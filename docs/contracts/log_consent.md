# log_consent Edge Function — Contract v1

Zweck: Definiert den aktuellen Request/Response-Contract der Supabase Edge Function `log_consent` für Consent-Logging ohne PII-Leckagen.

## Request
- **HTTP**: `POST {SUPABASE_URL}/functions/v1/log_consent`
- **Headers**:
  - `Authorization: Bearer <Supabase access token>` (erforderlich; wird via `supabase.auth.getUser()` verifiziert)
  - `apikey: <SUPABASE_ANON_KEY>` (required für Functions-Gateway)
  - `Content-Type: application/json`
- **Body (JSON)**:
  - `policy_version` (string, Pflicht) · Alias `version` wird akzeptiert
  - `scopes` (object, Pflicht) · Canonical: JSON-Objekt mit boolean-flags `{ "<scope_id>": true, ... }`
    - Legacy (MVP-Compat): `string[]` wird akzeptiert, wird serverseitig in das Objekt-Format normalisiert
    - Erlaubte Scope-IDs: `terms | health_processing | analytics | marketing | ai_journal | model_training`
  - `source` (string, optional) · Herkunft der Einwilligung (z.B. `contract-test`, `onboarding`)
  - `appVersion` (string, optional) · Client-Build zur Metrik-Korrelation
- `user_id` wird nie übergeben, sondern aus dem JWT (`auth.getUser()`) gelesen.

## Erfolgsresponse
- **Status** `201 Created`
- **Body**: `{ "ok": true, "request_id": "<uuid>" }`
- **Headers**: `X-Request-Id` spiegelt dieselbe ID und erlaubt Log-Korrelation.

## Fehlerfälle
| Status | Auslöser | Response |
| --- | --- | --- |
| 405 | Methode ≠ `POST` | `{ "error": "Method not allowed", "request_id": "<uuid>" }` + `X-Request-Id` |
| 401 | `Authorization` fehlt oder Token ungültig | `{ "error": "Missing Authorization header", "request_id": "<uuid>" }` bzw. `{ "error": "Unauthorized", "request_id": "<uuid>" }` |
| 400 | Invalides JSON, `policy_version` fehlt, `scopes` leer/invalid oder enthält unbekannte Werte | `{ "error": "Invalid request body", "request_id": "<uuid>" }`, `{ "error": "policy_version is required", "request_id": "<uuid>" }`, `{ "error": "scopes must be provided", "request_id": "<uuid>" }`, `{ "error": "scopes must be non-empty", "request_id": "<uuid>" }`, bzw. `{ "error": "Invalid scopes provided", "invalidScopes": [...], "request_id": "<uuid>" }` |
| 429 | Sliding-Window-Limit verletzt (`CONSENT_RATE_LIMIT_WINDOW_SEC`/`CONSENT_RATE_LIMIT_MAX_REQUESTS`, Default 60s/20 Requests pro Nutzer) | `{ "error": "Rate limit exceeded", "request_id": "<uuid>" }` + `Retry-After`, `X-RateLimit-Limit`, `X-RateLimit-Remaining=0` |
| 500 | RPC `log_consent_if_allowed` liefert Fehler | `{ "error": "Failed to log consent", "request_id": "<uuid>" }` |

Alle Fehler enthalten mindestens ein `error`-Feld, immer ein `request_id`-Feld und teilen sich den `X-Request-Id`-Header zur Log-Korrelation (Client kann `request_id` aus dem JSON nutzen, falls Header nicht zugreifbar ist).

## Hinweise
- Rate-Limiting erfolgt per Postgres-RPC inkl. Advisory-Lock, damit mehrere Einreichungen in derselben Sekunde atomar bewertet werden.
- IP/UA werden vor Logging auf `/24` bzw. `/64` normalisiert und via HMAC-SHA256 (`CONSENT_HASH_PEPPER`) oder unsalted SHA-256 pseudonymisiert → siehe `docs/privacy/hmac_hashing_controls.md`.
- `source`/`appVersion` landen ausschließlich in Observability-Logs; Consent-Inserts speichern nur `user_id`, `version`, `scopes`.
- Alerts (`CONSENT_ALERT_WEBHOOK_URL`) feuern bei Fehlern bzw. Rate-Limit-Exzessen (Sampling via `CONSENT_ALERT_SAMPLE_RATE`).
- Contract ist durch `supabase/tests/log_consent.test.ts` abgesichert und spiegelt denselben Scope/Status-Kanon wider.

## Referenzen
- `supabase/functions/log_consent/index.ts`
- `supabase/tests/log_consent.test.ts`
- `docs/runbooks/verify-consent-flow.md`
- `docs/privacy/hmac_hashing_controls.md`
