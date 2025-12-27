-- Ensure pgcrypto is available for digest() function
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Fix: `jsonb_object_length(jsonb)` is not available; use an empty-object check.
--
-- This patches `public.log_consent_if_allowed` introduced/updated by
-- `20251222173000_consents_scopes_object_bool.sql` to validate non-empty scopes
-- without relying on `jsonb_object_length`.

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
  invalid_scope_ids text[];
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

  if jsonb_typeof(p_scopes) = 'array' then
    -- Legacy format: ["terms", "analytics", ...]
    invalid_scope_ids := array(
      select distinct v
      from jsonb_array_elements_text(p_scopes) v
      where not public.consents_scopes_keys_valid(jsonb_build_object(v, true))
    );
    if coalesce(cardinality(invalid_scope_ids), 0) > 0 then
      raise exception 'p_scopes contains unknown scope IDs: %',
        array_to_string(invalid_scope_ids, ', ');
    end if;

    normalized_scopes := (
      select coalesce(jsonb_object_agg(v, true), '{}'::jsonb)
      from (
        select distinct v
        from jsonb_array_elements_text(p_scopes) v
      ) s
    );
  elsif jsonb_typeof(p_scopes) = 'object' then
    -- Canonical format: {"terms": true, "analytics": true, ...}
    if not public.consents_scopes_values_boolean(p_scopes) then
      raise exception 'p_scopes must be an object with boolean values only';
    end if;

    invalid_scope_ids := array(
      select distinct e.key
      from jsonb_each(p_scopes) as e(key, value)
      where not public.consents_scopes_keys_valid(jsonb_build_object(e.key, true))
    );
    if coalesce(cardinality(invalid_scope_ids), 0) > 0 then
      raise exception 'p_scopes contains unknown scope IDs: %',
        array_to_string(invalid_scope_ids, ', ');
    end if;

    normalized_scopes := (
      select coalesce(jsonb_object_agg(e.key, true), '{}'::jsonb)
      from jsonb_each(p_scopes) as e(key, value)
      where e.value = 'true'::jsonb
    );
  else
    raise exception 'p_scopes must be an array (legacy) or object (canonical)';
  end if;

  if not public.consents_scopes_keys_valid(normalized_scopes) then
    raise exception 'p_scopes contains unknown scope IDs';
  end if;

  if normalized_scopes = '{}'::jsonb then
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
