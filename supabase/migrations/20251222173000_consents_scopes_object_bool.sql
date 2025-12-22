-- Canonicalize `public.consents.scopes` to a JSONB object of boolean flags.
--
-- Background:
-- - We detected "format drift" where `consents.scopes` was sometimes stored as
--   an array (["analytics", "crash"]) and sometimes as an object
--   ({"analytics": true, "crash": true}).
-- - We want one canonical SSOT format for exports/analytics and compliance
--   evidence.
--
-- Canonical format (this migration):
-- - `scopes` is a JSONB object: {"scope_id": true, ...}
-- - Only known scope IDs are allowed (defense-in-depth).
-- - Values must be boolean.
--
-- Unknown scope handling:
-- - Unknown keys are dropped during backfill (MVP-safe normalization).
-- - After this migration, unknown keys are rejected by CHECK constraints.

-- Helper: allowed scope IDs (must match `config/consent_scopes.json`).
create or replace function public.consents_scopes_keys_valid(p_scopes jsonb)
returns boolean
language sql
immutable
as $$
  select not exists (
    select 1
    from jsonb_object_keys(p_scopes) as k
    where k not in (
      'terms',
      'health_processing',
      'analytics',
      'marketing',
      'ai_journal',
      'model_training'
    )
  );
$$;

-- Helper: enforce that all values are boolean.
create or replace function public.consents_scopes_values_boolean(p_scopes jsonb)
returns boolean
language sql
immutable
as $$
  select not jsonb_path_exists(p_scopes, '$.* ? (@.type() != "boolean")');
$$;

do $$
declare
  v_backfilled integer := 0;
  v_coerced integer := 0;
begin
  -- Drop previous anti-drift constraint (array) before any backfill updates,
  -- otherwise row updates from array->object would violate it.
  alter table public.consents
    drop constraint if exists consents_scopes_is_array;

  -- Align default with canonical object format early (safe with constraint dropped).
  alter table public.consents
    alter column scopes set default '{}'::jsonb;

  -- 1) Backfill legacy array rows -> canonical object map.
  update public.consents c
  set scopes = (
    select coalesce(jsonb_object_agg(v, true), '{}'::jsonb)
    from jsonb_array_elements_text(c.scopes) v
    where v in (
      'terms',
      'health_processing',
      'analytics',
      'marketing',
      'ai_journal',
      'model_training'
    )
  )
  where jsonb_typeof(c.scopes) = 'array';

  get diagnostics v_backfilled = row_count;
  if v_backfilled > 0 then
    raise notice 'Backfilled % public.consents rows from array->object scopes', v_backfilled;
  end if;

  -- 2) Coerce legacy object rows into canonical object map:
  --    - Keep only known keys
  --    - Coerce common non-boolean representations safely
  --    - Store only enabled scopes (value=true)
  update public.consents c
  set scopes = (
    select coalesce(jsonb_object_agg(e.key, true), '{}'::jsonb)
    from jsonb_each(c.scopes) as e(key, value)
    where e.key in (
      'terms',
      'health_processing',
      'analytics',
      'marketing',
      'ai_journal',
      'model_training'
    )
    and (
      case jsonb_typeof(e.value)
        when 'boolean' then e.value = 'true'::jsonb
        when 'string' then lower(e.value #>> '{}') = 'true'
        when 'number' then (e.value #>> '{}')::numeric <> 0
        else false
      end
    )
  )
  where jsonb_typeof(c.scopes) = 'object';

  get diagnostics v_coerced = row_count;
  if v_coerced > 0 then
    raise notice 'Normalized % public.consents rows from object->object scopes', v_coerced;
  end if;

  -- 3) Defense-in-depth: normalize unexpected JSON types to empty object.
  update public.consents
  set scopes = '{}'::jsonb
  where jsonb_typeof(scopes) is null
     or jsonb_typeof(scopes) not in ('object', 'array');

  -- Replace/ensure canonical constraint.
  alter table public.consents
    drop constraint if exists consents_scopes_is_object_bool;
  alter table public.consents
    add constraint consents_scopes_is_object_bool
      check (
        jsonb_typeof(scopes) = 'object'
        and public.consents_scopes_values_boolean(scopes)
        and public.consents_scopes_keys_valid(scopes)
      );
end $$;

-- Update RPC contract: accept array (legacy) or object (canonical),
-- normalize internally, and persist canonical object only.
create or replace function public.log_consent_if_allowed(
  p_user_id uuid,
  p_version text,
  p_scopes jsonb,
  p_window_sec integer,
  p_max_requests integer
)
returns boolean
language plpgsql
security invoker
as $$
declare
  recent_count integer := 0;
  lock_key bigint;
  d bytea;
  normalized_scopes jsonb;
begin
  if p_user_id is null then
    raise exception 'p_user_id must be a non-null valid uuid';
  end if;
  if p_version is null or btrim(p_version) = '' then
    raise exception 'p_version must be provided';
  end if;
  if p_scopes is null then
    raise exception 'p_scopes must be provided';
  end if;

  -- Normalize legacy formats to canonical object.
  if jsonb_typeof(p_scopes) = 'array' then
    normalized_scopes := (
      select coalesce(jsonb_object_agg(v, true), '{}'::jsonb)
      from jsonb_array_elements_text(p_scopes) v
    );
  elsif jsonb_typeof(p_scopes) = 'object' then
    -- Require boolean values only; store only enabled scopes.
    if not public.consents_scopes_values_boolean(p_scopes) then
      raise exception 'p_scopes must be an object with boolean values only';
    end if;
    normalized_scopes := (
      select coalesce(jsonb_object_agg(e.key, true), '{}'::jsonb)
      from jsonb_each(p_scopes) as e(key, value)
      where e.value = 'true'::jsonb
    );
  else
    raise exception 'p_scopes must be an array (legacy) or object (canonical)';
  end if;

  -- Defense-in-depth: only allow known scope IDs.
  if not public.consents_scopes_keys_valid(normalized_scopes) then
    raise exception 'p_scopes contains unknown scope IDs';
  end if;

  if jsonb_object_length(normalized_scopes) < 1 then
    raise exception 'p_scopes must be non-empty';
  end if;

  if p_window_sec is null or p_window_sec <= 0 then
    raise exception 'p_window_sec must be > 0';
  end if;
  if p_max_requests is null or p_max_requests <= 0 then
    raise exception 'p_max_requests must be > 0';
  end if;

  d := digest(p_user_id::text, 'sha256');
  lock_key := ('x' || encode(substring(d, 1, 8), 'hex'))::bit(64)::bigint;
  perform pg_advisory_xact_lock(lock_key);

  select count(*) into recent_count
  from public.consents c
  where c.user_id = p_user_id
    and c.created_at > now() - make_interval(secs => p_window_sec);

  if recent_count >= p_max_requests then
    return false;
  end if;

  insert into public.consents(user_id, version, scopes)
  values (p_user_id, p_version, normalized_scopes);

  return true;
end;
$$;
