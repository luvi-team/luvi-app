# Offline Resume – Key Management Design

Scope: Encryption keys for local offline resume snapshots (Flutter, `sqflite_sqlcipher`). Complements ADR-0006.

Objectives
- Protect locally cached resume snapshots at rest on device.
- Avoid user-password–derived keys; minimize UX/operational risk.
- Enable periodic rekey; tolerate device loss/migration without data loss of server truth.

Decisions
- Key origin: Generate a random 32-byte secret on first use via a cryptographically secure RNG (`Random.secure()` in Dart). Store in OS-backed Secure Storage (Keychain/Keystore). Do not derive from user password.
- DB keying: Use the stored secret as SQLCipher passphrase. Rely on SQLCipher’s PBKDF2-HMAC-SHA512 derivation. Explicitly set the iteration count via `PRAGMA kdf_iter` to a modern value (target 210,000 for PBKDF2-HMAC-SHA512 per OWASP 2023) where supported; otherwise use library defaults.
- Rotation/rekey: Prefer export → rename using `sqlcipher_export` to a fresh encrypted database file, followed by an atomic rename into place. In-place `PRAGMA rekey = '<new_key>'` is permitted only when constraints require it and preconditions are met (see below). Default rotation window: 180 days (configurable). Rekey/export runs only when the database is open and healthy. After success, record `last_rotated_at` (UTC) both inside the encrypted DB (e.g., `pragma user_version` or a `meta` table) and in app preferences for cross-checking.
- Migration/new device: No key portability. A new device generates a new key and an empty local DB and then rehydrates from server. Local-only anonymous caches may be discarded on migration.
- Secure Storage loss/compromise:
  - Loss (key missing/unavailable): Drop local DB and rehydrate from server for signed-in users; show a non-blocking info toast. Anonymous caches are discarded.
  - Compromise (root/jailbreak detected): Disable persistent local caching for snapshots; operate in memory-only mode for the session. Re-enable after device returns to a trusted state.
- Multi-device: Keys are device-local; there is no shared secret across devices. Server remains the source of truth for signed-in users.

Operational Notes
- Key material never leaves the device. Server-side snapshots remain encrypted at transport (TLS) and are stored unencrypted on the server DB (server-side security via RLS and access controls). Local encryption is a defense-in-depth measure.
- Error handling: Any failure to open with the current key triggers a single retry after a short, explicitly defined delay. Use a shared constant across clients, e.g., `RETRY_DELAY_MS = 500`. Implementers on Flutter (iOS/Android) MUST reference the same config value to keep behavior consistent. If still failing after the one retry, treat as key loss: wipe local DB and rehydrate. During rekey/export, if an error occurs, abort the operation, retry once with the old key, and attempt rehydration from server backup if corruption is suspected. Fail closed with a clear remediation path if recovery is not possible (do not proceed with a partially rekeyed file).
- Telemetry: Emit non-PII events for `resume_local_rekey_start|success|failure` and `resume_local_rehydrate_start|success|failure` with error-class only.

Graceful degradation for low storage (deferral policy)
- Rationale: The 2–3× free-disk requirement (see Preconditions below) can be unmet on low-storage devices, especially around OS updates or media spikes. Rekey must degrade gracefully without blocking core usage.
- User-facing deferral flow: When free space is insufficient, defer rekey and present a non-blocking notification/toast with actionable steps and a retry affordance.
  - Example copy: “Security update postponed: Not enough free space to rotate local encryption. Free up storage and try again. This does not affect your workouts.”
  - CTA options: “Learn how to free space”, “Retry now”, and implicit auto-retry when idle/on charge/Wi‑Fi.
- Required telemetry/instrumentation: Record deferrals with reason codes and context to monitor operational impact.
  - Event: `resume_local_rekey_deferred`
  - Properties: `{ reason: "low_disk"|"db_busy"|..., free_space_bytes, db_size_bytes, required_min_bytes, attempts, last_attempt_at }`
- Fallback policy and rotation window treatment:
  - Acceptable deferral window: up to 14 days from first scheduled rotation. Within this window, periodically reattempt (exponential backoff, bounded).
  - After 7 days: escalate UI to a higher-visibility but still non-blocking reminder; surface a settings badge.
  - After 14 days: mark status as “rotation overdue” and prioritize background rekey when Preconditions are met. Do not block app usage; if device remains constrained, continue deferrals and surface guidance.
  - Rotation window: a deferred rotation extends the effective window; the next rotation date is based on the actual completion timestamp, not the original due date.
