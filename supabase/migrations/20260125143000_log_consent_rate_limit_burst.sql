-- Update log_consent_if_allowed to support burst allowance in rate limiting.
-- Adds p_burst_max_requests and ensures least-privilege grants are preserved.

begin;

create extension if not exists pgcrypto;

drop function if exists public.log_consent_if_allowed(uuid, text, jsonb, integer, integer);

create or replace function public.log_consent_if_allowed(
  p_user_id uuid,
  p_version text,
  p_scopes jsonb,
  p_window_sec integer,
  p_max_requests integer,
  p_burst_max_requests integer
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
  effective_max integer;
begin
  if p_user_id is null then
    raise exception 'p_user_id must be a non-null valid uuid';
  end if;

  -- Defense-in-depth: always enforce end-user context (no `service_role` bypass).
  if auth.uid() is null then
    raise exception 'auth.uid() must be available'
      using errcode = '42501';
  end if;
  if p_user_id is distinct from auth.uid() then
    raise exception 'p_user_id must match auth.uid()'
      using errcode = '42501';
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

    -- Validate ALL keys (even if value=false) to avoid confusing "empty" errors.
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

  if normalized_scopes = '{}'::jsonb then
    raise exception 'p_scopes must be non-empty';
  end if;

  if p_window_sec is null or p_window_sec <= 0 then
    raise exception 'p_window_sec must be > 0';
  end if;
  if p_max_requests is null or p_max_requests <= 0 then
    raise exception 'p_max_requests must be > 0';
  end if;
  if p_burst_max_requests is null or p_burst_max_requests < 0 then
    raise exception 'p_burst_max_requests must be >= 0';
  end if;

  -- Guard against integer overflow in effective_max
  if p_max_requests > 1000000 or p_burst_max_requests > 1000000 then
    raise exception 'p_max_requests and p_burst_max_requests must be <= 1000000';
  end if;

  effective_max := p_max_requests + p_burst_max_requests;

  d := digest(p_user_id::text, 'sha256');
  lock_key := ('x' || encode(substring(d, 1, 8), 'hex'))::bit(64)::bigint;
  perform pg_advisory_xact_lock(lock_key);

  select count(*) into recent_count
  from public.consents c
  where c.user_id = p_user_id
    and c.created_at > now() - make_interval(secs => p_window_sec);

  if recent_count >= effective_max then
    return false;
  end if;

  insert into public.consents(user_id, version, scopes)
  values (p_user_id, p_version, normalized_scopes);

  return true;
end;
$$;

revoke execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer, integer) from public;
revoke execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer, integer) from anon;
-- Intentionally revoked: service_role bypass blocked; function enforces auth.uid() match.
-- Verify in app/edge code that log_consent_if_allowed is called only with anon/authenticated context.
revoke execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer, integer) from service_role;
grant execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer, integer) to authenticated;
commit;
