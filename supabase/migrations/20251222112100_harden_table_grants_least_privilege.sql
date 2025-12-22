-- Least-Privilege hardening (Defense-in-depth).
--
-- Live drift (confirmed):
-- - anon had SELECT and TRUNCATE on multiple sensitive tables.
-- - authenticated had TRUNCATE/TRIGGER/REFERENCES/MAINTAIN due to default ACLs.
--
-- SSOT intent:
-- - RLS remains the primary barrier.
-- - Grants should be minimal: authenticated needs SELECT/INSERT/UPDATE/DELETE only.
-- - anon/public should not have access to sensitive tables.
--
-- Notes:
-- - PostgREST does not expose TRUNCATE/TRIGGER/REFERENCES/MAINTAIN; removing them
--   reduces blast-radius if creds are compromised and aligns with ADR-0002.
-- - This migration also tightens DEFAULT PRIVILEGES so future tables don't
--   silently regain broad grants.

DO $$
DECLARE
  table_name text;
  tables text[] := ARRAY[
    'profiles',
    'consents',
    'cycle_data',
    'email_preferences',
    'daily_plan'
  ];
BEGIN
  -- 1) Fix existing tables
  FOREACH table_name IN ARRAY tables LOOP
    IF EXISTS (
      SELECT 1
      FROM pg_class t
      JOIN pg_namespace n ON n.oid = t.relnamespace
      WHERE n.nspname = 'public'
        AND t.relname = table_name
    ) THEN
      EXECUTE format('REVOKE ALL ON TABLE public.%I FROM anon', table_name);
      EXECUTE format('REVOKE ALL ON TABLE public.%I FROM authenticated', table_name);
      EXECUTE format('REVOKE ALL ON TABLE public.%I FROM PUBLIC', table_name);

      EXECUTE format(
        'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.%I TO authenticated',
        table_name
      );

      -- Keep admin workflows functional (explicit grant; does not affect client).
      EXECUTE format(
        'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.%I TO service_role',
        table_name
      );
    END IF;
  END LOOP;

  -- 2) Fix default privileges (root cause of recurring grant drift)
  --
  -- Current live defaults were granting ALL table privileges (incl. TRUNCATE/TRIGGER)
  -- to anon/authenticated/service_role on new tables in `public`.
  --
  -- The role used by Supabase CLI might not be allowed to change default
  -- privileges for other owner roles (e.g. `supabase_admin`). Therefore:
  -- - Always fix defaults for the CURRENT ROLE (no `FOR ROLE`).
  -- - Best-effort attempt to fix for `supabase_admin` without failing the migration.
  ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM anon;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM authenticated;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM service_role;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO service_role;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN
    BEGIN
      EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON TABLES FROM anon';
      EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON TABLES FROM authenticated';
      EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON TABLES FROM service_role';
      EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC';
      EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated';
      EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO service_role';
    EXCEPTION
      WHEN insufficient_privilege THEN
        RAISE NOTICE 'Skipping ALTER DEFAULT PRIVILEGES for role supabase_admin (insufficient_privilege)';
    END;
  END IF;
END $$;
