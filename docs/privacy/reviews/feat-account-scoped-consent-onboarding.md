# Privacy Review — feat-account-scoped-consent-onboarding

## Purpose

This feature moves gate state and selected onboarding answers from device-only storage (SharedPreferences) to an account-scoped, server-side SSOT in Supabase/Postgres, so that:
- Gate decisions (Consent/Onboarding) are consistent across devices.
- Onboarding answers (e.g., name/fitness level/goals) are available server-side for personalization.
- Least-privilege via RLS remains guaranteed (owner-only access).

## Data-Flow (High-Level)

- **Auth:** Client ↔ Supabase Auth (`auth.users`).
- **Consent-Logging:** Client → `POST /functions/v1/log_consent` → DB RPC `public.log_consent_if_allowed(...)` → Insert in `public.consents`.
- **Gate SSOT + Onboarding Answers:** Client (authenticated) → PostgREST → `public.profiles` (Upsert/Select owner-only).
- **Cycle-Input:** Client (authenticated) → PostgREST → `public.cycle_data` (Upsert/Select owner-only; extended with `cycle_regularity`).

## Data Categories (PII / Health Data)

- **PII (GDPR Art. 4):**
  - `public.profiles.display_name` (Name)
  - `public.profiles.birth_date` (Date of birth; required when `has_completed_onboarding=true` · 16–120)
- **Health Data (GDPR Art. 9 / FemTech):**
  - `public.cycle_data`: `cycle_length`, `period_duration`, `last_period`, `age`, `cycle_regularity`
  - `public.daily_plan`: Mood/Energy/Symptoms/Notes etc. (already existing)
- **Consent Records (auditable, no IP/UA in DB):**
  - `public.consents`: `user_id`, `version`, `scopes`, `created_at`, `revoked_at`
  - IP/UA are only processed pseudonymized (Hash/HMAC) in observability logs, not persisted in tables.

## Consent (Required vs Optional, Versioning, Revocation)

- **Scopes-SSOT:** `config/consent_scopes.json` (`required=true|false`).
- **Versioning:**
  - String version in consent log: `public.consents.version` (e.g., `v1.0`).
  - Gate version (numeric) for fast comparisons: `public.profiles.accepted_consent_version` (e.g., `1`).
- **Timestamps:**
  - Consent event: `public.consents.created_at`, optional `revoked_at`.
  - Gate state: `public.profiles.accepted_consent_at` (if used/set).
- **Revocation:** via update of a matching consent event (`revoked_at`) or via new explicit "revoke" event (separate feature/PR; not part of this migration).

### Version Sync Requirements

**Fields:**
- `public.consents.version` — String (e.g., `"v1.0"`)
- `public.profiles.accepted_consent_version` — Numeric (e.g., `1`)

**Client-Side Implementation:**
- **File:** [`lib/core/privacy/consent_config.dart`](../../../lib/core/privacy/consent_config.dart)
- **Key Symbols:**
  - `ConsentConfig.currentVersion` — canonical version string (`'v1.0'`)
  - `ConsentConfig.currentVersionInt` — derived major version integer (parsing inline via getter)
  - Version regex: `^v(\d+)(?:\.\d+)?$` (extracts major from `vX.Y`)

> Note: There is no separate `parseConsentVersion` function. The parsing logic is implemented inline in the `currentVersionInt` getter using RegExp.

**CI Validation (TODO):**
- CI pre-merge hook should mirror the parsing rules from `ConsentConfig.currentVersionInt` getter
- Test cases: `v1.0` ↔ `1` (pass), `v2.0` ↔ `2` (pass), `v1.0` ↔ `2` (fail)

**Sync Rules:**
1. **Canonical Source:** `config/consent_scopes.json` defines the current version; both fields derive from this.
2. **Validation (Current):**
   - DB constraint ensures numeric version is non-negative integer
   - Edge Function validates version string format on write
3. **Validation (TODO — Future PR):**
   - CI pre-merge hook to validate version format consistency
   - Runtime API cross-validation between string/numeric forms
4. **Migration Procedure:** Version bumps update both fields atomically via a single DB transaction.
5. **Mismatch Handling:** On detection, reject the write and emit an audit log entry.

