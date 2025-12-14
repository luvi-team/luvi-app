-- Defense-in-depth hardening:
-- - daily_plan contains health data → FORCE RLS + remove anon table privileges.
-- - log_consent_if_allowed() should not be callable by anon/public.

alter table if exists public.daily_plan force row level security;
revoke all on table public.daily_plan from anon;

-- log_consent_if_allowed: keep authenticated/service_role, remove public/anon.
revoke execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) from public;
revoke execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) from anon;
grant execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) to authenticated;
grant execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) to service_role;

