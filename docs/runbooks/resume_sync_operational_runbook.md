# Resume Sync – Operational Runbook

Scope: Monitoring thresholds, streaming guidance, and on-call actions for the resume snapshots feature. Complements ADR-0006.

Metrics
- Event error rate (daily): `failed_sync_events / total_sync_events` (signed-in users). Target < 1% baseline; alerting thresholds below.
- User error rate (daily): `users_with_≥1_failure / users_with_≥1_sync`.

Alerting (initial; calibrate post-launch)
- Warn (async): ≥ 2% over ≥ 60 min OR trend +0.5%/h → ticket for feature team.
- Page (SEV‑3): ≥ 5% over rolling 24h OR ≥ 7% over ≥ 30 min.
- SEV‑2: ≥ 10% over ≥ 30 min OR ≥ 5,000 affected users/day.
- SEV‑1: ≥ 25% over ≥ 15 min OR data corruption indicators → enable feature‑flag „local‑only“.

Streaming Guidance
- Default to buffered downloads for exports.
- Switch to streaming for large payloads (indicative thresholds): > 10 MB or > 1,000 snapshots, or when incremental rendering is required.
- Before streaming, estimate size using `Content-Length` or count × average record size; ensure memory footprint stays within budget.

Triage Steps
1) Identify error class (4xx, 5xx, network, 429/rate-limit).
2) Verify client backoff/retry bounds; enable/decrease concurrency if needed.
3) Consider feature‑flag „local‑only“ on server degradation.
4) Inspect queue length, batch sizes, and latencies.
5) Communicate status; publish RCA ≤ 48h; add regression tests for the cause.

Time & Timestamps
- Persist `updated_at` strictly in UTC (server-controlled). Clients may display localized times but must not persist device-local times.

