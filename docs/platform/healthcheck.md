# Healthcheck Endpoint Specification

## Endpoint
- **URL:** `/api/health`
- **Method:** `GET`
- **Timeout:** 5 s per request
- **Retry:** Max. 3 retries (in addition to the initial attempt); exponential backoff (base 2): 1 s → 2 s → 4 s
- **Polling frequency (Gate/CI):** every 5 minutes

## Response Schema

### Rationale
Explicit thresholds ensure consistent behavior across environments with low traffic while preserving sensitivity under normal load.

- Status mapping (default unless overridden by per-service `thresholds`):
  - `ok` if (`response_ms` ≤ `ok_lte`) AND (error rate < 5%).
  - `degraded` if:
    - (`ok_lte` < `response_ms` ≤ `degraded_lte`) AND (error rate < 20%), OR
    - (5% ≤ error rate < 20%) AND (`response_ms` ≤ `degraded_lte`)
  - `down` if (`response_ms` > `degraded_lte`) OR repeated timeouts OR (error rate ≥ 20%).

## Success Criteria
- Gate passes when HTTP 200 + `status = ok` and no service is `down`.
- `degraded` raises a warning (no hard fail); `down` fails the Gate immediately.

## Status Transitions
- Hysteresis is required to avoid flapping. Use consecutive check counts/time windows:
  - ok → degraded: 2 consecutive non‑ok aggregated outcomes (i.e., latency or error rate outside ok thresholds), or a partial feature failure is detected.
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
- Alerting/escalation: 
  - `degraded` → warning/Slack; `down` → page/PagerDuty.
  - Auto-resolve behavior: When a service transitions to `ok`, the incident remains open for a 5-minute confirmation window. Auto-resolve occurs only after the service remains continuously `ok` for the full 5 minutes. This window prevents flap-induced re-alerting.
  - Manual acknowledgment: Operators may acknowledge incidents manually at any time but are not required to.
  - Stale incident timeout: PagerDuty incidents auto-close if not updated within 24 hours.

### Aggregation and hysteresis counters (state machine semantics)
- A single "check" may perform internal retries per the retry/backoff policy. These retries MUST be collapsed into one aggregated outcome level: `ok`, `degraded`, or `failed` based on aggregated metrics and thresholds.

**Terminology clarification:**
- **`failed`** is an internal aggregated outcome produced by a check's retry/aggregation logic and used by the state machine to decide transitions. It is not directly exposed to API consumers.
- **`down`** is the external observable service status, emitted by the state machine after completing state transitions. Once the state machine determines that `failed` outcomes have persisted (e.g., `consecutiveFailed >= 2`), it transitions the service status to `down`.
- The consecutive counters track only aggregated outcomes and are context aware:
  - `consecutiveOk` increments on `ok` and resets on non‑ok.
  - `consecutiveFailed` increments on `failed` (≥ 20% error, latency > `degraded_lte`, or repeated timeouts) and resets on non‑failed.
  - `consecutiveNonOk` increments on any non‑ok outcome (`degraded` or `failed`) and resets on `ok`. This is used for the `ok → degraded` hysteresis.
  - While in `down`, a separate short counter `consecutiveNonFailedWhileDown` increments on any non‑failed result (`ok` or `degraded`) and resets on `failed`. This is used exclusively for the `down → degraded` transition.
- Error-rate threshold is evaluated per aggregated check consistent with the status mapping above: aggregated `error_rate ≥ 20%` contributes a `failed` outcome; `5% ≤ error_rate < 20%` contributes a `degraded` outcome. There is not a separate counter for error‑rate.
- State transitions evaluate only these aggregated results and the consecutive counters.

