# Privacy Review: Consent Logging MIWF v1.0

**Purpose:** Implement consent logging with MIWF approach for GDPR compliance

**Endpoint:** `POST /functions/v1/log_consent`  
**Payload:** `{version: string, scopes: string[]}`

**Security:** RLS owner-based policies enforced; user_id set via DB trigger; ANON key only (no service_role)

**Evidence:** Tested with curl for two users - write and read operations verified; created_at timestamp auto-populated

**Versioning:** version='v1.0' for initial release; scopes stored as JSON array

**Data Minimization:** Only version and scopes collected; user_id from auth context; no PII in logs