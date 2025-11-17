-- Hardening migration: fix lint warnings for search_path, RLS policies, and FK index.

-- 1) Pin search_path for security-definer and helper functions so execution
--    does not depend on caller role settings. Use defensive checks so the
--    migration does not fail if optional Archon functions are missing.
DO $$
BEGIN
  -- set_user_id_from_auth()
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

  -- hybrid_search_archon_code_examples_multi(...)
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'hybrid_search_archon_code_examples_multi'
      AND n.nspname = 'public'
      AND p.pronargs = 6
  ) THEN
    EXECUTE 'ALTER FUNCTION public.hybrid_search_archon_code_examples_multi(vector, integer, text, integer, jsonb, text) SET search_path = public';
  END IF;

  -- hybrid_search_archon_crawled_pages_multi(...)
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'hybrid_search_archon_crawled_pages_multi'
      AND n.nspname = 'public'
      AND p.pronargs = 6
  ) THEN
    EXECUTE 'ALTER FUNCTION public.hybrid_search_archon_crawled_pages_multi(vector, integer, text, integer, jsonb, text) SET search_path = public';
  END IF;

  -- match_archon_code_examples_multi(...)
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'match_archon_code_examples_multi'
      AND n.nspname = 'public'
      AND p.pronargs = 5
  ) THEN
    EXECUTE 'ALTER FUNCTION public.match_archon_code_examples_multi(vector, integer, integer, jsonb, text) SET search_path = public';
  END IF;

  -- match_archon_crawled_pages_multi(...)
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'match_archon_crawled_pages_multi'
      AND n.nspname = 'public'
      AND p.pronargs = 5
  ) THEN
    EXECUTE 'ALTER FUNCTION public.match_archon_crawled_pages_multi(vector, integer, integer, jsonb, text) SET search_path = public';
  END IF;

  -- update_updated_at_column()
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

  -- archive_task(uuid, text)
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'archive_task'
      AND n.nspname = 'public'
      AND p.pronargs = 2
  ) THEN
    EXECUTE 'ALTER FUNCTION public.archive_task(uuid, text) SET search_path = public';
  END IF;

  -- detect_embedding_dimension(vector)
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname = 'detect_embedding_dimension'
      AND n.nspname = 'public'
      AND p.pronargs = 1
  ) THEN
    EXECUTE 'ALTER FUNCTION public.detect_embedding_dimension(vector) SET search_path = public';
  END IF;
END;
$$;

-- 2) Update email_preferences policies to avoid per-row auth.<fn>() init plans.
ALTER POLICY "Users can view their own email preferences" ON public.email_preferences
  USING (user_id = (SELECT auth.uid()));

ALTER POLICY "Users can insert their own email preferences" ON public.email_preferences
  WITH CHECK (user_id = (SELECT auth.uid()));

ALTER POLICY "Users can update their own email preferences" ON public.email_preferences
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

ALTER POLICY "Users can delete their own email preferences" ON public.email_preferences
  USING (user_id = (SELECT auth.uid()));

-- 3) Add a covering index for archon_tasks.parent_task_id to support the FK.
CREATE INDEX IF NOT EXISTS idx_archon_tasks_parent_task_id
  ON public.archon_tasks(parent_task_id);
