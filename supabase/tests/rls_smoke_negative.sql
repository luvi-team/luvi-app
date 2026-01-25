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

-- Persist IDs as session settings so DO blocks can access them (psql vars do not expand inside $$...$$ bodies).
SELECT set_config('rls_smoke.test_user_id', :'test_user_id', false);

-- Optional: pick a second auth.users row for cross-user (unauthorized) RLS checks.
SELECT id AS other_user_id
FROM auth.users
WHERE id <> :'test_user_id'
ORDER BY created_at NULLS LAST, id
LIMIT 1
\gset
\if :{?other_user_id}
SELECT set_config('rls_smoke.other_user_id', :'other_user_id', false);
\endif

-- ----------------------------------------------------------------------------
-- Negative RLS / Privilege Checks (unauthorized reads/writes must be blocked)
-- ----------------------------------------------------------------------------

-- anon must not be able to read or write sensitive tables.
RESET ROLE;
SET ROLE anon;
DO $$
BEGIN
  -- SELECT must fail (no table privileges).
  BEGIN
    PERFORM 1 FROM public.consents LIMIT 1;
    RAISE EXCEPTION 'Expected anon SELECT on public.consents to be blocked';
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN others THEN RAISE EXCEPTION 'Expected insufficient_privilege (42501), got % (%).', SQLERRM, SQLSTATE;
  END;

  BEGIN
    PERFORM 1 FROM public.cycle_data LIMIT 1;
    RAISE EXCEPTION 'Expected anon SELECT on public.cycle_data to be blocked';
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN others THEN RAISE EXCEPTION 'Expected insufficient_privilege (42501), got % (%).', SQLERRM, SQLSTATE;
  END;

  BEGIN
    PERFORM 1 FROM public.profiles LIMIT 1;
    RAISE EXCEPTION 'Expected anon SELECT on public.profiles to be blocked';
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN others THEN RAISE EXCEPTION 'Expected insufficient_privilege (42501), got % (%).', SQLERRM, SQLSTATE;
  END;

  BEGIN
    PERFORM 1 FROM public.email_preferences LIMIT 1;
    RAISE EXCEPTION 'Expected anon SELECT on public.email_preferences to be blocked';
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN others THEN RAISE EXCEPTION 'Expected insufficient_privilege (42501), got % (%).', SQLERRM, SQLSTATE;
  END;

  IF to_regclass('public.daily_plan') IS NOT NULL THEN
    BEGIN
      PERFORM 1 FROM public.daily_plan LIMIT 1;
      RAISE EXCEPTION 'Expected anon SELECT on public.daily_plan to be blocked';
    EXCEPTION
      WHEN insufficient_privilege THEN NULL;
      WHEN others THEN RAISE EXCEPTION 'Expected insufficient_privilege (42501), got % (%).', SQLERRM, SQLSTATE;
    END;
  END IF;

  -- INSERT/UPDATE/DELETE must fail.
  BEGIN
    INSERT INTO public.consents (user_id, scopes, version)
    VALUES (current_setting('rls_smoke.test_user_id')::uuid, '{}'::jsonb, 'rls-smoke-negative');
    RAISE EXCEPTION 'Expected anon INSERT on public.consents to be blocked';
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN others THEN RAISE EXCEPTION 'Expected insufficient_privilege (42501), got % (%).', SQLERRM, SQLSTATE;
  END;
END $$;
RESET ROLE;

-- authenticated must not be able to UPDATE/DELETE consents (append-only).
SET ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', :'test_user_id', 'role', 'authenticated')::text,
  false
);

INSERT INTO public.consents (id, user_id, scopes, version)
VALUES (
  '00000000-0000-0000-0000-00000000d001',
  (SELECT auth.uid()),
  DEFAULT,
  'rls-smoke-negative'
)
ON CONFLICT (id) DO NOTHING;

