-- Atomic consent logging with per-user advisory lock to prevent race conditions
-- Function: public.log_consent_if_allowed
-- Behavior: acquires a transaction-scoped advisory lock per user, checks the
--           sliding-window count, and conditionally inserts a consent record.
-- Returns: boolean (true if inserted, false if rate-limited)

-- Ensure pgcrypto is available for digest()
create extension if not exists pgcrypto;

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
declare
  recent_count integer := 0;
  lock_key bigint;
  d bytea;
begin
begin
  -- Validate input parameters early to avoid ambiguous failures downstream.
  if p_user_id is null then
    raise exception 'p_user_id must be a non-null valid uuid';
  end if;
  if p_version is null or btrim(p_version) = '' then
    raise exception 'p_version must be provided';
  end if;
  if p_scopes is null or jsonb_typeof(p_scopes) <> 'array' then
    raise exception 'p_scopes must be a non-empty array';
  end if;
  if jsonb_array_length(p_scopes) < 1 then
    raise exception 'p_scopes must be a non-empty array';
  end if;
  if p_window_sec is null or p_window_sec <= 0 then
    raise exception 'p_window_sec must be > 0';
  end if;
  if p_max_requests is null or p_max_requests <= 0 then
    raise exception 'p_max_requests must be > 0';
  end if;

  -- Derive a stable 64-bit signed key from the UUID using SHA-256 digest.
  -- Take the first 8 bytes of the digest (big-endian) as an unsigned 64-bit
  -- value, then convert to a signed bigint range acceptable to
  -- pg_advisory_xact_lock.
  d := digest(p_user_id::text, 'sha256');
  -- Take first 8 bytes as hex and cast to bigint (automatically handles sign conversion)
  lock_key := ('x' || encode(substring(d, 1, 8), 'hex'))::bit(64)::bigint;
  perform pg_advisory_xact_lock(lock_key);

  -- Count consents in the sliding window for this user
  select count(*) into recent_count
  from public.consents c
  where c.user_id = p_user_id
    and c.created_at > now() - make_interval(secs => p_window_sec);

  if recent_count >= p_max_requests then
    return false; -- rate limited
  end if;

  -- Insert consent respecting RLS (security invoker)
  insert into public.consents(user_id, version, scopes)
  values (p_user_id, p_version, p_scopes);

  return true;
end;
$$;

comment on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer)
  is 'Atomically logs a consent after a sliding-window rate limit check under a per-user advisory lock.';

grant execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer)
  to authenticated;