Pseudocode (reference implementation):
```pseudo
// Initial state
// On startup, initial state = ok. Counters start at 0; the first aggregated
// health check may transition immediately per the rules below. Alerting follows
// the alerting policy above (e.g., auto-resolve confirmation window).
state ∈ {ok, degraded, down}
consecutiveOk = 0
consecutiveFailed = 0
consecutiveNonOk = 0
consecutiveNonFailedWhileDown = 0

function runSingleCheckWithRetries(checkFn):
  // Perform the initial attempt plus maxRetries additional retries
  attemptsCount = maxRetries + 1
  attempts = []
  for i in 0..attemptsCount-1:
    res = checkFn()
    attempts.append(res)
    if res.success:
      // Classify immediate attempt to short‑circuit if it's clearly within OK or degraded thresholds
      if res.errorRate < 0.05 and res.latency <= thresholds.ok_lte:
        return { level: "ok", errorRate: res.errorRate, latency: res.latency }
      if res.errorRate < 0.20 and res.latency <= thresholds.degraded_lte:
        return { level: "degraded", errorRate: res.errorRate, latency: res.latency }
    // Only back off if another retry remains
    if i < attemptsCount - 1:
      backoff(i)
  // Aggregate after retries exhausted
  // See section "Aggregation Policy (concrete)" for exact formulas.
  aggErrorRate = aggregateErrorRate(attempts) // weighted by sample_count across attempts
  aggLatency = aggregateLatency(attempts)     // default p95 across merged samples (configurable)
  if aggErrorRate >= 0.20 or aggLatency > thresholds.degraded_lte or repeatedTimeouts(attempts):
    // "failed" is internal outcome; see terminology clarification above
    return { level: "failed", errorRate: aggErrorRate, latency: aggLatency }
  if aggErrorRate < 0.05 and aggLatency <= thresholds.ok_lte:
    return { level: "ok", errorRate: aggErrorRate, latency: aggLatency }
  return { level: "degraded", errorRate: aggErrorRate, latency: aggLatency }

function updateState(aggResult):
  // "failed" is internal outcome; external status "down" is set by state machine below
  if aggResult.level == "failed":
    consecutiveFailed += 1
    consecutiveNonOk += 1
    consecutiveOk = 0
    consecutiveNonFailedWhileDown = 0
  else if aggResult.level == "ok":
    consecutiveOk += 1
    consecutiveFailed = 0
    consecutiveNonOk = 0
    if state == down: consecutiveNonFailedWhileDown += 1
  else: // level == "degraded"
    consecutiveOk = 0
    consecutiveFailed = 0 // degraded is not failed
    consecutiveNonOk += 1
    // Only track consecutiveNonFailedWhileDown while in 'down' state
    // (not when state is degraded or ok)
    if state == down: consecutiveNonFailedWhileDown += 1

  switch state:
    case ok:
      // Any non‑ok aggregated result breaks ok streaks; degrade after 2 non‑ok outcomes
      if consecutiveNonOk >= 2: state = degraded
    case degraded:
      // Degraded → down: the state machine MUST evaluate the aggregated metrics
      // across the last two consecutive failed checks to determine transition.
      // Any deviation from this evaluation method MUST be explicitly opted‑in via
      // a documented service configuration schema or an ADR that defines the
      // opt‑in mechanism and validation requirements.
      if consecutiveFailed >= 2 and (
           aggResult.latency > thresholds.degraded_lte or repeatedTimeoutsLastChecks()):
        state = down
      else if consecutiveOk >= 3: // require 3 consecutive OK results
        state = ok
    case down:
      if aggResult.level != "failed" and aggResult.latency <= thresholds.degraded_lte:
        if consecutiveNonFailedWhileDown >= 2:
          state = degraded
          consecutiveNonFailedWhileDown = 0 // reset after leaving "down"
      if consecutiveOk >= 3:
        state = ok
        consecutiveNonFailedWhileDown = 0 // reset after leaving "down"
```

### Degraded → Down Evaluation Method

Services may optionally opt into a specific degraded → down evaluation method via the per‑service configuration key `health.evaluation.degraded_to_down_method`.

- Key: `degraded_to_down_method`
- Scope: per service (`health.evaluation`)
- Allowed values (MVP):
  - `aggregated_last_two_failed` (default, and only allowed value without ADR): Transition to `down` when the last two consecutive aggregated checks are `failed` and either p95 latency exceeds `degraded_lte` or repeated timeouts were observed in those checks.
  - `any_single_failed` (extension; requires ADR): Transition to `down` after any single aggregated `failed` check (more aggressive; increases sensitivity, higher risk of flapping).
  - `majority_failed` (extension; requires ADR): Evaluate a sliding window and transition if the majority of aggregated checks in the window are `failed`.

