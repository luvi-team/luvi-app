# Privacy Review – Consent Index & UX Cycle Constraint (2025-11-16)

## Summary
- **Scope:** Supabase migrations `20251103113000`, `20251104120000`, `20251116120000`
- **Purpose:** harden consent logging (performance + atomicity) and enforce one `cycle_data` record per user for UX predictability.
- **Data impact:** no new attributes stored; operations remain within existing `consents` and `cycle_data` tables.

## Change Details
| Migration | Table/Function | Description | Personal Data Impact |
| --- | --- | --- | --- |
| `20251103113000_consents_user_id_created_at_idx.sql` | `consents` | Adds composite index `(user_id, created_at DESC)` for sliding-window queries. | None – purely structural for faster lookups. |
| `20251104120000_log_consent_atomic.sql` | `log_consent_if_allowed` function | Introduces per-user advisory lock & rate-limit guard before inserting to `consents`. | Uses existing `user_id`, `version`, `scopes`; no new fields. |
| `20251116120000_add_ux_cycle_data_user_constraint.sql` | `cycle_data` | Adds unique constraint `ux_cycle_data_user` ensuring 1:1 relation. | Prevents duplicate rows; no additional data collected. |

## Legal Basis & Purpose Limitation
- **Consent logs (`consents`):** Art. 6(1)(a) GDPR. Logs document the user’s granted scopes and legal versions. The atomic function enforces fairness (max requests / window) but does not widen purpose.
- **Cycle data (`cycle_data`):** continues to rely on explicit consent provided during onboarding (Art. 6(1)(a) + Art. 9(2)(a)). Unique constraint keeps the dataset accurate for hormone-phase UX.

## Retention & Access Control
- **Retention:** TTL already defined in `docs/privacy/consent_logs_ttl_policy.md` (12 months) and `consent_logs_risk_memo.md`. Index/function respect existing retention because they operate on the same table.
- **Access:** RLS + FORCE RLS already enforce `user_id = auth.uid()`. New function runs as `security invoker` and therefore inherits those constraints. Unique constraint does not change RLS rules on `cycle_data`.

## Risk Assessment
- **Performance index:** lowers response time for rate-limit checks, reducing chance of partial writes. No incremental privacy risk.
- **Atomic function:** Advisory lock prevents duplicate entries under concurrent load → mitigates log inconsistencies. Inputs validated; rejects malformed versions/scopes. Risk of denial-of-service via lock is mitigated by sliding window and by still requiring authenticated session.
- **Unique constraint:** prevents corrupted UX state (multiple cycle entries). In worst case, conflicting duplicates must be resolved manually before constraint is added (migration is idempotent and checks existing index name).

## Rollback Plan
- Drop index `idx_consents_user_id_created_at` if required: `DROP INDEX IF EXISTS idx_consents_user_id_created_at;`
- Revert function via previous definition stored in Git history (`git checkout <prev> supabase/migrations/20251104120000_log_consent_atomic.sql`). Deployment through standard Supabase migration rollback.
- Drop constraint `ux_cycle_data_user` using `ALTER TABLE public.cycle_data DROP CONSTRAINT IF EXISTS ux_cycle_data_user;` (only if duplicate rows must be re-allowed temporarily).

## Verification / Manual Tests
- `scripts/db_dry_run.sh` executed in CI (Supabase DB Dry-Run) – ensures migrations apply cleanly.
- `log_consent_if_allowed` contract tests keep asserting 401/403/201 flows.
- App integration tests (`test/features/consent/...` and `test/services/user_state_service_test.dart`) confirm no behavioral regressions.

## Reviewer Notes
- No new categories of sensitive data introduced.
- Continue to monitor consent log rate-limit metrics to ensure advisory lock does not become a bottleneck.
