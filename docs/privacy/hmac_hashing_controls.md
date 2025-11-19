# HMAC Hashing Controls (UA/IP)

Version: v1.0 · Scope: consent_logs (UA/IP surrogates)

- Algorithm: HMAC-SHA256 with server-managed pepper (secret key).
- Inputs:
  - `ip_hash = HMAC_SHA256(pepper, ip_cidr_truncated)` with CIDR truncation (e.g., IPv4 /24, IPv6 /64) before hashing.
  - `ua_hash = HMAC_SHA256(pepper, user_agent_string)` after trimming/normalizing whitespace.
- Storage:
  - Store only hex/base64 digest; never store raw IP or UA.
  - Record `hash_version` (e.g., `hmac_v1`) next to hashes for forward rotation.
- Rotation cadence: quarterly (every 90 days). Maintain `pepper_active` and `pepper_previous` for a 30‑day grace window to validate historical hashes if required.
- Emergency rotation:
  1) Generate new `pepper_active` in secret store; revoke `pepper_previous` if still present.
  2) Flip application config to use new pepper immediately.
  3) Backfill on write: new records always use new pepper; optional opportunistic rehash when reading known recent rows.
  4) Audit: record `rotated_at`, actor, reason. Verify no raw IP/UA persisted.
- Access control: peppers live in server secret storage; no client access; audit trail on reads.
- Data minimisation: prefer truncated IP as input; avoid salts unique per user to keep comparability for abuse detection while limiting linkability.
- Testing: unit tests covering determinism, rotation boundaries, and version tagging.

