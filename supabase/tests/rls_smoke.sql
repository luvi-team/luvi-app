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
\echo 'rls_smoke.sql requires at least one auth.users record (otherwise FK inserts will fail).'
\quit 1
\endif

-- Grants (Defense-in-depth): anon/public must not have access to sensitive tables.
DO $$
BEGIN
  -- anon
  ASSERT NOT has_table_privilege('anon', 'public.consents', 'SELECT'),
    'anon must not have SELECT on public.consents';
  ASSERT NOT has_table_privilege('anon', 'public.consents', 'TRUNCATE'),
    'anon must not have TRUNCATE on public.consents';
  ASSERT NOT has_table_privilege('anon', 'public.cycle_data', 'SELECT'),
    'anon must not have SELECT on public.cycle_data';
  ASSERT NOT has_table_privilege('anon', 'public.cycle_data', 'TRUNCATE'),
    'anon must not have TRUNCATE on public.cycle_data';
  ASSERT NOT has_table_privilege('anon', 'public.email_preferences', 'SELECT'),
    'anon must not have SELECT on public.email_preferences';
  ASSERT NOT has_table_privilege('anon', 'public.email_preferences', 'TRUNCATE'),
    'anon must not have TRUNCATE on public.email_preferences';
  ASSERT NOT has_table_privilege('anon', 'public.profiles', 'SELECT'),
    'anon must not have SELECT on public.profiles';
  ASSERT NOT has_table_privilege('anon', 'public.daily_plan', 'SELECT'),
    'anon must not have SELECT on public.daily_plan';
END $$;

-- Grants: service_role must not be able to directly DELETE from consents (append-only audit log).
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    ASSERT NOT has_table_privilege('service_role', 'public.consents', 'DELETE'),
      'service_role must not have DELETE on public.consents (append-only)';
  END IF;
END $$;

-- Grants: ensure no explicit privileges exist for the PUBLIC pseudo-role (grantee=0).
DO $$
BEGIN
  ASSERT NOT EXISTS (
    SELECT 1
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    CROSS JOIN LATERAL aclexplode(coalesce(c.relacl, acldefault('r', c.relowner))) acl
    WHERE n.nspname = 'public'
      AND c.relname IN ('consents', 'cycle_data', 'email_preferences', 'profiles', 'daily_plan')
      AND acl.grantee = 0
      AND acl.privilege_type IN ('SELECT', 'TRUNCATE')
  ), 'PUBLIC must not have SELECT/TRUNCATE on sensitive tables';
END $$;

