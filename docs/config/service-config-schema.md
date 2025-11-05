# Service Configuration Schema (Health)

Status: Draft (MVP)
Scope: Per‑service healthcheck thresholds, windows, and evaluation policy

## Purpose
Define a minimal, validated schema for service‑specific health configuration. Overrides must be explicit and opt‑in; invalid overrides are rejected.

## Schema (YAML)

Top‑level keys: `service`, `health`.

```yaml
service: <string>               # Unique service identifier
health:
  thresholds:
    ok_lte: <duration>          # e.g., 250ms
    degraded_lte: <duration>    # e.g., 1200ms
    error_rate_warn: <float>    # 0..1 (e.g., 0.05)
    error_rate_crit: <float>    # 0..1 (e.g., 0.20)
  windows:
    consecutive_ok_for_recover_ok: <int>      # default 3
    consecutive_fail_for_degrade: <int>       # default 2
    consecutive_fail_for_down: <int>          # default 2
    confirm_ok_auto_resolve_minutes: <int>    # default 5
  timeouts:
    per_request_timeout: <duration>           # default 5s
    repeated_timeouts_per_check: <int>        # default ≥2 attempts
    repeated_timeouts_last_checks: <int>      # default 2 checks
  evaluation:
    degraded_to_down_method: <enum>           # allowed: aggregated_last_two_failed (default)
```

### Validation rules
- `ok_lte < degraded_lte` (strict).
- `0 ≤ error_rate_warn < error_rate_crit ≤ 1`.
- All counters must be positive integers.
- Durations must parse to finite values (e.g., `Xs`, `Xms`).
- `evaluation.degraded_to_down_method` must be `aggregated_last_two_failed` unless explicitly extended via ADR; unknown values are rejected.

### Precedence and rollout
- Precedence: per‑service overrides → org/global defaults → spec defaults.
- CI enforces schema validation; invalid configs fail the build.
- Rollout: managed via Settings UI (Settings → Health → Thresholds) or service registry/manifests. Changes are applied on next deploy or dynamic config reload if supported.

### Example

```yaml
service: revenuecat_proxy
health:
  thresholds:
    ok_lte: 250ms
    degraded_lte: 1200ms
    error_rate_warn: 0.05
    error_rate_crit: 0.20
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
    degraded_to_down_method: aggregated_last_two_failed
```

