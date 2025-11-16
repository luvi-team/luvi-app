\set ON_ERROR_STOP on
SET LOCAL ROLE authenticated;
SELECT set_config(
  'request.jwt.claims',
  json_build_object('sub','00000000-0000-0000-0000-000000000000','role','authenticated')::text,
  true
);
-- Sollte FEHLERN (falscher Owner)
INSERT INTO public.consents (user_id, scopes, version)
VALUES ('11111111-1111-1111-1111-111111111111','{}'::jsonb,'v1');