-- Grants: authenticated must not have TRUNCATE/TRIGGER/REFERENCES/MAINTAIN on sensitive tables.
DO $$
BEGIN
  ASSERT NOT has_table_privilege('authenticated', 'public.profiles', 'TRUNCATE'),
    'authenticated must not have TRUNCATE on public.profiles';
  ASSERT NOT has_table_privilege('authenticated', 'public.consents', 'TRUNCATE'),
    'authenticated must not have TRUNCATE on public.consents';
  ASSERT NOT has_table_privilege('authenticated', 'public.cycle_data', 'TRUNCATE'),
    'authenticated must not have TRUNCATE on public.cycle_data';
  ASSERT NOT has_table_privilege('authenticated', 'public.email_preferences', 'TRUNCATE'),
    'authenticated must not have TRUNCATE on public.email_preferences';
  ASSERT NOT has_table_privilege('authenticated', 'public.daily_plan', 'TRUNCATE'),
    'authenticated must not have TRUNCATE on public.daily_plan';

  ASSERT NOT has_table_privilege('authenticated', 'public.consents', 'TRIGGER'),
    'authenticated must not have TRIGGER on public.consents';
  ASSERT NOT has_table_privilege('authenticated', 'public.cycle_data', 'TRIGGER'),
    'authenticated must not have TRIGGER on public.cycle_data';
  ASSERT NOT has_table_privilege('authenticated', 'public.email_preferences', 'TRIGGER'),
    'authenticated must not have TRIGGER on public.email_preferences';
  ASSERT NOT has_table_privilege('authenticated', 'public.profiles', 'TRIGGER'),
    'authenticated must not have TRIGGER on public.profiles';
  ASSERT NOT has_table_privilege('authenticated', 'public.daily_plan', 'TRIGGER'),
    'authenticated must not have TRIGGER on public.daily_plan';

  ASSERT NOT has_table_privilege('authenticated', 'public.consents', 'REFERENCES'),
    'authenticated must not have REFERENCES on public.consents';
  ASSERT NOT has_table_privilege('authenticated', 'public.cycle_data', 'REFERENCES'),
    'authenticated must not have REFERENCES on public.cycle_data';
  ASSERT NOT has_table_privilege('authenticated', 'public.email_preferences', 'REFERENCES'),
    'authenticated must not have REFERENCES on public.email_preferences';
  ASSERT NOT has_table_privilege('authenticated', 'public.profiles', 'REFERENCES'),
    'authenticated must not have REFERENCES on public.profiles';
  ASSERT NOT has_table_privilege('authenticated', 'public.daily_plan', 'REFERENCES'),
    'authenticated must not have REFERENCES on public.daily_plan';

  ASSERT NOT has_table_privilege('authenticated', 'public.consents', 'MAINTAIN'),
    'authenticated must not have MAINTAIN on public.consents';
  ASSERT NOT has_table_privilege('authenticated', 'public.cycle_data', 'MAINTAIN'),
    'authenticated must not have MAINTAIN on public.cycle_data';
  ASSERT NOT has_table_privilege('authenticated', 'public.email_preferences', 'MAINTAIN'),
    'authenticated must not have MAINTAIN on public.email_preferences';
  ASSERT NOT has_table_privilege('authenticated', 'public.profiles', 'MAINTAIN'),
    'authenticated must not have MAINTAIN on public.profiles';
  ASSERT NOT has_table_privilege('authenticated', 'public.daily_plan', 'MAINTAIN'),
    'authenticated must not have MAINTAIN on public.daily_plan';

  -- Append-only: authenticated must not be able to mutate/delete consent audit records.
  ASSERT NOT has_table_privilege('authenticated', 'public.consents', 'UPDATE'),
    'authenticated must not have UPDATE on public.consents (append-only)';
  ASSERT NOT has_table_privilege('authenticated', 'public.consents', 'DELETE'),
    'authenticated must not have DELETE on public.consents (append-only)';
END $$;

-- NOTE: The following RLS policy scope check uses string-matching heuristics
-- (position('auth.uid()' in ...) to detect owner-scoped policies. This is a
-- best-effort smoke test with known limitations: spacing, parentheses, aliases,
-- or functionally equivalent expressions may bypass detection. Deeper security
-- audits should not rely solely on this check.
-- RLS: consents must remain owner-scoped and append-only.
DO $$
BEGIN
  ASSERT NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'consents'
      AND cmd IN ('UPDATE', 'DELETE')
  ), 'consents must not have UPDATE/DELETE policies (append-only)';

  ASSERT NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'consents'
      AND cmd IN ('SELECT', 'INSERT')
      AND (
        (cmd = 'SELECT' AND (qual IS NULL OR position('auth.uid()' in lower(qual)) = 0))
        OR (cmd = 'INSERT' AND (with_check IS NULL OR position('auth.uid()' in lower(with_check)) = 0))
      )
  ), 'consents SELECT/INSERT policies must scope to auth.uid()';
END $$;

-- 0) Ohne Kontext: keine Sicht
SET ROLE authenticated;
SELECT COUNT(*) = 0 AS rls_blocks FROM public.consents;
DO $$
DECLARE
  rls_blocks boolean;
BEGIN
  SELECT COUNT(*) = 0 INTO rls_blocks FROM public.consents;
  ASSERT rls_blocks, 'consents baseline must return zero rows without context';
END $$;

