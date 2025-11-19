-- Performance: composite index for sliding-window queries on consents
-- Covers patterns like: WHERE user_id = $1 AND created_at > $2
-- Note: Avoid CONCURRENTLY in migration to remain compatible with transactional runners.
CREATE INDEX IF NOT EXISTS idx_consents_user_id_created_at
  ON public.consents (user_id, created_at DESC);

