-- Defense-in-depth hardening:
-- - daily_plan contains health data → FORCE RLS + remove anon table privileges.
-- - log_consent_if_allowed() should not be callable by anon/public.

alter table if exists public.daily_plan force row level security;
revoke all on table public.daily_plan from anon;

-- log_consent_if_allowed: keep authenticated/service_role, remove public/anon.
-- Wrapped in conditional to prevent errors if function doesn't exist yet.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname = 'log_consent_if_allowed'
      AND pg_get_function_identity_arguments(p.oid) = 'uuid, text, jsonb, integer, integer'
  ) THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) FROM public';
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) FROM anon';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) TO authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) TO service_role';
  END IF;
END
$$;

