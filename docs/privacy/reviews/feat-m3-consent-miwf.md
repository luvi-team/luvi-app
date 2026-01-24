# Privacy Review: Consent Logging MIWF v1.0

**Purpose:** Implement consent logging with MIWF approach for GDPR compliance

**Endpoint:** `POST /functions/v1/log_consent`  
**Payload:** `{version: string, scopes: string[]}`

**Security:** RLS owner-based policies enforced; user_id set via DB trigger; ANON key only (no service_role)

**Evidence:** Tested with curl for two users - write and read operations verified; created_at timestamp auto-populated

**Versioning:** version='v1.0' for initial release; scopes stored as JSON array

**Data Minimization:** Only version, scopes, and user_id collected; user_id is personal data under GDPR and stored only in database records (not application logs); any diagnostic logging must hash/redact user identifiers per ADR-0005

## Retention Policy

- **Retention Period:** Indefinite (legal obligation to retain proof of consent)
- **Rationale:** Art. 7(1) GDPR requires proof of consent; deletion would jeopardize compliance
- **Archiving:** Consent logs are not actively deleted; on account deletion an anonymized audit trail is retained

### Immutability Clarification

Consent records follow an **append-only model** with one documented exception for GDPR compliance:

| Field | Mutability | On Account Deletion |
|-------|------------|---------------------|
| `version` | Immutable | Unchanged |
| `scopes` | Immutable | Unchanged |
| `created_at` | Immutable | Unchanged |
| `user_id` | **Pseudonymized** | UUID → SHA-256 hash (one-way, irreversible) |

**Rationale:** Pseudonymization of `user_id` satisfies GDPR Art. 17 erasure requirements while preserving the anonymized audit trail required by Art. 7(1). This is an in-place update to `user_id` only, not a compensating event.

**Cryptographic Irreversibility:** SHA-256 is a one-way cryptographic hash function. Given only the hash output, it is computationally infeasible to recover the original `user_id` UUID. This ensures that pseudonymized records cannot be re-linked to the original user, satisfying GDPR Art. 4(5) pseudonymization requirements while maintaining the audit trail integrity mandated by Art. 7(1).

## Data Subject Rights (DSAR)

### Access Request (Art. 15 GDPR)
- **Query:** `SELECT version, scopes, created_at FROM consents WHERE user_id = auth.uid()`
- **Return:** All consent entries with timestamp and scope list

### Erasure Request (Art. 17 GDPR)
- **Limitation:** Consent logs are exempt for proof-of-consent obligations (Art. 17(3)(b))
- **Alternative:** On complete account deletion, `user_id` is pseudonymized (UUID → hash)

### Rectification (Art. 16 GDPR)
- **Not applicable:** Consent events are immutable; corrections are made by creating a new consent entry

## Versioning & Audit
- `version='v1.0'` denotes the initial consent schema
- Schema changes require a new `version` string and a migration plan
- Old entries remain unchanged (append-only model)