- Operational monitoring: Track deferral rates and overdue counts for alerting.
  - Suggested alerts: daily deferral rate `> 10%` of active devices, or `> 1%` devices overdue `> 14d`.
  - Dashboard slices by platform version, device storage tiers, and app version.

Rekey Safety and Procedure
1) Preconditions (both in-place and export):
- Verify the local DB has been successfully synced to server (for signed-in users) to ensure no local-only data is at risk.
- Verify free disk space ≥ 2× the current DB file size (baseline). Allow up to 3× when page/reserved-byte layout changes or VACUUM-style rewrites may occur, to accommodate temporary artifacts.
- Ensure the DB is idle (no long-running transactions). If using WAL, checkpoint and truncate the WAL (or close all connections) prior to rekeying to avoid additional temporary WAL usage during the operation.

 Failure behavior when preconditions are unmet:
 - The rekey operation MUST be deferred and MUST NOT start.
 - Return a clear error code and message, e.g. `REKEY_PRECONDITION_FAILED` with diagnostics describing which check failed and the current observed values (e.g., `free_space_bytes`, `db_size_bytes`, `active_connections`, `wal_size_bytes`).
 - Notify the user/admin with actionable steps: free disk space, close database connections, run a WAL checkpoint/truncate, or retry later when device is idle.
 - Optional automated fallback: schedule a retry with exponential backoff (e.g., base 30s, multiplier 2×, jitter ±20%) with a bounded maximum attempts window (e.g., 5 attempts). If the app supports offline work queues, enqueue the rekey for an offline retry window.
 - Safe rollback/logging: ensure no partial rekey attempts are left on disk. Do not modify the original DB file. Log a structured event with error-class, precondition details, and whether a retry was scheduled. No user data changes are permitted in this state.

2) Recommended default: export → rename
- Steps:
  - Open the existing DB with `PRAGMA key` (old key), then set `PRAGMA kdf_iter = 210000` (if supported) before any reads/writes.
  - Create a new temporary database file (`<db>.tmp`) and open it; apply `PRAGMA key = '<new_key>'` then `PRAGMA kdf_iter = 210000`.
  - Run `SELECT sqlcipher_export('<main_or_alias_of_tmp>');` to copy contents into the new encrypted DB.
  - On the new DB, run `PRAGMA integrity_check;` and verify `ok`.
  - fsync and close both DBs; atomically rename `<db>.tmp` over the original `<db>` (use platform atomic rename APIs).
  - Reopen the final DB and run another `PRAGMA integrity_check;`.

3) In-place rekey (only if necessary)
- **Caveat**: `PRAGMA rekey` is not filesystem-atomic and creates a corruption risk window. A crash or power loss during the operation may render the database unrecoverable. Ensure device has adequate battery and stable power before proceeding. Crash safety depends on `journal_mode`, `synchronous`, and the VFS's atomic-commit guarantees. Use conservative settings during rekey:
  - `PRAGMA journal_mode = wal;` or `DELETE` based on platform guarantees and library defaults.
  - `PRAGMA synchronous = FULL;` for the operation window.
- Steps:
  - Open with `PRAGMA key` (old key) → set `PRAGMA kdf_iter = 210000` (if supported) → run `PRAGMA rekey = '<new_key>';`.
  - After completion, run `PRAGMA integrity_check;` and verify `ok`.
- If any step fails, do not continue using the possibly partially rekeyed file; close, reopen with the old key, and fall back to export → rename or full rehydrate.

4) Post-rotation bookkeeping
- Update `last_rotated_at` inside the DB (e.g., `meta(key='last_rotated_at', value=ISO8601)`) and in app preferences.
- Log success telemetry; on failure, include error class and chosen recovery path (retry/rehydrate/abort).

Open Items
- Validate `kdf_iter` control support in `sqflite_sqlcipher` for explicit iteration tuning; otherwise document library defaults. Confirm platform-specific atomic rename semantics and recommended `journal_mode` for safest rekey on iOS/Android.
- Document platform-specific secure storage behavior (iOS keychain accessibility class; Android Keystore backup behavior) in a short appendix.
