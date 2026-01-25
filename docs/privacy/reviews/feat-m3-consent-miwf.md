# Privacy Review: Consent Logging MIWF v1.0

**Purpose:** Implement consent logging with MIWF approach for GDPR compliance

**Endpoint:** `POST /functions/v1/log_consent`
**Payload:** `{version: string, scopes: string[]}`

### Database Schema

**API Payload:** `{version: string, scopes: string[]}`
**Database Schema:** `{user_id, version, scopes, created_at, revoked_at}`

> Note: `user_id`, `created_at`, and `revoked_at` are server-managed fields and are **not** part of the client payload.

### Payload Validation

| Field | Constraint | Error Response |
|-------|-----------|----------------|
| `version` | Required, format `v{major}` or `v{major}.{minor}` (regex: `^v\d+(?:\.\d+)?$`) | 400 `invalid_version_format` |
| `scopes` | Required array, max 50 items | 400 `scopes_limit_exceeded` |
| `scopes[*]` | Max 100 chars per scope string | 400 `scope_too_long` |
| `scopes[*]` | Must match known scope IDs | 400 `unknown_scope` |
| Payload | Max 64KB JSON | 413 `payload_too_large` |
| Content-Type | Must be `application/json` | 415 `unsupported_media_type` |

**Known Scope IDs:** `terms`, `health_processing`, `analytics`, `marketing`, `ai_journal`, `model_training`

**Example Valid Payload:**
```json
{
  "version": "v1.0",
  "scopes": ["terms", "health_processing", "analytics"]
}
```

### Version Validation Flow & Mismatch Handling

**Validation Architecture**: Multi-layer validation ensures version consistency:

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│ Dart Client │────▶│ Edge Function│────▶│   Database   │
│             │     │  (validate)  │     │   (store)    │
└─────────────┘     └──────────────┘     └──────────────┘
     │                     │                     │
     │ ConsentConfig      │ version_parser.ts   │ version column
     │ .currentVersion    │ parseVersion()      │ (text)
     │ "v1.0"             │ ✓ format check      │
     └────────────────────┴─────────────────────┘
