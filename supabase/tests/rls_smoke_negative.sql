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
    'rls_smoke_negative.sql benötigt einen auth.users-Datensatz für 00000000-0000-0000-0000-000000000000';
END $$;

SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000000000','role','authenticated')::text,
  true
);

-- Anti-Drift: consents.scopes must reject legacy object-map format.
DO $$
BEGIN
  BEGIN
    INSERT INTO public.consents (user_id, scopes, version)
    VALUES ((SELECT auth.uid()), '{}'::jsonb, 'rls-smoke-negative');
    RAISE EXCEPTION 'Expected CHECK violation: consents.scopes must be a JSONB array';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN others THEN
      RAISE EXCEPTION 'Expected check_violation (23514), got % (%).', SQLERRM, SQLSTATE;
  END;
END $$;
