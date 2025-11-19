# log_consent Deployment & Monitoring Guide

Dieser Leitfaden bündelt Env-Variablen, Deployment-Schritte, Smoke-Tests und Monitoring-Hinweise für die Supabase-Edge-Funktion `log_consent`. Die JSON-SSOT unter `config/consent_scopes.json` sowie Backend-/Flutter-Quellen bleiben unverändert; hier geht es ausschließlich um Ops-Prozesse.

## 1. Environment-Variablen (Start-Check)

| Variable | Zweck | Anforderungen / Hinweise |
| --- | --- | --- |
| `SUPABASE_URL` | Basis-URL des Projekts für `createClient`. | Pflicht – Funktion schlägt beim Start mit *Missing required environment variable* fehl, wenn unset. |
| `SUPABASE_ANON_KEY` | Public API Key für Authentifizierung gegen Supabase. | Pflicht – fehlender Key führt zu Startfehler. |
| `CONSENT_METRIC_SALT` | Optionales Salt zum Pseudonymisieren von Consent-/User-IDs in Logs. | Empfohlen in Prod; leer = unsalted Hash. |
| `CONSENT_HASH_PEPPER` | Optionaler HMAC-Pepper für UA-/IP-Hashes. | Falls nicht gesetzt, wird `CONSENT_METRIC_SALT` genutzt; leer = reines SHA-256. |
| `CONSENT_RATE_LIMIT_WINDOW_SEC` | Sliding Window für Rate-Limit. | Muss Integer 1–3600 sein; sonst `CONSENT_RATE_LIMIT_WINDOW_SEC must be between 1 and 3600`. |
| `CONSENT_RATE_LIMIT_MAX_REQUESTS` | Requests pro Window. | Muss Integer 1–1000 sein; sonst `CONSENT_RATE_LIMIT_MAX_REQUESTS must be between 1 and 1000`. |
| `CONSENT_ALERT_SAMPLE_RATE` | Sampling für Alerts/Monitoring. | Muss endlich (Float/String parsable) sein; Standard 0.1. Funktion klemmt auf [0,1], wirft beim Start `CONSENT_ALERT_SAMPLE_RATE must be a finite number between 0 and 1`, wenn Wert nicht numerisch ist. Wertebereichsempfehlung: 0.1–0.2 für Dev/Staging; Prod nach Bedarf justieren. |

> **Praxis:** Vor jedem Deploy in Dev/Staging/Prod im Supabase Dashboard (Project Settings → Functions → Environment Variables) oder via Management-API verifizieren. Keine Secrets in Git einchecken.

## 2. Deployment (CLI-Beispiele)

Vorbereitung:
- `supabase login` (falls CLI noch nicht authorisiert).
- `.supabase/config.toml` bzw. `--project-ref` Parameter kennen.
- Env-Variablen gemäß Tabelle setzen/prüfen.

Beispiel-Kommandos (Templates – `<...>` anpassen):

```bash
# Dev
supabase functions deploy log_consent --project-ref <DEV_PROJECT_REF>

# Staging
supabase functions deploy log_consent --project-ref <STAGE_PROJECT_REF>

# Prod (nur nach Freigabe & Smoke-Test in Staging)
supabase functions deploy log_consent --project-ref <PROD_PROJECT_REF>
```

Hinweise:
- Vor Deploy sicherstellen, dass `scripts/flutter_codex.sh analyze` + `scripts/flutter_codex.sh test -j 1` lokal grün waren und Deno-Tests (`deno test supabase/functions/log_consent/consent_scopes_ssot.test.ts`) laufen konnten.
- Nach Deploy ist der Endpoint unter `https://<PROJECT_REF>.functions.supabase.co/log_consent` erreichbar (HTTPS, POST).

## 3. Smoke-Tests (manuell)

Alle Beispiele ersetzen `<PROJECT_REF>`/Tokens durch reale Werte. Access Token kann z. B. via `supabase auth signin` oder App generiert werden.

1. **Happy Path**
   ```bash
   curl -i https://<PROJECT_REF>.functions.supabase.co/log_consent \
     -H "Authorization: Bearer <USER_ACCESS_TOKEN>" \
     -H "Content-Type: application/json" \
     -d '{
       "version": "v1-test",
       "scopes": ["terms", "health_processing"],
       "source": "dev-smoketest",
       "appVersion": "1.0.0-test"
     }'
   ```
   Erwartet: `201` + `{"ok":true,"request_id":"..."}`.

2. **Ungültige Scopes**
   ```bash
   curl -i https://<PROJECT_REF>.functions.supabase.co/log_consent \
     -H "Authorization: Bearer <USER_ACCESS_TOKEN>" \
     -H "Content-Type: application/json" \
     -d '{"version":"v1-test","scopes":["terms","foo"]}'
   ```
   Erwartet: `400` + `{"error":"Invalid scopes provided","invalidScopes":["foo"]}`.

3. **Fehlende Scopes**
   ```bash
   curl -i https://<PROJECT_REF>.functions.supabase.co/log_consent \
     -H "Authorization: Bearer <USER_ACCESS_TOKEN>" \
     -H "Content-Type: application/json" \
     -d '{"version":"v1-test","scopes":[]}'
   ```
   Erwartet: `400` + Meldung `scopes must be a non-empty array`.

4. **Objekt-Scopes**
   ```bash
   curl -i https://<PROJECT_REF>.functions.supabase.co/log_consent \
     -H "Authorization: Bearer <USER_ACCESS_TOKEN>" \
     -H "Content-Type: application/json" \
     -d '{
       "version":"v1-test",
       "scopes":{"terms":true,"health_processing":true},
       "source":"dev-object"
     }'
   ```
   Erwartet: `201` sofern Keys valide; bei komplett leeren/false-Werten → `400` wie oben.

> Alle Requests verwenden Test-/Staging-Tokens; keine Prod-Daten ohne Freigabe senden.

## 4. Monitoring nach Deploy

- **Supabase Dashboard → Logs**: Filter auf Events `consent_log`, `consent_alert_failed`, `consent_rpc_failed`.
- Warnsignale:
  - Häufung von `400` mit `reason: invalid_scopes` oder `missing_scopes` → Client-Drift prüfen.
  - Startfehler/Crash mit Meldung zu `CONSENT_ALERT_SAMPLE_RATE` → Env sofort korrigieren.
  - Rate-Limit-Warnungen (`rate_limited`) → ggf. Fenster/MaxRequests anpassen.
- **CLI-Template** (falls verfügbar):
  ```bash
  supabase functions logs log_consent \
    --project-ref <PROJECT_REF> \
    --since 1h
  ```
- Empfehlung: Zuerst Dev/Staging beobachten (mindestens 24h), dann Prod umstellen. Alerts (Slack/Webhook) sollten denselben Env-Set nutzen.