-- 1) Owner-Kontext simulieren
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', :'test_user_id', 'role', 'authenticated')::text,
  false
);
INSERT INTO public.consents (id, user_id, scopes, version)
VALUES (
  '00000000-0000-0000-0000-00000000c001',
  (SELECT auth.uid()),
  DEFAULT,
  'rls-smoke'
)
ON CONFLICT (id) DO NOTHING;
DO $$
DECLARE
  default_def text;
  has_constraint boolean;
  row_is_ok boolean;
  rpc_allowed boolean;
  rpc_allowed_legacy boolean;
BEGIN
  SELECT column_default INTO default_def
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'consents'
    AND column_name = 'scopes';
  ASSERT default_def = '''{}''::jsonb',
    'consents.scopes default must be ''{}''::jsonb (canonical object)';

  SELECT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND t.relname = 'consents'
      AND c.conname = 'consents_scopes_is_object_bool'
  ) INTO has_constraint;
  ASSERT has_constraint, 'consents_scopes_is_object_bool constraint must exist';

  SELECT jsonb_typeof(scopes) = 'object' AND scopes = '{}'::jsonb
  INTO row_is_ok
  FROM public.consents
  WHERE id = '00000000-0000-0000-0000-00000000c001';
  ASSERT row_is_ok, 'consents.scopes must default to an empty JSONB object';

  SELECT public.log_consent_if_allowed(
    (SELECT auth.uid()),
    'rls-smoke',
    '{"terms": true}'::jsonb,
    1,
    1000
  ) INTO rpc_allowed;
  ASSERT rpc_allowed, 'log_consent_if_allowed must accept canonical JSONB object scopes';

  -- Backward compatibility: legacy array format is still accepted and normalized.
  SELECT public.log_consent_if_allowed(
    (SELECT auth.uid()),
    'rls-smoke',
    '["terms"]'::jsonb,
    1,
    1000
  ) INTO rpc_allowed_legacy;
  ASSERT rpc_allowed_legacy, 'log_consent_if_allowed must accept legacy JSONB array scopes';
END $$;
SELECT COUNT(*) >= 1 AS rls_allows
FROM public.consents
WHERE user_id = (SELECT auth.uid());
DO $$
DECLARE
  rls_allows boolean;
BEGIN
  SELECT COUNT(*) >= 1 INTO rls_allows
  FROM public.consents
  WHERE user_id = (SELECT auth.uid());
  ASSERT rls_allows, 'consents owner context must allow querying own rows';
END $$;

-- 2) WITH CHECK muss falschen Owner blocken (erwarteter Fehler)
-- HINWEIS: Diesen Block optional separat in dev ausführen, da Fehler den Lauf abbricht.
-- INSERT INTO public.consents (user_id, scopes, version)
-- VALUES ('11111111-1111-1111-1111-111111111111', '[]'::jsonb, 'v1');

-- 3) cycle_data: baseline ohne Kontext & Owner-Kontext
RESET ROLE; RESET ALL;
SET ROLE authenticated;
SELECT COUNT(*) = 0 AS rls_blocks FROM public.cycle_data;
DO $$
DECLARE
  rls_blocks boolean;
BEGIN
  SELECT COUNT(*) = 0 INTO rls_blocks FROM public.cycle_data;
  ASSERT rls_blocks, 'cycle_data baseline must return zero rows without context';
END $$;

SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', :'test_user_id', 'role', 'authenticated')::text,
  false
);
INSERT INTO public.cycle_data (
  user_id,
  cycle_length,
  period_duration,
  last_period,
  age
)
VALUES (
  (SELECT auth.uid()),
  20,
  15,
  '2025-01-01',
  25
)
ON CONFLICT (user_id) DO UPDATE
SET cycle_length = EXCLUDED.cycle_length,
    period_duration = EXCLUDED.period_duration,
    last_period = EXCLUDED.last_period,
    age = EXCLUDED.age;
SELECT COUNT(*) >= 1 AS rls_allows
FROM public.cycle_data
WHERE user_id = (SELECT auth.uid());
DO $$
DECLARE
  rls_allows boolean;
BEGIN
  SELECT COUNT(*) >= 1 INTO rls_allows
  FROM public.cycle_data
  WHERE user_id = (SELECT auth.uid());
  ASSERT rls_allows, 'cycle_data owner context must allow querying own rows';
END $$;

-- 4) email_preferences: baseline ohne Kontext & Owner-Kontext
RESET ROLE; RESET ALL;
SET ROLE authenticated;
SELECT COUNT(*) = 0 AS rls_blocks FROM public.email_preferences;
DO $$
DECLARE
  rls_blocks boolean;
BEGIN
  SELECT COUNT(*) = 0 INTO rls_blocks FROM public.email_preferences;
  ASSERT rls_blocks, 'email_preferences baseline must return zero rows without context';
END $$;

SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', :'test_user_id', 'role', 'authenticated')::text,
  false
);
INSERT INTO public.email_preferences (id, user_id, newsletter)
VALUES (
  '00000000-0000-0000-0000-00000000c003',
  (SELECT auth.uid()),
  false
)
ON CONFLICT (user_id) DO UPDATE
SET newsletter = EXCLUDED.newsletter;
SELECT COUNT(*) >= 1 AS rls_allows
FROM public.email_preferences
WHERE user_id = (SELECT auth.uid());
DO $$
DECLARE
  rls_allows boolean;
BEGIN
  SELECT COUNT(*) >= 1 INTO rls_allows
  FROM public.email_preferences
  WHERE user_id = (SELECT auth.uid());
  ASSERT rls_allows, 'email_preferences owner context must allow querying own rows';
END $$;

-- 5) profiles: baseline ohne Kontext & Owner-Kontext
RESET ROLE; RESET ALL;
SET ROLE authenticated;
SELECT COUNT(*) = 0 AS rls_blocks FROM public.profiles;
DO $$
DECLARE
  rls_blocks boolean;
BEGIN
  SELECT COUNT(*) = 0 INTO rls_blocks FROM public.profiles;
  ASSERT rls_blocks, 'profiles baseline must return zero rows without context';
END $$;

SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub', :'test_user_id', 'role', 'authenticated')::text,
  false
);
INSERT INTO public.profiles (
  user_id,
  display_name,
  birth_date,
  fitness_level,
  goals,
  interests,
  has_seen_welcome,
  has_completed_onboarding,
  accepted_consent_version,
  onboarding_completed_at
)
VALUES (
  (SELECT auth.uid()),
  'rls-smoke',
  '1990-01-01',
  'beginner',
  '[]'::jsonb,
  '[]'::jsonb,
  true,
  true,
  1,
  now()
)
ON CONFLICT (user_id) DO UPDATE
SET display_name = EXCLUDED.display_name,
    birth_date = EXCLUDED.birth_date,
    fitness_level = EXCLUDED.fitness_level,
    goals = EXCLUDED.goals,
    interests = EXCLUDED.interests,
    has_seen_welcome = EXCLUDED.has_seen_welcome,
    has_completed_onboarding = EXCLUDED.has_completed_onboarding,
    accepted_consent_version = EXCLUDED.accepted_consent_version,
    onboarding_completed_at = EXCLUDED.onboarding_completed_at;
SELECT accepted_consent_at IS NOT NULL AS accepted_consent_at_set
FROM public.profiles
WHERE user_id = (SELECT auth.uid());
DO $$
DECLARE
  accepted_consent_at_set boolean;
BEGIN
  SELECT accepted_consent_at IS NOT NULL INTO accepted_consent_at_set
  FROM public.profiles
  WHERE user_id = (SELECT auth.uid());
  ASSERT accepted_consent_at_set,
    'profiles.accepted_consent_at must be set server-side when consent version is written';
END $$;
SELECT COUNT(*) = 1 AS rls_allows
FROM public.profiles
WHERE user_id = (SELECT auth.uid());
DO $$
DECLARE
  rls_allows boolean;
BEGIN
  SELECT COUNT(*) = 1 INTO rls_allows
  FROM public.profiles
  WHERE user_id = (SELECT auth.uid());
  ASSERT rls_allows, 'profiles owner context must allow querying own row';
END $$;