Notes:
- For the MVP, unknown values are rejected by schema validation and only `aggregated_last_two_failed` is accepted. Any future method must be introduced via ADR and added to the schema allow‑list.
- This key controls only the degraded → down transition; other transitions follow the counters/hysteresis described above.

### Aggregation Policy (concrete)

Error‑rate (weighted average by samples across all attempts in a single check):

Let attempt i provide `sample_count_i` total responses and `error_count_i` errors (timeouts that yield no responses contribute to the timeout rules below, not to counts here).

```
total_error_count  = Σ_i error_count_i
total_sample_count = Σ_i sample_count_i
aggErrorRate       = total_error_count / max(1, total_sample_count)
```

Timeout‑only attempts (no responses within the per‑request timeout) are excluded from the numerator and denominator above and are handled by `repeatedTimeouts(...)` and `repeatedTimeoutsLastChecks()`.

Latency (default p95 across attempts):
- Default aggregation computes p95 over the union of all per‑attempt latency samples within the single check (merge all samples, then compute p95).
- This can be overridden per service via configuration. Allowed options:
  - `p50` (median across merged samples)
  - `p95` (default; across merged samples)
  - `max` (maximum across merged samples)
  - `ma_last_5m` (moving average over last 5 minutes; requires backend support; if unsupported, fallback to `p95`).

Configuration knobs (per service):
- `health.aggregation.latency_metric`: one of `p50 | p95 | max | ma_last_5m` (default: `p95`).
- Error‑rate method is fixed to `weighted_by_samples` for MVP and is not configurable; any future change must go through ADR and schema extension.

Governance & compatibility:
- Unknown enum values MUST be rejected by validation.
- Extensions to aggregation policy require an ADR and a schema update listing the new allowed values. See docs/config/service-config-schema.md.

### Definition: repeated timeouts
To remove ambiguity around timeout-based transitions, use the following concrete thresholds and windows:

- `repeatedTimeouts(attempts)` (within a single aggregated check): true if the number of timed-out attempts across the initial try plus retries is ≥ 2 (not necessarily consecutive).
- `repeatedTimeoutsLastChecks()` (across recent aggregated checks): true if `repeatedTimeouts(...)` was true in each of the last 2 aggregated checks (i.e., repeated timeouts in the last 2 checks).

Notes:
- A “timeout” here refers to any attempt that hit the per-request timeout (5 s) and produced no successful response.
- These thresholds are tuned for the MVP; services may override them with stricter windows if needed.

## Per-service threshold overrides
- See: docs/config/service-config-schema.md (Service configuration schema)
- Precedence: explicit per‑service overrides take priority over organization/global defaults, which take priority over this spec’s baked‑in defaults. Invalid or partial overrides must be rejected by validation and fall back to the next lower precedence.

Example (YAML):

```yaml
service: revenuecat_proxy
health:
  thresholds:
    ok_lte: 250ms
    degraded_lte: 1200ms
    error_rate_warn: 0.05   # 5%
    error_rate_crit: 0.20   # 20%
  windows:
    consecutive_ok_for_recover_ok: 3
    consecutive_fail_for_degrade: 2
    consecutive_fail_for_down: 2
    confirm_ok_auto_resolve_minutes: 5
  timeouts:
    per_request_timeout: 5s
    repeated_timeouts_per_check: 2
    repeated_timeouts_last_checks: 2
  evaluation:
    degraded_to_down_method: aggregated_last_two_failed   # opt‑in keys must validate against schema
  aggregation:
    latency_metric: p95  # allowed: p50 | p95 (default) | max | ma_last_5m
```

Operators can apply overrides via the Settings UI (Settings → Health → Thresholds) referenced above, or by editing the service registry and CI deployment manifests that carry this configuration. Changes must pass schema validation before taking effect.

## Monitoring
- Results are pushed to the observability stack (Grafana/PostHog).
- Failed checks trigger PagerDuty (Prod) and Slack alerts (Dev/Beta).
- Retain history for 30 days for audits.
