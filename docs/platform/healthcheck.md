# Healthcheck Endpoint Specification

## Endpoint
- **URL:** `/api/health`
- **Method:** `GET`
- **Timeout:** 5 s pro Request
- **Retry:** Max. 3 Retries (zusätzlich zum Initialversuch); Backoff exponentiell (Base‑2): 1 s → 2 s → 4 s
- **Polling-Frequenz (Gate/CI):** alle 5 min

## Response Schema
```json
{
  "status": "ok",
  "checkedAt": "2024-01-01T12:00:00Z",
  "services": {
    "supabase_db": "ok",
    "supabase_auth": "ok",
    "analytics_pipeline": "ok",
    "revenuecat_proxy": "ok",
    "external_apis": "ok"
  }
}
```
- `status`: `ok`, `degraded` oder `down` (Aggregation der Services)
- `services`: gleiche drei Status-Werte pro abhängiger Komponente
- Weitere optionale Felder: `version`, `latencyMs`, `notes`

## Erfolgskriterien
- Gate gilt als bestanden, wenn HTTP 200 + `status = ok` + alle Services ≠ `down`.
- `degraded` löst Warning aber keinen Hard-Fail aus; `down` failt Gate sofort.

## Monitoring
- Ergebnisse werden an Observability-Stack (Grafana/PostHog) gepusht.
- Fehlversuche triggern PagerDuty (Prod) bzw. Slack Alert (Dev/Beta).
- Historie wird 30 Tage aufbewahrt für Audits.