```

**Layer 1 - Client-Side (Dart)**:
- Location: `lib/core/privacy/consent_config.dart`
- Validation: `ConsentConfig.assertVersionFormatValid()` called at app startup
- Utility: `lib/core/privacy/version_parser.dart`
- Failure: App throws `StateError` during initialization

**Layer 2 - Edge Function (TypeScript)**:
- Location: `supabase/functions/log_consent/index.ts` (after line 539)
- Validation: Format checked using `_shared/version_parser.ts`
- Failure: Returns 400 `invalid_version_format` with error message
- No database insertion on validation failure

**Layer 3 - Database**:
- No format validation at DB level (version stored as text)
- Relies on Edge Function validation for data quality

**Audit Logging**:

| Outcome | Log Level | Fields | Location |
|---------|-----------|--------|----------|
| Success | `info` | `consent_id_hash`, `version`, `scope_count`, `duration_ms` | Line 775-779 |
| Invalid version | `warning` | `reason: "invalid_version_format"`, `version`, `error` | Validation block |
| Rate limited | `warning` | `consent_id_hash`, `window_sec`, `max`, `burst_max` | Line 729-738 |

**Pseudonymization**: All logs use `consent_id_hash` (HMAC-SHA256 of user_id) instead of raw user_id (ADR-0005).

**Error Contract - Invalid Version**:
```json
{
  "error": "invalid_version_format",
  "message": "Invalid version format: \"1.0\". Expected format: v{major} or v{major}.{minor}",
  "request_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Client Handling Guidelines**:
1. **Prevention**: Always use `ConsentConfig.currentVersion` (validated at startup)
2. **Detection**: Check response status:
   - 201 → Success
   - 400 + `invalid_version_format` → Client bug
   - 401 → Auth issue
   - 429 → Rate limited
3. **Recovery**: Log error, surface generic message, DO NOT retry with modified version
4. **Monitoring**: Track 400 responses to detect client bugs

**Shared Validation Contract**:

Both Dart and TypeScript use identical regex: `^v(\d+)(?:\.(\d+))?$`
- Dart: `lib/core/privacy/version_parser.dart`
- TypeScript: `supabase/functions/_shared/version_parser.ts`
- CI: Both test suites run in CI workflow

**Security:** RLS owner-based policies enforced; user_id set via DB trigger; ANON key only (no service_role)

**Rate Limiting & Abuse Controls:**
- **Per-user limit:** 5 requests/minute (configurable via `CONSENT_RATE_LIMIT_MAX_REQUESTS`) *
- **Burst allowance:** +3 requests/window (configurable via `CONSENT_RATE_LIMIT_BURST`) *
- **Per-IP limit:** 30 requests/minute (ANON key context) *
- **Abuse detection:** IP throttling with exponential backoff (1s → 2s → 4s → block 5min)
- **Monitoring:** Consent logging metrics exposed via Supabase observability (request count, error rate, latency)
- **Enforcement:** RLS owner-based policies + Edge Function request validation

> Note: Rate limits enforced at Edge Function level before DB trigger executes.
> *Values are initial estimates; adjust based on production monitoring data and tune burst behavior in production.

**Evidence:** Tested with curl for two users - write and read operations verified; created_at timestamp auto-populated

**Versioning:** version='v1.0' for initial release; scopes stored as JSON array

**Data Minimization:** Only version, scopes, and user_id collected; user_id is personal data under GDPR and stored only in database records (not application logs); any diagnostic logging must hash/redact user identifiers per ADR-0005

## Retention Policy

- **Retention Period:** Pending legal counsel review (estimated range: 3-7 years based on GDPR Art. 5(1)(e) and German BGB §195)
- **Legal Basis:** GDPR Art. 5(1)(e) storage limitation, Art. 7(1) proof of consent, Art. 17(3)(b) exemption for legal claims
- **EDPB Guidance:** Consent records may be retained as long as necessary to demonstrate compliance (EDPB Guidelines 05/2020)
- **Legal Review Status:** PENDING - Exact retention period requires GDPR-qualified legal counsel approval
- **Factors for Legal Review:**
  - German BGB §195 standard limitation period (3 years)
  - GDPR Art. 17(3)(b) exemption for legal claims
  - Regulatory inquiry retention requirements
  - Cross-border litigation considerations for EU member states
  - Industry best practices for health data consent records
- **Post-Retention:** Records are deleted or pseudonymized (UUID → HMAC-SHA256 hash) once retention period expires
- **Extended Retention:** Period extends if active legal claims or regulatory investigations exist
- **Archiving:** Consent logs are not actively deleted during retention period; on account deletion an anonymized audit trail is retained

### Immutability Clarification

Consent records follow an **append-only model** with one documented exception for GDPR compliance:

| Field | Mutability | On Account Deletion |
|-------|------------|---------------------|
| `version` | Immutable | Unchanged |
| `scopes` | Immutable | Unchanged |
| `created_at` | Immutable | Unchanged |
| `user_id` | **Pseudonymized** | UUID → HMAC-SHA256(secret_key, UUID); secret key stored separately with access controls |

**Rationale:** Pseudonymization of `user_id` satisfies GDPR Art. 17 erasure requirements while preserving the anonymized audit trail required by Art. 7(1). This is an in-place update to `user_id` only, not a compensating event.

**Cryptographic Irreversibility:** HMAC-SHA256 with a secret key (stored separately per GDPR Art. 4(5)) is a one-way keyed hash function. Without access to the separately-protected secret key, re-identification is infeasible. This ensures pseudonymized records cannot be re-linked to the original user, satisfying GDPR Art. 4(5) pseudonymization and maintaining audit trail integrity per Art. 7(1).

#### Secret Key Management
- **Storage:** Store the HMAC secret in a secure secrets manager (e.g., Supabase Vault, KMS-backed encrypted env var).
- **Access:** Only the Edge Function runtime and limited ops roles; enforce RBAC and audit access.
- **Rotation:** Follow `docs/runbooks/key-rotation-runbook.md`. Steps: enable dual-hash support (accept old + new), stage rollout (deploy code, then rotate secret), run verification tests (sample re-hash + consent access), and write an audit log entry. **Rollback:** re-enable old key, keep dual-hash during rollback window, re-run verification tests, and log the rollback reason in the audit trail.
- **Backup/Recovery:** Store encrypted backups in the secrets manager with access logging; verify restore quarterly. **Recovery:** restore the last known-good key, re-run verification tests, and document the incident. Losing the key makes existing pseudonymized `user_id` values irreversible, so recovery must be treated as a P1 runbook.

### Legal Compliance Checklist

**Retention Policy Review (Required before production):**
- [ ] Retention period reviewed by GDPR-qualified legal counsel
- [ ] Retention policy approved for German jurisdiction (BGB §195 compliance)
- [ ] Cross-border retention obligations verified for all EU member states
- [ ] Health data special category handling confirmed (GDPR Art. 9)
- [ ] Review completed date: _________
- [ ] Legal reviewer name/firm: _________
- [ ] Approval documentation filed at: _________

**Status**: PENDING LEGAL REVIEW

## Data Subject Rights (DSAR)

### Access Request (Art. 15 GDPR)
- **Query:** `SELECT version, scopes, created_at FROM consents WHERE user_id = auth.uid()`
- **Return:** All consent entries with timestamp and scope list

### Erasure Request (Art. 17 GDPR)
- **Limitation:** Consent logs are exempt for proof-of-consent obligations (Art. 17(3)(b))
- **Alternative:** On complete account deletion, `user_id` is pseudonymized (UUID → hash)

### Rectification (Art. 16 GDPR)
- **Not applicable:** Consent events are immutable; corrections are made by creating a new consent entry

### Consent Withdrawal (Art. 7(3) GDPR)

**Endpoint:** `POST /functions/v1/withdraw_consent` (planned)
**Status:** Not yet implemented — tracked in Archon Project `0c3dd817-69cd-4791-ba70-a71485f6f80a` (Consent Flow Redesign v3)

**Mechanism:**
- Withdrawal is recorded as a **new append-only row** in `consents` table
- Schema: see **Database Schema** section above (server-managed fields included)
- Active consent determined by: latest entry per scope, then check `revoked_at` on that newest row

**Processing Logic (Planned Implementation):**
```sql
-- Active consent check (per scope, optimized with user pre-filter)
-- Index: idx_consents_user_id_created_at exists (created in migration 20251103113000)
-- Index definition: CREATE INDEX idx_consents_user_id_created_at ON consents(user_id, created_at DESC)
WITH user_consents AS (
  -- Pre-filter: Only this user's consent records
  SELECT id, scopes, created_at, revoked_at
  FROM consents
  WHERE user_id = auth.uid()
),
latest_per_scope AS (
  SELECT DISTINCT ON (s.value)
    s.value AS scope_name,
    uc.created_at,
    uc.revoked_at
  FROM user_consents uc
  CROSS JOIN LATERAL jsonb_array_elements_text(uc.scopes) AS s(value)
  ORDER BY s.value, uc.created_at DESC
)
SELECT *
FROM latest_per_scope
WHERE scope_name = $1
  AND revoked_at IS NULL;
```

**Impact on Services:**
- Processing for withdrawn scopes must stop immediately
- Dependent features should gracefully degrade (e.g., disable analytics if `analytics` scope withdrawn)
- Backfill revocation events for audit trail if needed

**Example Flow:**
1. User withdraws `analytics` scope
2. System inserts: `{version: 'v1.0', scopes: ['analytics'], revoked_at: NOW()}`
3. Services check latest entry → find withdrawal → stop analytics processing

### Database Indexes

The following indexes support consent query performance:

| Index Name | Columns | Purpose | Migration | Status |
|------------|---------|---------|-----------|--------|
| `idx_consents_user_id_created_at` | `user_id, created_at DESC` | Sliding-window queries (user + temporal) | `20251103113000` | ✅ Deployed |
| `idx_consents_user_id` | `user_id` | User-scoped lookups | `20250903235538` | ✅ Deployed |
| `idx_consents_created_at` | `created_at` | Temporal ordering | `20250903235538` | ✅ Deployed |
| `idx_consents_revoked_at` | `revoked_at` (WHERE NOT NULL) | Revocation queries | `20250903235538` | ✅ Deployed |

**Query Coverage**: The composite index covers the consent withdrawal query pattern shown above (WHERE user_id = auth.uid() ORDER BY created_at DESC).

## Versioning & Audit

- `version='v1.0'` denotes the initial consent schema
- Schema changes require a new `version` string and a migration plan
- Old entries remain unchanged (append-only model)

### Schema Change Process

**Communication:**
1. Users notified via in-app banner before version bump
2. Changelog published in privacy policy update
3. Stakeholders notified via release notes

**Migration Checklist:**
- [ ] Update `supabase/functions/log_consent/consent_scopes.json` (Edge Function SSOT)
- [ ] Sync `config/consent_scopes.json` (Flutter asset) to match Edge Function version
- [ ] Update `ConsentConfig.currentVersion` in Dart code
- [ ] Create DB migration if schema changes needed
- [ ] Test backward compatibility with existing consent records
- [ ] Update privacy review documentation
- [ ] Deploy Edge Function with new validation rules

**Backward Compatibility:**
- New versions MUST accept existing scope IDs
- Removed scopes: mark as deprecated, continue accepting
- New scopes: optional until next major version

**Mixed-Version Handling:**
- System reads all versions, newest entry per scope wins
- Version negotiation: client sends current version, server validates
- Rollback: revert `ConsentConfig.currentVersion`, no data migration needed
- Monitoring: track version distribution via analytics
