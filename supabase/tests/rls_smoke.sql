\set ON_ERROR_STOP on
RESET ROLE;
RESET ALL;

-- Fixture-Prüfung: auth.users muss Test-User enthalten
DO $$
DECLARE
  has_user boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM auth.users WHERE id = '00000000-0000-0000-0000-000000000000'
  )
  INTO has_user;
  ASSERT has_user,
    'rls_smoke.sql benötigt einen auth.users-Datensatz für 00000000-0000-0000-0000-000000000000';
END $$;

-- 0) Ohne Kontext: keine Sicht
SELECT COUNT(*) = 0 AS rls_blocks FROM public.consents;
DO $$
DECLARE
  rls_blocks boolean;
BEGIN
  SELECT COUNT(*) = 0 INTO rls_blocks FROM public.consents;
  ASSERT rls_blocks, 'consents baseline must return zero rows without context';
END $$;

-- 1) Owner-Kontext simulieren
SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000000000','role','authenticated')::text,
  true
);
INSERT INTO public.consents (id, user_id, scopes, version)
VALUES (
  '00000000-0000-0000-0000-00000000c001',
  (SELECT auth.uid()),
  '{}'::jsonb,
  'rls-smoke'
)
ON CONFLICT (id) DO UPDATE
SET user_id = EXCLUDED.user_id,
    scopes = EXCLUDED.scopes,
    version = EXCLUDED.version;
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
-- VALUES ('11111111-1111-1111-1111-111111111111', '{}'::jsonb, 'v1');

-- 3) cycle_data: baseline ohne Kontext & Owner-Kontext
RESET ROLE; RESET ALL;
SELECT COUNT(*) = 0 AS rls_blocks FROM public.cycle_data;
DO $$
DECLARE
  rls_blocks boolean;
BEGIN
  SELECT COUNT(*) = 0 INTO rls_blocks FROM public.cycle_data;
  ASSERT rls_blocks, 'cycle_data baseline must return zero rows without context';
END $$;

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000000000','role','authenticated')::text,
  true
);
INSERT INTO public.cycle_data (
  id,
  user_id,
  cycle_length,
  period_duration,
  last_period,
  age
)
VALUES (
  '00000000-0000-0000-0000-00000000c002',
  (SELECT auth.uid()),
  28,
  5,
  '2025-01-01',
  25
)
ON CONFLICT (id) DO UPDATE
SET user_id = EXCLUDED.user_id,
    cycle_length = EXCLUDED.cycle_length,
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
SELECT COUNT(*) = 0 AS rls_blocks FROM public.email_preferences;
DO $$
DECLARE
  rls_blocks boolean;
BEGIN
  SELECT COUNT(*) = 0 INTO rls_blocks FROM public.email_preferences;
  ASSERT rls_blocks, 'email_preferences baseline must return zero rows without context';
END $$;

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000000000','role','authenticated')::text,
  true
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