BEGIN;
DO $$
BEGIN
  BEGIN
    UPDATE public.consents
    SET version = 'should-fail'
    WHERE id = '00000000-0000-0000-0000-00000000d001';
    RAISE EXCEPTION 'Expected UPDATE on public.consents to be blocked (append-only)'
      USING ERRCODE = 'P9999';
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN raise_exception THEN NULL;
    WHEN others THEN RAISE EXCEPTION 'Expected blocked UPDATE (42501 or P0001), got % (%).', SQLERRM, SQLSTATE;
  END;

  BEGIN
    DELETE FROM public.consents
    WHERE id = '00000000-0000-0000-0000-00000000d001';
    RAISE EXCEPTION 'Expected DELETE on public.consents to be blocked (append-only)'
      USING ERRCODE = 'P9999';
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN others THEN RAISE EXCEPTION 'Expected insufficient_privilege (42501), got % (%).', SQLERRM, SQLSTATE;
  END;
END $$;
ROLLBACK;

-- Cross-user RLS: another authenticated user must not be able to read/update/delete test_user rows.
\if :{?other_user_id}
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', :'other_user_id', 'role', 'authenticated')::text,
  false
);

BEGIN;
DO $$
DECLARE
  can_see boolean;
  affected integer;
BEGIN
  SELECT COUNT(*) = 0 INTO can_see
  FROM public.consents
  WHERE id = '00000000-0000-0000-0000-00000000d001';
  ASSERT can_see, 'consents must not leak rows across authenticated users';

  UPDATE public.profiles
  SET display_name = display_name
  WHERE user_id = current_setting('rls_smoke.test_user_id')::uuid;
  GET DIAGNOSTICS affected = ROW_COUNT;
  ASSERT affected = 0, 'profiles UPDATE must not affect other users'' rows';

  UPDATE public.cycle_data
  SET cycle_length = cycle_length
  WHERE user_id = current_setting('rls_smoke.test_user_id')::uuid;
  GET DIAGNOSTICS affected = ROW_COUNT;
  ASSERT affected = 0, 'cycle_data UPDATE must not affect other users'' rows';

  DELETE FROM public.email_preferences
  WHERE user_id = current_setting('rls_smoke.test_user_id')::uuid;
  GET DIAGNOSTICS affected = ROW_COUNT;
  ASSERT affected = 0, 'email_preferences DELETE must not affect other users'' rows';

  IF to_regclass('public.daily_plan') IS NOT NULL THEN
    DELETE FROM public.daily_plan
    WHERE user_id = current_setting('rls_smoke.test_user_id')::uuid;
    GET DIAGNOSTICS affected = ROW_COUNT;
    ASSERT affected = 0, 'daily_plan DELETE must not affect other users'' rows';
  END IF;
END $$;
ROLLBACK;
\else
\echo 'rls_smoke_negative.sql: skipping cross-user RLS checks (only one auth.users row found).'
\endif

-- service_role must not be able to UPDATE/DELETE consents (append-only).
RESET ROLE;
BEGIN;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    EXECUTE 'SET ROLE service_role';
    BEGIN
      UPDATE public.consents
      SET version = version
      WHERE id = '00000000-0000-0000-0000-00000000d001';
      RAISE EXCEPTION 'Expected service_role UPDATE on public.consents to be blocked'
        USING ERRCODE = 'P9999';
    EXCEPTION
      WHEN insufficient_privilege THEN NULL;
      WHEN raise_exception THEN NULL;
      WHEN others THEN RAISE EXCEPTION 'Expected blocked UPDATE (42501 or P0001), got % (%).', SQLERRM, SQLSTATE;
    END;

    BEGIN
      DELETE FROM public.consents
      WHERE id = '00000000-0000-0000-0000-00000000d001';
      RAISE EXCEPTION 'Expected service_role DELETE on public.consents to be blocked'
        USING ERRCODE = 'P9999';
    EXCEPTION
      WHEN insufficient_privilege THEN NULL;
      WHEN others THEN RAISE EXCEPTION 'Expected insufficient_privilege (42501), got % (%).', SQLERRM, SQLSTATE;
    END;
    EXECUTE 'RESET ROLE';
  END IF;
END $$;
ROLLBACK;

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