> **Follow-up Tracked:** Archon Task `419030ef-69e1-463a-a70a-8d3f53f015b5` —
> "Implement CI pre-merge hook for consent version validation".
> Scope: Validate format consistency between `consents.version` (string, e.g., "v1.0")
> and `profiles.accepted_consent_version` (numeric, e.g., 1). PRs with mismatched
> formats will be rejected. Test cases: v1.0↔1 (pass), v2.0↔2 (pass), v1.0↔2 (fail).

> **Last validated:** Commit `52339cf5` (2026-01-25) — Version parsing logic verified against
> `lib/core/privacy/consent_config.dart` inline RegExp getter implementation.

## Access Control (RLS / Least Privilege)

### profiles (new)
- `public.profiles` has **RLS enabled + FORCE RLS**.
- Policies are owner-only for `authenticated` via `user_id = auth.uid()` (SELECT/INSERT/UPDATE/DELETE).
- Privileges: **no anon/public access** (only `authenticated`).

### cycle_data (existing, extended)
- `public.cycle_data` remains owner-only via existing policies.
- New enum-like CHECK for `cycle_regularity` (nullable; values: `regular|unpredictable|unknown`).

### daily_plan (Hardening)
- `public.daily_plan` is hardened to **FORCE RLS** and `anon` table privileges are revoked (defense-in-depth).

### log_consent_if_allowed (Hardening)
- `public.log_consent_if_allowed(...)` is deprivileged from `public/anon` (EXECUTE), remains executable for `authenticated` (owner-guard: `p_user_id == auth.uid()`; no `service_role` bypass; `service_role` EXECUTE revoked via patch migration).

## Logging / Telemetry (PII-Safety)

- No PII/health data in app logs or edge logs.
- `log_consent` uses pseudonymized metrics (`ip_hash`, `ua_hash`, `consent_id_hash`) in observability logs. The DB (`public.consents`) stores: `user_id`, `version`, `scopes`, `created_at`, `revoked_at`. Note: Timestamps are system-managed, not PII.

## Evidence (RLS + Gates)

### Migrations
- `supabase/migrations/20251214193000_create_profiles_gate_ssot.sql`
- `supabase/migrations/20251214193100_add_cycle_data_regularity.sql`
- `supabase/migrations/20251214193200_harden_privileges_daily_plan_and_log_consent.sql`
- `supabase/migrations/20251222112000_fix_cycle_data_constraint_drift.sql`
- `supabase/migrations/20251222112100_harden_table_grants_least_privilege.sql`
- `supabase/migrations/20251222112200_profiles_birth_date_gate_constraint.sql`
- `supabase/migrations/20251222131000_profiles_set_accepted_consent_at_server_time.sql`
- `supabase/migrations/20251226191139_log_consent_auth_uid_check.sql`
- `supabase/migrations/20251227141500_log_consent_patch_harden_owner_guard_and_scopes.sql`

### Migration Consolidation Note
> **Historical Context:** The privilege hardening was added incrementally across multiple migrations as security controls evolved. For future privacy-sensitive features:
>
> 1. **Pre-merge security review:** Include threat model before initial migration
> 2. **Consolidated privileges:** Include all role grants/revokes in the initial migration
> 3. **PR checklist gate:** Ensure least-privilege grants are part of the initial schema change
>
> See `supabase/migrations/README.md` for the Consent Change-Set Rule requiring coordinated deployment.

### RLS Smoke (Expected Output)
- Option A (without `SUPABASE_DB_URL`, recommended): `.env.local` + `SUPABASE_PROJECT_REF` + `SUPABASE_DB_PASSWORD`
  - `set -a; source .env.local; set +a`
  - `PGPASSWORD="$SUPABASE_DB_PASSWORD" psql "postgresql://postgres@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres?sslmode=require" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke.sql`
  - `PGPASSWORD="$SUPABASE_DB_PASSWORD" psql "postgresql://postgres@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres?sslmode=require" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke_negative.sql`
- Option B (if available): `psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke.sql` (+ `_negative.sql`)
  - Expected: `profiles baseline must return zero rows without context` ✅
  - Expected: Insert/Select under `ROLE authenticated` and `request.jwt.claims.sub=<user>` ✅

