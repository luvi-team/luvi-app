# Offline Resume – Key Management Design

Scope: Encryption keys for local offline resume snapshots (Flutter, `sqflite_sqlcipher`). Complements ADR-0006.

Objectives
- Protect locally cached resume snapshots at rest on device.
- Avoid user-password–derived keys; minimize UX/operational risk.
- Enable periodic rekey; tolerate device loss/migration without data loss of server truth.

Decisions
- Key origin: Generate a random 32-byte secret on first use. Store in OS-backed Secure Storage (Keychain/Keystore). Do not derive from user password.
- DB keying: Use the stored secret as SQLCipher passphrase. Rely on SQLCipher’s PBKDF2-HMAC-SHA512 derivation. Prefer explicitly setting iteration count where supported via `PRAGMA kdf_iter` to a modern value; otherwise use library defaults.
 - Rotation/rekey: Prefer in-place `PRAGMA rekey = '<new_key>'` when available. Default rotation window: 180 days (configurable). Rekey runs only when the database is open and healthy. After rekey, existing pages are rewritten under the new key; no legacy keys must be retained. Keep a monotonic `last_rotated_at` (UTC) in app preferences.
- Migration/new device: No key portability. A new device generates a new key and an empty local DB and then rehydrates from server. Local-only anonymous caches may be discarded on migration.
- Secure Storage loss/compromise:
  - Loss (key missing/unavailable): Drop local DB and rehydrate from server for signed-in users; show a non-blocking info toast. Anonymous caches are discarded.
  - Compromise (root/jailbreak detected): Disable persistent local caching for snapshots; operate in memory-only mode for the session. Re-enable after device returns to a trusted state.
- Multi-device: Keys are device-local; there is no shared secret across devices. Server remains the source of truth for signed-in users.

Operational Notes
- Key material never leaves the device. Server-side snapshots remain encrypted at transport (TLS) and are stored unencrypted on the server DB (server-side security via RLS and access controls). Local encryption is a defense-in-depth measure.
- Error handling: Any failure to open with the current key triggers a single re-try after a short delay. If still failing, treat as key loss: wipe local DB and rehydrate.
- Telemetry: Emit non-PII events for `resume_local_rekey_start|success|failure` and `resume_local_rehydrate_start|success|failure` with error-class only.

Open Items
- Validate `kdf_iter` control support in `sqflite_sqlcipher` for explicit iteration tuning; otherwise document library defaults.
- Document platform-specific secure storage behavior (iOS keychain accessibility class; Android Keystore backup behavior) in a short appendix.
