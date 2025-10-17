# API/Backend Checklist (Vercel Edge · TypeScript ESM)

Ziel: Robustes EU‑Edge‑Gateway mit klaren Contracts, CORS, Redaction und Health‑Gate.

Edge & Bundling
- `export const config = { runtime: 'edge' }` (kein `as const`).
- ESM‑Imports inkl. `.js`‑Endung für lokale Module; keine Node‑APIs.

Security & Compliance
- JWT‑Verifikation (Signatur, `exp/iss/aud`); Secrets nur serverseitig.
- CORS: dynamische Allow‑List; `OPTIONS` kurzschließen mit korrekten Headers.
- Rate‑Limit (Burst + Tages‑Quota); Circuit‑Breaker bei Downstreams.
- Logs strukturiert + PII‑Redaction; `request_id` propagieren.

Observability
- SLIs: Verfügbarkeit, p95 Latenz, Fehlerquote; Alerts auf Ausfälle/Spikes.
- Health‑Endpoint `/api/health` → 200 JSON; Diagnosepfade separat.

Contract‑Tests (Minimum)
- Negative Paths: 401/403, 405, 413, 429, CORS‑Preflight.
- Schema‑Validation (Request/Response) für Kernrouten.

EU‑Region
- Regionen auf EU (z. B. `fra1`) pinnen; keine PII‑Weitergabe außer EU.

Quick Wins
- OPTIONS‑Handler zentralisieren; Redaction‑Utility rekursiv; Idempotency‑Key für POSTs.

Review‑Fragen (Kurz)
- Sind CORS/OPTIONS korrekt? Werden PII konsequent redacted? Greifen Rate‑Limits? Liefert Health 200?

