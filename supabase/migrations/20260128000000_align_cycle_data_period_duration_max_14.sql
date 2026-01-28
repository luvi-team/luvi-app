-- Align period_duration constraint to match UI constant kMaxPeriodDuration = 14.
--
-- Drift: DB allows period_duration <= 15, UI clamps to <= 14.
-- Resolution: Clamp any rows with period_duration > 14 to 14 (medically valid),
-- then tighten the constraint.
--
-- Reference:
-- - lib/features/onboarding/utils/onboarding_constants.dart:39 (kMaxPeriodDuration = 14)
-- - 20251222112000_fix_cycle_data_constraint_drift.sql (previous constraint fix)

DO $$
DECLARE
  v_rows_to_clamp integer := 0;
BEGIN
  -- Skip if table does not exist (fresh environment)
  IF NOT EXISTS (
    SELECT 1
    FROM pg_class t
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND t.relname = 'cycle_data'
  ) THEN
    RAISE NOTICE 'Skipping migration: public.cycle_data does not exist';
    RETURN;
  END IF;

  -- Preflight: count rows that will be clamped
  SELECT count(*) INTO v_rows_to_clamp
  FROM public.cycle_data
  WHERE period_duration > 14;

  IF v_rows_to_clamp > 0 THEN
    RAISE NOTICE 'Clamping % row(s) with period_duration > 14 to 14', v_rows_to_clamp;

    -- Clamp values to 14 (medically valid maximum)
    UPDATE public.cycle_data
    SET period_duration = 14
    WHERE period_duration > 14;
  ELSE
    RAISE NOTICE 'No rows require clamping (all period_duration <= 14)';
  END IF;

  -- Drop existing constraint
  ALTER TABLE public.cycle_data
    DROP CONSTRAINT IF EXISTS chk_period_duration;

  -- Add tightened constraint (matches UI kMaxPeriodDuration = 14)
  ALTER TABLE public.cycle_data
    ADD CONSTRAINT chk_period_duration
    CHECK (period_duration > 0 AND period_duration <= 14);

  RAISE NOTICE 'Successfully aligned chk_period_duration to <= 14';
END $$;
