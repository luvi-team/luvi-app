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

  ALTER TABLE public.cycle_data
    DROP CONSTRAINT IF EXISTS chk_cycle_length;

  ALTER TABLE public.cycle_data
    DROP CONSTRAINT IF EXISTS chk_period_duration;
END $$;

