-- Ensure a single cycle_data profile per user (1:1) in a reproducible way.
-- This migration is idempotent: it only adds the constraint if it does not already exist.

DO $$
BEGIN
  -- Check if a constraint with the expected name already exists
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t ON c.conrelid = t.oid
    JOIN pg_namespace n ON t.relnamespace = n.oid
    WHERE n.nspname = 'public'
      AND t.relname = 'cycle_data'
      AND c.conname = 'ux_cycle_data_user'
  ) AND NOT EXISTS (
    SELECT 1
    FROM pg_class i
    JOIN pg_namespace n ON i.relnamespace = n.oid
    WHERE n.nspname = 'public'
      AND i.relkind = 'i'
      AND i.relname = 'ux_cycle_data_user'
  ) THEN
    ALTER TABLE public.cycle_data
      ADD CONSTRAINT ux_cycle_data_user UNIQUE (user_id);
  END IF;
END;
$$;

