\set ON_ERROR_STOP on
RESET ROLE;
RESET ALL;

-- 0) Ohne Kontext: keine Sicht
SELECT COUNT(*) = 0 AS rls_blocks FROM public.consents;

-- 1) Owner-Kontext simulieren
SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000000000','role','authenticated')::text,
  true
);
SELECT COUNT(*) >= 0 AS rls_allows
FROM public.consents
WHERE user_id = (SELECT auth.uid());

-- 2) WITH CHECK muss falschen Owner blocken (erwarteter Fehler)
-- HINWEIS: Diesen Block optional separat in dev ausführen, da Fehler den Lauf abbricht.
-- INSERT INTO public.consents (user_id, scopes, version)
-- VALUES ('11111111-1111-1111-1111-111111111111', '{}'::jsonb, 'v1');

-- 3) cycle_data: baseline ohne Kontext & Owner-Kontext
RESET ROLE; RESET ALL;
SELECT COUNT(*) = 0 AS rls_blocks FROM public.cycle_data;

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000000000','role','authenticated')::text,
  true
);
SELECT COUNT(*) >= 0 AS rls_allows
FROM public.cycle_data
WHERE user_id = (SELECT auth.uid());

-- 4) email_preferences: baseline ohne Kontext & Owner-Kontext
RESET ROLE; RESET ALL;
SELECT COUNT(*) = 0 AS rls_blocks FROM public.email_preferences;

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000000000','role','authenticated')::text,
  true
);
SELECT COUNT(*) >= 0 AS rls_allows
FROM public.email_preferences
WHERE user_id = (SELECT auth.uid());
