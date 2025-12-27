-- Migration: Replace CHECK constraint with BEFORE trigger for age validation
-- Reason: CHECK with CURRENT_DATE is time-sensitive and can invalidate rows on unrelated updates
-- The trigger only validates when has_completed_onboarding transitions to true
-- CodeRabbit Issue #14

-- Step 1: Drop the existing CHECK constraint
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_birth_date_required_when_completed;

-- Step 2: Create trigger function for conditional validation
CREATE OR REPLACE FUNCTION public.validate_birth_date_on_complete()
RETURNS TRIGGER AS $$
BEGIN
  -- Only validate when transitioning to completed onboarding
  IF NEW.has_completed_onboarding = true AND
     (OLD IS NULL OR OLD.has_completed_onboarding IS DISTINCT FROM true) THEN

    -- Check birth_date is set
    IF NEW.birth_date IS NULL THEN
      RAISE EXCEPTION 'birth_date is required when completing onboarding'
        USING ERRCODE = 'check_violation';
    END IF;

    -- Check age is at least 16
    IF NEW.birth_date > (CURRENT_DATE - INTERVAL '16 years') THEN
      RAISE EXCEPTION 'User must be at least 16 years old'
        USING ERRCODE = 'check_violation';
    END IF;

    -- Check age is at most 120
    IF NEW.birth_date < (CURRENT_DATE - INTERVAL '120 years') THEN
      RAISE EXCEPTION 'Invalid birth date: age exceeds 120 years'
        USING ERRCODE = 'check_violation';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create trigger
DROP TRIGGER IF EXISTS trg_validate_birth_date ON public.profiles;
CREATE TRIGGER trg_validate_birth_date
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_birth_date_on_complete();

-- Note: Trigger validates ONLY on transition to completed, not on every update
