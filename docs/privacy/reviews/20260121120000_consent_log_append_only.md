# Privacy Review — 20260121120000_consent_log_append_only.sql

## Summary
- **Scope:** Supabase migration `supabase/migrations/20260121120000_consent_log_append_only.sql`
- **Purpose:** make `public.consents` an immutable audit trail (GDPR Art. 7(1))
- **Data impact:** no new tables/fields; only restricts UPDATE/DELETE paths for clients

## Change
- Drops UPDATE/DELETE RLS policies on `public.consents` (client can no longer update/delete consent rows).
- Revokes `UPDATE, DELETE` privileges on `public.consents` from the `authenticated` role.
- Adds a defense-in-depth UPDATE-blocking trigger `consent_no_update` via `public.prevent_consent_update()` (blocks UPDATE for all roles).
- Intentionally does **not** add a DELETE trigger:
  - deletion must remain possible for account deletion (`auth.users` → `public.consents` via `ON DELETE CASCADE`) and potential erasure/retention workflows,
  - while DELETE stays disallowed for authenticated clients via dropped policies + revoked privileges.

## Data Impact
- Consent records remain within the existing table: `public.consents` (existing columns include `user_id`, `version`, `scopes`, `created_at`, `revoked_at`).
- Scopes shape remains JSON object with boolean values (no schema change).
- No new categories of personal data, no new recipients, no new processing purpose.

## RLS / Access Control
- RLS remains enabled; removing UPDATE/DELETE policies shrinks the client attack surface.
- UPDATE is blocked even for privileged roles because the trigger fires for all roles (defense-in-depth).
- Operational note: admin/support corrections require a privileged workflow and (if needed) a temporary trigger disable (documented in the migration). This must **never** imply shipping `service_role` credentials in the client.

## GDPR / Legal Basis
- No change to legal basis; this strengthens evidence integrity for consent (Art. 7(1)).
- Technical hardening measure (Art. 32) that reduces consent tampering risk.

## Verification (CI / Staging)
- CI should continue to dry-run migrations via `scripts/db_dry_run.sh` (Supabase `db push --dry-run`).
- Manual SQL checks after applying the migration (see migration footer), expected outcomes:
  - UPDATE on `public.consents` → error: “Consent log is append-only… UPDATE is not allowed.”
  - DELETE as authenticated client → denied (RLS/privileges).
  - Policies list → only SELECT/INSERT for `public.consents`.

## Rollback
Not recommended (breaks GDPR audit integrity). See rollback section in `supabase/migrations/20260121120000_consent_log_append_only.sql`.

## Result
✅ Append-only consent audit log enforced; no new personal data collected; reduced tampering surface.

