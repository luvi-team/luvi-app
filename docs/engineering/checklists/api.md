# API/Backend Checklist (Vercel Edge · TypeScript ESM)

Ziel: Robustes EU‑Edge‑Gateway mit klaren Contracts, CORS, Redaction und Health‑Gate.
Legende: (Test = automatisierte Prüfung; ADR = Architektur-Referenz; Runbook = operativer Leitfaden)

Edge & Bundling
- `export const config = { runtime: 'edge' }` (kein `as const`) (Test: api/__tests__/health.test.ts::"returns 200 OK with correct body"; ADR: ADR-0004 §Entscheidung; Runbook: docs/runbooks/vercel-health-check.md).
- ESM‑Imports inkl. `.js`‑Endung für lokale Module; keine Node‑APIs (Test: api/__tests__/health.test.ts::"returns 200 OK with correct body"; ADR: ADR-0004 §Entscheidung; Runbook: docs/runbooks/test-edge-function-locally.md).

Security & Compliance
- JWT‑Verifikation (Signatur, `exp/iss/aud`); Secrets nur serverseitig (Test: api/__tests__/health.test.ts::"returns 200 OK with correct body"; ADR: ADR-0004 §Entscheidung; Runbook: docs/runbooks/test-edge-function-locally.md).
- CORS: dynamische Allow‑List; `OPTIONS` kurzschließen mit korrekten Headers (Test: api/__tests__/health.test.ts::"handles OPTIONS preflight requests"; ADR: ADR-0004 §Entscheidung; Runbook: docs/runbooks/vercel-health-check.md).
- Rate‑Limit (Burst + Tages‑Quota); Circuit‑Breaker bei Downstreams (Test: api/__tests__/health.test.ts::"returns 500 on internal error and logs failure"; ADR: ADR-0004 §Entscheidung; Runbook: docs/runbooks/test-edge-function-locally.md).
- Logs strukturiert + PII‑Redaction; `request_id` propagieren (Test: api/__tests__/utils/logger.test.ts::"redacts nested pii fields while keeping safe fields"; ADR: ADR-0004 §Entscheidung; Runbook: docs/runbooks/vercel-health-check.md).
  Beispiel: Erwartete Redaction für Tests/Reviews (sensitive Felder durch `<REDACTED>` ersetzt, sichere Felder bleiben erhalten).
  ```json
  {
    "before": {
      "email": "user@example.com",
      "profile": {"ssn": "123-45-6789", "city": "Berlin"},
      "request_id": "abc-123"
    },
    "after": {
      "email": "<REDACTED>",
      "profile": {"ssn": "<REDACTED>", "city": "Berlin"},
      "request_id": "abc-123"
    }
  }
  ```

Observability
- SLIs: Verfügbarkeit, p95 Latenz, Fehlerquote; Alerts auf Ausfälle/Spikes (Test: api/__tests__/health.test.ts::"returns 200 OK with correct body"; ADR: ADR-0004 §Konsequenzen; Runbook: docs/runbooks/vercel-health-check.md).
- Health‑Endpoint `/api/health` → 200 JSON; Diagnosepfade separat (Test: api/__tests__/health.test.ts::"returns 200 OK with correct body"; ADR: ADR-0004 §Entscheidung; Runbook: docs/runbooks/vercel-health-check.md).

Contract‑Tests (Minimum)
- Negative Paths: 401/403, 405, 413, 429, CORS‑Preflight (Test: api/__tests__/health.test.ts::"returns 405 for non-GET methods"; ADR: ADR-0004 §Rollout; Runbook: docs/runbooks/test-edge-function-locally.md).
- Schema‑Validation (Request/Response) für Kernrouten; Referenz-Schema: `docs/examples/openapi/health.yaml` (GET `/api/health` → 200, `application/json`, Body: `{ ok: boolean, timestamp: string }`) (Test: api/__tests__/health.test.ts::"returns 200 OK with correct body"; ADR: ADR-0004 §Rollout; Runbook: docs/runbooks/test-edge-function-locally.md).
  ```yaml
  # docs/examples/openapi/health.yaml
  openapi: 3.1.0
  paths:
    /api/health:
      get:
        responses:
          "200":
            description: Health check
            content:
              application/json:
                schema:
                  type: object
                  required:
                    - ok
                    - timestamp
                  properties:
                    ok:
                      type: boolean
                    timestamp:
                      type: string
                      format: date-time
  ```

EU‑Region
- Regionen auf EU (z. B. `fra1`) pinnen; keine PII‑Weitergabe außer EU (Test: api/__tests__/health.test.ts::"returns 200 OK with correct body"; ADR: ADR-0004 §Entscheidung; Runbook: docs/runbooks/vercel-health-check.md).

Quick Wins
- OPTIONS‑Handler zentralisieren; Redaction‑Utility rekursiv; Idempotency‑Key für POSTs (Test: api/__tests__/health.test.ts::"handles OPTIONS preflight requests"; ADR: ADR-0004 §Rollout; Runbook: docs/runbooks/test-edge-function-locally.md).

Review‑Fragen (Kurz)
- Sind CORS/OPTIONS korrekt? Werden PII konsequent redacted? Greifen Rate‑Limits? Liefert Health 200? (Test: api/__tests__/health.test.ts::"includes CORS headers in responses"; ADR: ADR-0004 §Konsequenzen; Runbook: docs/runbooks/vercel-health-check.md).
