-- Harden trigger helper functions by pinning their search_path to the public schema.
-- Only function metadata is updated here; no application data is modified.

DO $$
BEGIN
  -- Pin search_path for set_user_id_from_auth if the function exists in public schema.
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'set_user_id_from_auth'
      AND n.nspname = 'public'
      AND p.pronargs = 0
  ) THEN
    EXECUTE 'ALTER FUNCTION public.set_user_id_from_auth() SET search_path = public';
  END IF;

  -- Pin search_path for update_updated_at_column if the function exists in public schema.
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'update_updated_at_column'
      AND n.nspname = 'public'
      AND p.pronargs = 0
  ) THEN
    EXECUTE 'ALTER FUNCTION public.update_updated_at_column() SET search_path = public';
  END IF;
END;
$$;
