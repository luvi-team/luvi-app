-- Ensure pgcrypto is available for digest() function
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Defense-in-depth: ensure caller can only log consent for auth.uid().
-- Keeps the existing log_consent_if_allowed logic unchanged except for the
-- explicit auth.uid() match check.

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
  if current_user <> 'service_role' then
    if auth.uid() is null then
      raise exception 'auth.uid() must be available'
        using errcode = '42501';
    end if;
    if p_user_id is distinct from auth.uid() then
      raise exception 'p_user_id must match auth.uid()'
        using errcode = '42501';
    end if;
  end if;
  if p_version is null or btrim(p_version) = '' then
    raise exception 'p_version must be provided';
  end if;
  if p_scopes is null then
    raise exception 'p_scopes must be provided';
  end if;

  if jsonb_typeof(p_scopes) = 'array' then
    normalized_scopes := (
      select coalesce(jsonb_object_agg(v, true), '{}'::jsonb)
      from jsonb_array_elements_text(p_scopes) v
    );
  elsif jsonb_typeof(p_scopes) = 'object' then
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
