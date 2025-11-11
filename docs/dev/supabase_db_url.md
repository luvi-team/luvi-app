# Supabase DB URLs
Supabase DB URLs benötigen percent-encodete Passwörter, sobald Sonderzeichen vorkommen.
Encoden lokal: `node scripts/urlencode_password.mjs '<PLAINTEXT>'` und die Ausgabe unverändert übernehmen.
DB-URL-Template: `postgres://<user>:<encoded-password>@<host>:<port>/<database>?sslmode=require`.
Speichere die fertige URL als Secret wie `SUPABASE_DB_URL_DEV`, niemals den Klartext.
Für lokale Tests kannst du denselben Wert temporär in `.env` übernehmen; CI nutzt automatisch das Secret.
