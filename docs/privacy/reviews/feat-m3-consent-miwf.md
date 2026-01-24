# Privacy Review: Consent Logging MIWF v1.0

**Purpose:** Implement consent logging with MIWF approach for GDPR compliance

**Endpoint:** `POST /functions/v1/log_consent`  
**Payload:** `{version: string, scopes: string[]}`

**Security:** RLS owner-based policies enforced; user_id set via DB trigger; ANON key only (no service_role)

**Evidence:** Tested with curl for two users - write and read operations verified; created_at timestamp auto-populated

**Versioning:** version='v1.0' for initial release; scopes stored as JSON array

**Data Minimization:** Only version and scopes collected; user_id from auth context; no PII in logs

## Retention Policy

- **Aufbewahrungsdauer:** Unbefristet (gesetzliche Nachweispflicht für Consent)
- **Begründung:** Art. 7(1) DSGVO verlangt Nachweis der Einwilligung; Löschung würde Compliance gefährden
- **Archivierung:** Consent-Logs werden nicht aktiv gelöscht; bei Account-Deletion bleibt anonymisierter Audit-Trail erhalten

## Data Subject Rights (DSAR)

### Access Request (Art. 15 DSGVO)
- **Abfrage:** `SELECT version, scopes, created_at FROM consents WHERE user_id = auth.uid()`
- **Rückgabe:** Alle Consent-Einträge mit Timestamp und Scope-Liste

### Erasure Request (Art. 17 DSGVO)
- **Einschränkung:** Consent-Logs sind für Nachweis-Pflichten ausgenommen (Art. 17(3)(b))
- **Alternative:** Bei vollständiger Account-Deletion wird `user_id` pseudonymisiert (UUID → Hash)

### Rectification (Art. 16 DSGVO)
- **Nicht anwendbar:** Consent-Events sind immutable; Korrektur erfolgt durch neuen Consent-Eintrag

## Versioning & Audit
- `version='v1.0'` bezeichnet initiales Consent-Schema
- Änderungen am Schema erfordern neuen `version`-String und Migration-Plan
- Alte Einträge bleiben unverändert (append-only model)