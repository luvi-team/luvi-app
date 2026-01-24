# Privacy Review — feat-account-scoped-consent-onboarding

## Purpose
Dieses Feature verschiebt Gate-State und ausgewählte Onboarding-Antworten von device-only Storage (SharedPreferences) in eine account-scoped, serverseitige SSOT in Supabase/Postgres, damit:
- Gate-Entscheidungen (Consent/Onboarding) geräteübergreifend konsistent sind.
- Onboarding-Antworten (z. B. Name/Fitnesslevel/Ziele) serverseitig für Personalisierung verfügbar sind.
- Least-Privilege über RLS garantiert bleibt (Owner-only Zugriff).

## Data-Flow (High-Level)
- **Auth:** Client ↔ Supabase Auth (`auth.users`).
- **Consent-Logging:** Client → `POST /functions/v1/log_consent` → DB RPC `public.log_consent_if_allowed(...)` → Insert in `public.consents`.
- **Gate SSOT + Onboarding-Antworten:** Client (authenticated) → PostgREST → `public.profiles` (Upsert/Select owner-only).
- **Cycle-Input:** Client (authenticated) → PostgREST → `public.cycle_data` (Upsert/Select owner-only; erweitert um `cycle_regularity`).

## Data Categories (PII / Health Data)
- **PII (Art. 4 DSGVO):**
  - `public.profiles.display_name` (Name)
  - `public.profiles.birth_date` (Geburtsdatum; required wenn `has_completed_onboarding=true` · 16–120)
- **Gesundheitsdaten (Art. 9 DSGVO / FemTech):**
  - `public.cycle_data`: `cycle_length`, `period_duration`, `last_period`, `age`, `cycle_regularity`
  - `public.daily_plan`: Mood/Energy/Symptoms/Notes etc. (bereits vorhanden)
- **Consent-Nachweise (auditierbar, ohne IP/UA in DB):**
  - `public.consents`: `user_id`, `version`, `scopes`, `created_at`, `revoked_at`
  - IP/UA werden ausschließlich in Observability-Logs pseudonymisiert (Hash/HMAC) verarbeitet, nicht in Tabellen persistiert.

## Consent (Pflicht vs Optional, Versioning, Widerruf)
- **Scopes-SSOT:** `config/consent_scopes.json` (`required=true|false`).
- **Versioning:**
  - String-Version im Consent-Log: `public.consents.version` (z. B. `v1.0`).
  - Gate-Version (numerisch) für schnelle Vergleiche: `public.profiles.accepted_consent_version` (z. B. `1`).
- **Timestamps:**
  - Consent-Event: `public.consents.created_at`, optional `revoked_at`.
  - Gate-State: `public.profiles.accepted_consent_at` (falls genutzt/gesetzt).
- **Widerruf:** über Update eines passenden Consent-Events (`revoked_at`) oder durch neues, explizites „revoke"-Event (separates Feature/PR; nicht Teil dieser Migration).

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

## Access Control (RLS / Least Privilege)
### profiles (neu)
- `public.profiles` hat **RLS enabled + FORCE RLS**.
- Policies sind owner-only für `authenticated` via `user_id = auth.uid()` (SELECT/INSERT/UPDATE/DELETE).
- Privileges: **kein anon/public Zugriff** (nur `authenticated`).

### cycle_data (bestehend, erweitert)
- `public.cycle_data` bleibt owner-only über bestehende Policies.
- Neuer Enum-ähnlicher CHECK für `cycle_regularity` (nullable; Werte: `regular|unpredictable|unknown`).

### daily_plan (Hardening)
- `public.daily_plan` wird auf **FORCE RLS** gehärtet und `anon`-Table-Privileges werden entzogen (Defense-in-depth).

### log_consent_if_allowed (Hardening)
- `public.log_consent_if_allowed(...)` wird von `public/anon` entprivilegiert (EXECUTE), bleibt für `authenticated` ausführbar (Owner-Guard: `p_user_id == auth.uid()`; kein `service_role`-Bypass; `service_role` EXECUTE entzogen via Patch-Migration).

## Logging / Telemetry (PII-Safety)
- Keine PII/Health-Daten in App-Logs oder Edge-Logs ausgeben.
- `log_consent` nutzt pseudonymisierte Metriken (`ip_hash`, `ua_hash`, `consent_id_hash`) und speichert in der DB nur `user_id/version/scopes`.

## Evidence (RLS + Gates)
### Migrationen
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

### RLS Smoke (Soll-Ausgabe)
- Option A (ohne `SUPABASE_DB_URL`, empfohlen): `.env.local` + `SUPABASE_PROJECT_REF` + `SUPABASE_DB_PASSWORD`
  - `set -a; source .env.local; set +a`
  - `PGPASSWORD="$SUPABASE_DB_PASSWORD" psql "postgresql://postgres@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres?sslmode=require" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke.sql`
  - `PGPASSWORD="$SUPABASE_DB_PASSWORD" psql "postgresql://postgres@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres?sslmode=require" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke_negative.sql`
- Option B (falls vorhanden): `psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke.sql` (+ `_negative.sql`)
  - Erwartung: `profiles baseline must return zero rows without context` ✅
  - Erwartung: Insert/Select unter `ROLE authenticated` und `request.jwt.claims.sub=<user>` ✅

### Security Note for Shell Commands
> **Warning:** Commands using `PGPASSWORD` or database credentials can leak into shell history.
>
> **Mitigations:**
> - Prefix sensitive commands with a space (requires `HISTCONTROL=ignorespace` in bash)
> - Use a `.pgpass` file instead of `PGPASSWORD` environment variable
> - Run tests in a disposable shell session or container
> - Clear history after testing: `history -c` (bash) or `fc -p` (zsh)

## Risks & Mitigations
- **Mehr Persistenz von PII (Name/Geburtsdatum):** `birth_date` ist erforderlich, sobald Onboarding abgeschlossen ist; Zugriff owner-only; DB-CHECK erzwingt 16–120 (gate-sicher) und verhindert „completed ohne birthdate“.
- **Cross-device Konsistenz:** serverseitige Gate-SSOT verhindert lokale Drift zwischen Geräten.

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

**Failure Handling:**
- On persistent failure: Manual retry via UI (max 3 manual retries)
- No background sync queue (not implemented)
- App remains functional with cached local state

- **Abuse/Noise durch anon RPC:** EXECUTE-Revokes reduzieren Angriffsfläche und vermeiden DB-Fehler-Spam.

## Backout / Revert (operational)

### Database Changes
- Drop `profiles` table: `DROP TABLE IF EXISTS public.profiles;`
- Drop `cycle_regularity` column: `ALTER TABLE public.cycle_data DROP COLUMN IF EXISTS cycle_regularity;`
- Restore `log_consent_if_allowed` EXECUTE grants (nur falls benötigt) per neuem Revert-Migration-File.

### Data Migration Considerations
**Note:** Data migrated from SharedPreferences to the server will be lost on rollback.
This is acceptable because:
1. Users can re-complete onboarding after revert
2. No critical user data is lost (only onboarding preferences)
3. Consent records in `public.consents` remain intact (audit trail preserved)

**Pre-revert checklist:**
- [ ] Take DB snapshot before executing DROP statements
- [ ] Verify snapshot integrity and accessibility
- [ ] Verify no active user sessions during revert window
- [ ] **Notify affected users of the rollback (MANDATORY)**
  - [ ] Send notification via in-app message and email within 24 hours
  - [ ] Include: rollback reason, data impact summary, re-onboarding steps
  - [ ] Provide support contact for questions
  - [ ] Log notification delivery confirmation
