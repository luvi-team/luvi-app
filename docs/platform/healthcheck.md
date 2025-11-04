# Healthcheck Endpoint Specification

## Endpoint
- **URL:** `/api/health`
- **Method:** `GET`
- **Timeout:** 5 s per request
- **Retry:** Max. 3 retries (in addition to the initial attempt); exponential backoff (base 2): 1 s → 2 s → 4 s
- **Polling frequency (Gate/CI):** every 5 minutes

## Response Schema
```json
{
  "status": "ok",
  "checkedAt": "2024-01-01T12:00:00Z",
  "window": "last_5m",
  "metric": "p95",
  "services": {
    "supabase_db": {
      "status": "ok",
      "response_ms": 180,
      "thresholds": {"ok_lte": 200, "degraded_lte": 1000}
    },
    "supabase_auth": {
      "status": "ok",
      "response_ms": 160,
      "thresholds": {"ok_lte": 200, "degraded_lte": 1000}
    },
    "analytics_pipeline": {
      "status": "ok",
      "response_ms": 220,
      "thresholds": {"ok_lte": 300, "degraded_lte": 1500}
    },
    "revenuecat_proxy": {
      "status": "ok",
      "response_ms": 140,
      "thresholds": {"ok_lte": 250, "degraded_lte": 1200}
    },
    "external_apis": {
      "status": "ok",
      "response_ms": 190,
      "thresholds": {"ok_lte": 300, "degraded_lte": 1500}
    }
  },
  "version": "app-1.0.0",
  "notes": []
}
```
- `status`: `ok`, `degraded`, or `down` (aggregated across services using worst-of logic).
- `services`: per dependent component report with `status`, measured `response_ms` (numeric), and explicit per-service `thresholds`.
- Measurement method: use `p95` latency over the `last_5m` window. If sample size is insufficient, fall back to `p50` (median) or moving average; implementations must state the metric used via the `metric` field.
- Status mapping (default unless overridden by per-service `thresholds`):
  - `ok` if `response_ms` ≤ `ok_lte` and error rate < 5%.
  - `degraded` if `response_ms` ≤ `degraded_lte` or error rate ≥ 5% and < 20%.
  - `down` if `response_ms` > `degraded_lte`, repeated timeouts, or error rate ≥ 20%.

## Success Criteria
- Gate passes when HTTP 200 + `status = ok` and no service is `down`.
- `degraded` raises a warning (no hard fail); `down` fails the Gate immediately.

## Status Transitions
- Hysteresis is required to avoid flapping. Use consecutive check counts/time windows:
  - ok → degraded: threshold exceeded for 2 consecutive checks (or error rate ≥ 5% for 2 checks) or partial feature failure is detected.
  - degraded → ok: 3 consecutive checks back within `ok` thresholds and error rate < 5%.
  - degraded → down: persistent failures after all retries in 2 consecutive checks, repeated timeouts, or p95 exceeding `degraded_lte` for 2 checks.
  - down → degraded: first sustained successful responses below `degraded_lte` for 2 consecutive checks.
  - down → ok: 3 consecutive checks within `ok` thresholds.
- Dependency impact: a `down` dependency forces dependents to at least `degraded`; critical-path dependencies may propagate `down`.
- Retry/backoff: apply the endpoint retry policy above during each check; a single check is `failed` only after retries are exhausted.
- Alerting/escalation: `degraded` → warning/Slack; `down` → page/PagerDuty, with auto-resolve after recovery criteria are met.

## Monitoring
- Results are pushed to the observability stack (Grafana/PostHog).
- Failed checks trigger PagerDuty (Prod) and Slack alerts (Dev/Beta).
- Retain history for 30 days for audits.
