# Supabase DB URLs
Supabase DB URLs benötigen percent-encodete Passwörter, sobald Sonderzeichen vorkommen.
Encoden lokal: `node scripts/urlencode_password.mjs '<PLAINTEXT>'` und die Ausgabe unverändert übernehmen.
DB-URL-Template: `postgres://<user>:<encoded-password>@<host>:<port>/<database>?sslmode=require`.
Speichere die fertige URL als Secret wie `SUPABASE_DB_URL_DEV`, niemals den Klartext.
Für lokale Tests kannst du denselben Wert temporär in `.env` übernehmen; CI nutzt automatisch das Secret.

## log_consent Deno Contract Tests
- Starten: `deno test --allow-env --allow-net --allow-read supabase/tests/log_consent.test.ts`
  - Verwende `LOG_CONSENT_FUNCTION_URL` nur wenn du nicht den Standard-Endpunkt `SUPABASE_URL/functions/v1/log_consent` testen kannst.
- Pflicht-Umgebung für lokale Läufe (per `.env` oder Shell-Export, niemals einchecken):
  - `SUPABASE_URL` (lokal oft `http://127.0.0.1:54321`, ansonsten deine Dev-Instanz)
  - `SUPABASE_ANON_KEY` (Public-Anon-Key deiner Instanz)
  - optional `SUPABASE_SERVICE_ROLE_KEY` falls der Test-User noch erstellt werden muss.
- Test-Creds (`LOG_CONSENT_TEST_EMAIL`, `LOG_CONSENT_TEST_PASSWORD`) greifen sonst auf die Defaults `log-consent-contract@example.com` / `Testpass123!` zurück.
- Lege echte Keys/Passwörter ausschließlich in lokale `.env`-Dateien oder Secrets ab (`.env*` ist per `.gitignore` geschützt); Prüfläufe in CI beziehen sie aus Repository-Secrets.
