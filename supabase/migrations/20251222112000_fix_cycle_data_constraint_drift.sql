-- Fix drifted CHECK constraints on `public.cycle_data`.
--
-- Live drift (confirmed):
-- - chk_cycle_length enforces cycle_length >= 21
-- - chk_period_duration enforces period_duration <= 10
--
-- Repo SSOT:
-- - cycle_length: > 0 and <= 60 (see `20250903235539_create_cycle_data_table.sql`)
-- - period_duration: > 0 and <= 15
--
-- This migration drops the drift constraints so DB + client validations align
-- again and onboarding saves cannot get stuck in retry loops.

DO $$
DECLARE
  v_invalid_cycle_length integer := 0;
  v_invalid_period_duration integer := 0;
BEGIN
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

  -- Drop drifted constraints (too restrictive)
  -- Drift: cycle_length >= 21, period_duration <= 10
  ALTER TABLE public.cycle_data
    DROP CONSTRAINT IF EXISTS chk_cycle_length;
  ALTER TABLE public.cycle_data
    DROP CONSTRAINT IF EXISTS chk_period_duration;

  -- Preflight: existing rows can violate SSOT bounds even if they passed the
  -- drift constraints (cycle_length had no max; period_duration had no min).
  SELECT count(*) INTO v_invalid_cycle_length
  FROM public.cycle_data
  WHERE cycle_length <= 0 OR cycle_length > 60;

  SELECT count(*) INTO v_invalid_period_duration
  FROM public.cycle_data
  WHERE period_duration <= 0 OR period_duration > 15;

  IF v_invalid_cycle_length > 0 THEN
    RAISE NOTICE
      'cycle_data has % rows with cycle_length outside (0, 60]; adding chk_cycle_length as NOT VALID to avoid blocking deploy',
      v_invalid_cycle_length;
  END IF;

  IF v_invalid_period_duration > 0 THEN
    RAISE NOTICE
      'cycle_data has % rows with period_duration outside (0, 15]; adding chk_period_duration as NOT VALID to avoid blocking deploy',
      v_invalid_period_duration;
  END IF;

  -- Re-create with SSOT bounds
  -- SSOT: cycle_length > 0 AND <= 60, period_duration > 0 AND <= 15
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_cycle_length'
      AND conrelid = 'public.cycle_data'::regclass
  ) THEN
    IF v_invalid_cycle_length > 0 THEN
      ALTER TABLE public.cycle_data
        ADD CONSTRAINT chk_cycle_length
        CHECK (cycle_length > 0 AND cycle_length <= 60) NOT VALID;
    ELSE
      ALTER TABLE public.cycle_data
        ADD CONSTRAINT chk_cycle_length
        CHECK (cycle_length > 0 AND cycle_length <= 60);
    END IF;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_period_duration'
      AND conrelid = 'public.cycle_data'::regclass
  ) THEN
    IF v_invalid_period_duration > 0 THEN
      ALTER TABLE public.cycle_data
        ADD CONSTRAINT chk_period_duration
        CHECK (period_duration > 0 AND period_duration <= 15) NOT VALID;
    ELSE
      ALTER TABLE public.cycle_data
        ADD CONSTRAINT chk_period_duration
        CHECK (period_duration > 0 AND period_duration <= 15);
    END IF;
  END IF;

END $$;