### Security Note for Shell Commands
> **Warning:** Commands using `PGPASSWORD` or database credentials can leak into shell history.
>
> **Mitigations:**
> - Prefix sensitive commands with a space (requires `HISTCONTROL=ignorespace` in bash)
> - Use a `.pgpass` file instead of `PGPASSWORD` environment variable
> - Run tests in a disposable shell session or container
> - Clear history after testing: `history -c` (bash) or `fc -p` (zsh)

## Risks & Mitigations

- **Increased PII persistence (name/date of birth):** `birth_date` is required once onboarding is completed; access is owner-only; DB CHECK enforces 16–120 (gate-safe) and prevents "completed without birthdate".
- **Cross-device consistency:** Server-side gate SSOT prevents local drift between devices.

### Cross-Device Sync Behavior

**Server-to-Local Cache Sync:**
- Server (`public.profiles`) is the canonical SSOT for consent and onboarding gates
- Local SharedPreferences acts as cache, not primary storage
- On app start: Remote values sync to local cache when remote is "higher/true"

**Conflict Resolution:**
- Strategy: **Monotonic server-wins with backfill**
- Remote → Local: Server values always override local cache
- Local → Server: Only `true` values backfill (local `true` → remote `true`); `false` is no-op to prevent remote reset
- Race conditions: RLS + atomic upsert prevents partial writes

**Retry Behavior:**
- **Supabase initialization:** 5 attempts, exponential backoff (500ms base, 2x multiplier, ±20% jitter)
- **Profile/consent fetching:** 1 retry with timeout reduction (3s → 2s)
- **Backfill to server:** Fire-and-forget; errors logged but not queued

**Failure Handling (Enhanced for MVP+1):**
- **Per-Item Sync Status (TODO):**
  - Display indicators: "Syncing...", "Sync failed - Retry?"
  - Tied to specific backfill actions for transparency
- **Lightweight Retry Queue (TODO):**
  - Persist failed backfill attempts in local storage (SharedPreferences)
  - Background retry with exponential backoff
- **Escape Hatch UX:**
  - After 3 failed manual retries, show explicit message:
    > "Sync unsuccessful. You can continue with local data. Some settings may not sync across devices."
  - Link to FAQ entry explaining behavior
- **Telemetry Events:**
  - `backfill_attempt_failed {attempt_count, error_type}`
  - `backfill_retry_exhausted {total_attempts}`
  - `escape_hatch_used {session_id}`
- **Current MVP Behavior:** Fire-and-forget backfill; manual retry limit (3); escape hatch proceeds with cached state

- **Abuse/noise via anon RPC:** EXECUTE revokes reduce attack surface and prevent DB error spam.

## Backout / Revert (operational)

### Database Changes
- Drop `profiles` table: `DROP TABLE IF EXISTS public.profiles;`
- Drop `cycle_regularity` column: `ALTER TABLE public.cycle_data DROP COLUMN IF EXISTS cycle_regularity;`
- Restore `log_consent_if_allowed` EXECUTE grants (only if needed) via new revert migration file.

### Data Migration Considerations
**Note:** Data migrated from SharedPreferences to the server will be lost on rollback.
This is acceptable because:
1. Users can re-complete onboarding after revert
2. No critical user data is lost (only onboarding preferences)
3. Consent records in `public.consents` remain intact (audit trail preserved)

**Pre-revert checklist:**
- [ ] Take DB snapshot before executing DROP statements
- [ ] Verify snapshot integrity and accessibility
- [ ] Verify minimal active sessions (<5% DAU) during revert window
  - [ ] Define maintenance window (recommended: 02:00-04:00 UTC)
  - [ ] Monitor active session count via analytics dashboard
  - [ ] Threshold: Proceed if sessions < 5% of average DAU
  - [ ] Graceful degradation: If threshold exceeded, delay 30 min and re-check (max 3 attempts)
  - [ ] Fallback: If still exceeded after 3 attempts, proceed with elevated monitoring
- [ ] **Notify affected users of the rollback (MANDATORY)**
  - [ ] Send notification via in-app message and email within 24 hours
  - [ ] Include: rollback reason, data impact summary, re-onboarding steps
  - [ ] Provide support contact for questions
  - [ ] Log notification delivery confirmation
