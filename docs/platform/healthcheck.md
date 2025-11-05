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
- Measurement method and fallbacks:
  - Primary: use `p95` latency over the `last_5m` window when `sampleSize ≥ 20`.
  - Fallback 1: if `sampleSize < 20` but `sampleSize ≥ 5`, use `p50` (median) over the same `last_5m` window.
  - Fallback 2: if `sampleSize < 5` and percentiles are not statistically meaningful, use a simple moving average over `last_5m`.
  - Implementations MUST record the metric actually used in the top-level `metric` field using one of: `p95`, `p50`, or `ma_last_5m`. They SHOULD also include `sampleSize` in each service entry to aid debugging and audits.
  - Rationale: explicit thresholds ensure consistent behavior across environments with low traffic while preserving sensitivity under normal load.
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
- Dependency impact and critical-path definition:
  - Dependencies are marked as "critical-path" via configuration key `health.criticalDependencies` (list of service IDs) in the service registry or Settings UI under Health → Dependencies.
  - Propagation rule:
    - If any dependency is `down` and it is listed in `health.criticalDependencies`, the parent service becomes `down`.
    - If a non-critical dependency is `down`, the parent is at least `degraded` (never escalated to `down` solely due to a non-critical dependency).
  - Example: `serviceA` with `health.criticalDependencies = ["supabase_db", "revenuecat_proxy"]` becomes `down` if `supabase_db` is `down`; if only `external_apis` is `down`, `serviceA` is `degraded`.
  - Operators can manage the list under: Settings → Health → Dependencies → Critical Dependencies.
- Retry/backoff: apply the endpoint retry policy above during each check; a single check is `failed` only after retries are exhausted.
- Alerting/escalation: `degraded` → warning/Slack; `down` → page/PagerDuty, with auto-resolve after recovery criteria are met.

### Aggregation and hysteresis counters (state machine semantics)
- A single "check" may perform internal retries per the retry/backoff policy. These retries MUST be collapsed into one aggregated outcome: `pass` if any attempt succeeds within thresholds and error-rate < threshold; otherwise `failed`.
- The consecutive-failure counter increments by 1 only when the aggregated outcome of a check is `failed`. It resets to 0 on any aggregated `pass`.
- Error-rate threshold is evaluated per aggregated check (e.g., if aggregated `error_rate ≥ 5%` → outcome `failed`, contributes +1 to the consecutive-failure counter). There is not a second counter for error-rate.
- State transitions evaluate only these aggregated results and the consecutive-failure counter.

Pseudocode (reference implementation):
```pseudo
state ∈ {ok, degraded, down}
consecutiveFailed = 0

function runSingleCheckWithRetries(checkFn):
  attempts = []
  for i in 0..maxRetries:
    res = checkFn()
    attempts.append(res)
    if res.success and res.errorRate < 0.05 and res.latency <= thresholds.degraded_lte:
      return { outcome: "pass", errorRate: res.errorRate, latency: res.latency }
    backoff(i)
  // Aggregate after retries exhausted
  aggErrorRate = aggregateErrorRate(attempts) // e.g., weighted by samples
  aggLatency = aggregateLatency(attempts)     // per selected metric p95/p50/ma_last_5m
  if aggErrorRate >= 0.05 or aggLatency > thresholds.degraded_lte or repeatedTimeouts(attempts):
    return { outcome: "failed", errorRate: aggErrorRate, latency: aggLatency }
  return { outcome: "pass", errorRate: aggErrorRate, latency: aggLatency }

function updateState(aggResult):
  if aggResult.outcome == "failed":
    consecutiveFailed += 1
  else:
    consecutiveFailed = 0

  switch state:
    case ok:
      if consecutiveFailed >= 2: state = degraded
    case degraded:
      if consecutiveFailed >= 2 and (
           aggResult.latency > thresholds.degraded_lte or repeatedTimeoutsLastChecks()):
        state = down
      else if consecutiveFailed == 0 for 3 consecutive checks within ok thresholds:
        state = ok
    case down:
      if consecutiveFailed == 0 for 2 consecutive checks and latency <= thresholds.degraded_lte:
        state = degraded
      if consecutiveFailed == 0 for 3 consecutive checks within ok thresholds:
        state = ok
```

## Monitoring
- Results are pushed to the observability stack (Grafana/PostHog).
- Failed checks trigger PagerDuty (Prod) and Slack alerts (Dev/Beta).
- Retain history for 30 days for audits.
