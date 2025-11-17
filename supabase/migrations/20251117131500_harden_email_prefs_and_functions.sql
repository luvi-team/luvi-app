-- Hardening migration: fix lint warnings for search_path, RLS policies, and FK index.

-- 1) Pin search_path for security-definer and helper functions so execution
--    does not depend on caller role settings.
ALTER FUNCTION public.set_user_id_from_auth()
  SET search_path = public;

ALTER FUNCTION public.hybrid_search_archon_code_examples_multi(
  vector,
  integer,
  text,
  integer,
  jsonb,
  text
) SET search_path = public;

ALTER FUNCTION public.hybrid_search_archon_crawled_pages_multi(
  vector,
  integer,
  text,
  integer,
  jsonb,
  text
) SET search_path = public;

ALTER FUNCTION public.match_archon_code_examples_multi(
  vector,
  integer,
  integer,
  jsonb,
  text
) SET search_path = public;

ALTER FUNCTION public.match_archon_crawled_pages_multi(
  vector,
  integer,
  integer,
  jsonb,
  text
) SET search_path = public;

ALTER FUNCTION public.update_updated_at_column()
  SET search_path = public;

ALTER FUNCTION public.archive_task(uuid, text)
  SET search_path = public;

ALTER FUNCTION public.detect_embedding_dimension(vector)
  SET search_path = public;

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

ALTER POLICY email_prefs_select_own ON public.email_preferences
  USING (user_id = (SELECT auth.uid()));

ALTER POLICY email_prefs_insert_own ON public.email_preferences
  WITH CHECK (user_id = (SELECT auth.uid()));

ALTER POLICY email_prefs_update_own ON public.email_preferences
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

ALTER POLICY email_prefs_delete_own ON public.email_preferences
  USING (user_id = (SELECT auth.uid()));

-- 3) Add a covering index for archon_tasks.parent_task_id to support the FK.
CREATE INDEX IF NOT EXISTS idx_archon_tasks_parent_task_id
  ON public.archon_tasks(parent_task_id);
