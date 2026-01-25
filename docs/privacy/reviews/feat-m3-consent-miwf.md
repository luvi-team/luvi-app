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

- **Retention Period:** 7 years after consent withdrawal or last account activity
- **Legal Basis:** GDPR Art. 5(1)(e) storage limitation, Art. 7(1) proof of consent, German BGB §195 standard limitation period (3 years) + Art. 17(3)(b) exemption for legal claims
- **EDPB Guidance:** Consent records may be retained as long as necessary to demonstrate compliance (EDPB Guidelines 05/2020)
- **Rationale:** 7 years covers statute of limitations for contractual claims plus buffer for regulatory inquiries
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
- **Rotation:** Rotate on schedule (e.g., quarterly) and on incident; plan for re-pseudonymization or dual-hash support during transition.
- **Backup/Recovery:** Ensure secure backup of key material; losing the key makes existing pseudonymized `user_id` values irreversible.

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
-- Active consent check (per scope, assumes scopes stored as JSON string array)
WITH latest_per_scope AS (
  SELECT DISTINCT ON (scope_name)
    scope_name,
    user_id,
    scopes,
    created_at,
    revoked_at
  FROM consents
  CROSS JOIN LATERAL jsonb_array_elements_text(scopes) AS scope_name(scope_name)
  WHERE user_id = auth.uid()
  ORDER BY scope_name, created_at DESC
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
- [ ] Update `config/consent_scopes.json` with new version
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
