-- Enforce birthdate policy in a gate-safe, non-breaking way.
--
-- Policy (SSOT):
-- - Birthdate is required when onboarding is completed.
-- - Age must be between 16 and 120.
--
-- Live drift (confirmed):
-- - profiles.birth_date is nullable; at least one onboarding-completed row had NULL.
--
-- Approach:
-- 1) Repair/Backfill: Any profile marked as completed but missing/invalid birth_date
--    is downgraded to has_completed_onboarding=false (prevents gate bypass).
-- 2) Add CHECK constraint enforcing birth_date presence + bounds when completed.
--
-- NOTE: We intentionally do NOT set birth_date NOT NULL globally to avoid breaking
-- existing pre-onboarding rows.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_class t
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND t.relname = 'profiles'
  ) THEN
    RAISE NOTICE 'Skipping migration: public.profiles does not exist';
    RETURN;
  END IF;

  -- 1) Repair inconsistent rows (gate-safe)
  UPDATE public.profiles
  SET has_completed_onboarding = false,
      onboarding_completed_at = NULL
  WHERE has_completed_onboarding = true
    AND (
      birth_date IS NULL
      OR birth_date > (CURRENT_DATE - INTERVAL '16 years')
      OR birth_date < (CURRENT_DATE - INTERVAL '120 years')
    );

  -- 2) Enforce policy for future writes
  ALTER TABLE public.profiles
    DROP CONSTRAINT IF EXISTS profiles_birth_date_required_when_completed;

  ALTER TABLE public.profiles
    ADD CONSTRAINT profiles_birth_date_required_when_completed
      CHECK (
        has_completed_onboarding = false
        OR (
          birth_date IS NOT NULL
          AND birth_date <= (CURRENT_DATE - INTERVAL '16 years')
          AND birth_date >= (CURRENT_DATE - INTERVAL '120 years')
        )
      );
END $$;

