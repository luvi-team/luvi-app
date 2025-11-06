# Resume Sync – Operational Runbook

Scope: Monitoring thresholds, streaming guidance, and on-call actions for the resume snapshots feature. Complements ADR-0006.

Metrics
- Event error rate (daily): `failed_sync_events / total_sync_events` (signed-in users). Target < 1% baseline; alerting thresholds below.
- User error rate (daily): `users_with_≥1_failure / users_with_≥1_sync`.

Alerting (initial; calibrate post-launch)
- Warn (async): ≥ 2% over ≥ 60 min OR trend +0.5%/h → ticket for feature team.
- Page (SEV‑3): ≥ 5% over rolling 24h OR ≥ 7% over ≥ 30 min.
- SEV‑2: ≥ 10% over ≥ 30 min OR ≥ 5,000 affected users/day.
- SEV‑1: ≥ 25% over ≥ 15 min OR data corruption indicators → enable feature‑flag "local‑only".

Streaming Guidance
- Default to buffered downloads for exports.
- Switch to streaming for large payloads (indicative thresholds): > 10 MB or > 1,000 snapshots, or when incremental rendering is required.
- Before streaming, estimate size using `Content-Length` or count × average record size; ensure memory footprint stays within budget.

Triage Steps
1) Identify error class (4xx, 5xx, network, 429/rate-limit).
2) Verify client backoff/retry bounds; enable/decrease concurrency if needed.
3) Consider feature‑flag "local‑only" on server degradation.
4) Inspect queue length, batch sizes, and latencies.
5) Communicate status; publish RCA ≤ 48h; add regression tests for the cause.

Time & Timestamps
- Persist `updated_at` strictly in UTC (server-controlled). Clients may display localized times but must not persist device-local times.

Data Corruption Indicators
- Non-monotonic sequence or version counters for the same record (e.g., `version` decreases).
- Checksum/hash mismatch for snapshot payloads (e.g., stored `content_hash` != recomputed hash).
- Orphaned child rows (FK exists but parent missing) detected by integrity queries.
- Duplicate primary keys/unique keys observed in logs or constraint violation bursts.
- Server rejects payloads due to schema drift (unknown fields, type mismatches) after a deploy.
- Invariant violations in app logs (e.g., “resume-sync invariant failed: negative delta”, “invalid snapshot window”).

Example Integrity Queries (read-only)
- Orphans: `select child.id from child left join parent on child.parent_id = parent.id where parent.id is null limit 50;`
- Duplicate keys (by logical business key):
  `select logical_key, count(*) from snapshots group by logical_key having count(*) > 1 limit 50;`
- Non-monotonic versions per user (sequential check):
  `select user_id, id, version, created_at from (
     select s.*, lag(version) over (partition by user_id order by created_at) as prev_version
     from snapshots s
   ) t
   where prev_version is not null and version < prev_version
   limit 50;`
- Duplicate versions per user (optional):
  `select user_id, version, count(*) as n
   from snapshots
   group by user_id, version
   having count(*) > 1
   order by n desc
   limit 50;`

Local-Only Mode
- Behavior: disables outbound sync/network writes; client persists locally and defers any server mutations. Read paths may be stubbed/mocked or disabled.
- Purpose: immediate blast-radius reduction during suspected corruption or widespread server instability.
- Enable: roll out a remote feature-flag targeting 100% of affected users (key: `resume_sync.local_only`). If remote flags are unavailable, coordinate a server-side mitigation (e.g., temporarily disable sync endpoints via gateway/WAF) as an operational fallback.
- Disable: roll back the flag after mitigation and verification; gradually re-enable (10% → 50% → 100%) while monitoring error and corruption indicators.
- Client considerations: ensure UI communicates “sync paused – local changes queued” and that retries/backoff remain bounded.
