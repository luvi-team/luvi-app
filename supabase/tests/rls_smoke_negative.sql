\set ON_ERROR_STOP on
RESET ROLE;
RESET ALL;

-- Pick a real auth.users row so FK constraints work in remote envs (no hard-coded fixture user).
SELECT id AS test_user_id
FROM auth.users
ORDER BY created_at NULLS LAST, id
LIMIT 1
\gset
\if :{?test_user_id}
\else
\echo 'rls_smoke_negative.sql requires at least one auth.users record (otherwise FK inserts will fail).'
\quit 1
\endif

SET ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', :'test_user_id', 'role', 'authenticated')::text,
  false
);

-- Anti-Drift: consents.scopes must reject legacy array format.
DO $$
BEGIN
  BEGIN
    INSERT INTO public.consents (user_id, scopes, version)
    VALUES ((SELECT auth.uid()), '["terms"]'::jsonb, 'rls-smoke-negative');
    RAISE EXCEPTION 'Expected CHECK violation: consents.scopes must be a JSONB object';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN others THEN
      RAISE EXCEPTION 'Expected check_violation (23514), got % (%).', SQLERRM, SQLSTATE;
  END;
END $$;

-- Anti-Drift: consents.scopes must reject unknown scope IDs.
DO $$
BEGIN
  BEGIN
    INSERT INTO public.consents (user_id, scopes, version)
    VALUES ((SELECT auth.uid()), '{"unknown_scope": true}'::jsonb, 'rls-smoke-negative');
    RAISE EXCEPTION 'Expected CHECK violation: consents.scopes must only contain allowed keys';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN others THEN
      RAISE EXCEPTION 'Expected check_violation (23514), got % (%).', SQLERRM, SQLSTATE;
  END;
END $$;

-- Anti-Drift: consents.scopes must reject non-boolean values.
DO $$
BEGIN
  BEGIN
    INSERT INTO public.consents (user_id, scopes, version)
    VALUES ((SELECT auth.uid()), '{"terms": "true"}'::jsonb, 'rls-smoke-negative');
    RAISE EXCEPTION 'Expected CHECK violation: consents.scopes values must be boolean';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN others THEN
      RAISE EXCEPTION 'Expected check_violation (23514), got % (%).', SQLERRM, SQLSTATE;
  END;
END $$;

-- Anti-Drift: cycle_data bounds must allow period_duration up to 15 and cycle_length down to 1.
-- Reject invalid values beyond SSOT bounds.
DO $$
BEGIN
  -- period_duration > 15 must fail
  BEGIN
    INSERT INTO public.cycle_data (user_id, cycle_length, period_duration, last_period, age)
    VALUES ((SELECT auth.uid()), 28, 16, '2025-01-01', 25)
    ON CONFLICT (user_id) DO UPDATE
      SET cycle_length = EXCLUDED.cycle_length,
          period_duration = EXCLUDED.period_duration,
          last_period = EXCLUDED.last_period,
          age = EXCLUDED.age;
    RAISE EXCEPTION 'Expected CHECK violation: cycle_data.period_duration must be <= 15';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN others THEN
      RAISE EXCEPTION 'Expected check_violation (23514), got % (%).', SQLERRM, SQLSTATE;
  END;

  -- cycle_length > 60 must fail
  BEGIN
    INSERT INTO public.cycle_data (user_id, cycle_length, period_duration, last_period, age)
    VALUES ((SELECT auth.uid()), 61, 5, '2025-01-01', 25)
    ON CONFLICT (user_id) DO UPDATE
      SET cycle_length = EXCLUDED.cycle_length,
          period_duration = EXCLUDED.period_duration,
          last_period = EXCLUDED.last_period,
          age = EXCLUDED.age;
    RAISE EXCEPTION 'Expected CHECK violation: cycle_data.cycle_length must be <= 60';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN others THEN
      RAISE EXCEPTION 'Expected check_violation (23514), got % (%).', SQLERRM, SQLSTATE;
  END;
END $$;

-- Policy: birth_date required when has_completed_onboarding=true.
-- Note: Age bounds (16-120) are enforced separately in constraints, not tested here.
DO $$
BEGIN
  BEGIN
    INSERT INTO public.profiles (user_id, display_name, birth_date, has_completed_onboarding, onboarding_completed_at)
    VALUES ((SELECT auth.uid()), 'rls-smoke-negative', NULL, true, now())
    ON CONFLICT (user_id) DO UPDATE
      SET birth_date = NULL,
          has_completed_onboarding = true,
          onboarding_completed_at = now();
    RAISE EXCEPTION 'Expected CHECK violation: profiles.birth_date required when onboarding complete';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN others THEN
      RAISE EXCEPTION 'Expected check_violation (23514), got % (%).', SQLERRM, SQLSTATE;
  END;
END $$;
