# Privacy Review — 20251222 DB Drift Hardening (Grants + Constraints)

## Purpose
This change fixes confirmed DB drift in Supabase/Postgres to:
- prevent save/retry loops in onboarding caused by constraint mismatches,
- enforce least privilege / defense in depth for grants,
- enforce the birthdate policy (16–120) in a gate-safe way **without** breaking existing data.

## Findings (Live-DB)
- `public.cycle_data` had additional CHECK constraints that are not in the repo:
  - `chk_period_duration` (<= 10)
  - `chk_cycle_length` (>= 21)
- `anon` and `authenticated` had undesirably broad table privileges (e.g. `TRUNCATE`, `TRIGGER`, `REFERENCES`, `MAINTAIN`) on sensitive tables.
- `public.profiles.birth_date` was nullable; at least one row had `has_completed_onboarding=true` while `birth_date IS NULL` (gate risk).

## Changes (Repo SSOT)
### 1) cycle_data Constraint Drift
- Migration: `supabase/migrations/20251222112000_fix_cycle_data_constraint_drift.sql`
- Drop the drifted constraints (`chk_cycle_length`, `chk_period_duration`) so the SSOT bounds apply again:
  - `cycle_length` > 0 and <= 60
  - `period_duration` > 0 and <= 15

### 2) Least-Privilege Grants + Default Privileges
- Migration: `supabase/migrations/20251222112100_harden_table_grants_least_privilege.sql`
- For `profiles`, `consents`, `cycle_data`, `email_preferences`, `daily_plan`:
  - `REVOKE ALL` from `anon`, `authenticated`, `PUBLIC`
  - `GRANT SELECT, INSERT, UPDATE, DELETE` to `authenticated` (+ `service_role` for ops)
- Root cause fix: `ALTER DEFAULT PRIVILEGES` in schema `public`:
  - **Applied:** Harden defaults for the executing owner-role context (typically `postgres`).
  - **Best-effort:** Attempt the same for `supabase_admin`; if the DB connection lacks permissions, only a `NOTICE` is logged (no migration failure).
  - Verification via `pg_default_acl` is recommended (see Evidence).

### 3) Birthdate required when onboarding complete
- Migration: `supabase/migrations/20251222112200_profiles_birth_date_gate_constraint.sql`
- Repair/Backfill:
  - If `has_completed_onboarding=true` but `birth_date` is missing/invalid → set `has_completed_onboarding=false` and `onboarding_completed_at=NULL`.
- CHECK:
  - If `has_completed_onboarding=true` → `birth_date` NOT NULL and within `[today-120y, today-16y]`.

## Evidence / Proof
- Smoke (positive + grants): `supabase/tests/rls_smoke.sql`
- Smoke (negative constraints): `supabase/tests/rls_smoke_negative.sql`
- Run (recommended, no `SUPABASE_DB_URL` required):
  - `./supabase/tests/run_rls_smoke.sh` (sources `.env.local`; needs `SUPABASE_PROJECT_REF` + `SUPABASE_DB_PASSWORD`)
- Post-migration verification query (add to runbook): `SELECT defaclrole::regrole, defaclnamespace::regnamespace, defaclobjtype, defaclacl FROM pg_default_acl WHERE defaclnamespace = (SELECT oid FROM pg_namespace WHERE nspname='public') AND defaclobjtype='r';`

## Operations / Deployment
- Run the migrations in staging first, then run `./supabase/tests/run_rls_smoke.sh` and the verification query above; only then deploy to production.
- The workaround SQL in "Known Limitation" (the `ALTER DEFAULT PRIVILEGES ... FOR ROLE supabase_admin ...` statements) must be run by a DB owner / platform team member with the required role privileges (typically `postgres` / Supabase project owner); keep an audit trail (ticket id + who/when/why).
- Add automated monitoring/alerts after deploys: periodically query `pg_default_acl` and alert if defaults grant to `anon`, `authenticated`, or `PUBLIC`, or if defaults include `ALL` / `TRUNCATE` / `TRIGGER` on sensitive tables.

## Backout / Undo (Operational Snippets)
> **WARNING:** This section contains intentionally disabled examples of broad access re-opening (`GRANT ALL ...`, `ALTER DEFAULT PRIVILEGES ... GRANT ALL ...`). Do not copy/paste into production.

Security implications (why the disabled statements are dangerous):
- `GRANT ALL ON TABLE public.consents TO anon, authenticated;` → broad read/write *and* powerful privileges (e.g. `TRUNCATE`, `TRIGGER`, `REFERENCES`, `MAINTAIN`), enabling tampering with consent/audit data and expanding the attack surface.
- `GRANT ALL ON TABLE public.cycle_data TO anon, authenticated;` → exposes highly sensitive health/cycle data; also allows writes/deletes (and potentially `TRUNCATE`) beyond intended least-privilege.
- `GRANT ALL ON TABLE public.email_preferences TO anon, authenticated;` → may expose email/notification preferences and allows unauthorized modifications.
- `GRANT ALL ON TABLE public.profiles TO authenticated;` → grants broad access to PII (e.g. `birth_date`) and write access that can undermine RLS assumptions and data integrity.
- `ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;` → globally widens privileges for *future* tables; `service_role` (service account) inherits broad access; hard to audit/rollback and re-introduces drift after future changes.
- `ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;` → same global widening risk, plus requires elevated ownership and can silently re-introduce overly permissive defaults after `supabase db push`.

Safer alternatives (prefer these):
- Create a dedicated troubleshooting role and grant only what is needed (e.g. `GRANT SELECT ON TABLE public.consents TO luvi_troubleshoot;`), then `REVOKE`/`DROP ROLE` after.
- Prefer controlled `psql` sessions with `SET ROLE service_role` / `SET ROLE supabase_admin` (never client-facing roles) and explicit audit logging (ticket id + who/why/when).
- For debugging workflows, prefer `CREATE TEMP TABLE ...` / `CREATE TEMP VIEW ...` and avoid persistent grants.
```sql
-- 1) Re-add drift constraints (only if absolutely necessary; not recommended)
-- WARNING: These are the DRIFTED bounds (cycle_length 21-60, period_duration 1-10),
-- NOT the SSOT bounds (cycle_length > 0 && <= 60, period_duration > 0 && <= 15).
-- Only apply as emergency backout if absolutely necessary.
ALTER TABLE public.cycle_data
  ADD CONSTRAINT chk_cycle_length CHECK (cycle_length >= 21 AND cycle_length <= 60);
ALTER TABLE public.cycle_data
  ADD CONSTRAINT chk_period_duration CHECK (period_duration >= 1 AND period_duration <= 10);

-- 2) Revert birthdate gate constraint
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_birth_date_required_when_completed;

-- 3) Re-open broad grants (not recommended; debug-only)
-- DANGEROUS (DISABLED): Re-open broad grants. Do not execute unless you fully understand the implications.
-- GRANT ALL ON TABLE public.consents TO anon, authenticated;
-- GRANT ALL ON TABLE public.cycle_data TO anon, authenticated;
-- GRANT ALL ON TABLE public.email_preferences TO anon, authenticated;
-- GRANT ALL ON TABLE public.profiles TO authenticated;

-- 4) Re-open broad DEFAULT PRIVILEGES (not recommended; debug-only)
-- Note: This is a global lever. Inspect the current state first via:
--   SELECT defaclrole::regrole, defaclnamespace::regnamespace, defaclobjtype, defaclacl FROM pg_default_acl;
-- DANGEROUS (DISABLED): Re-open broad default privileges. This affects *future* objects created by these roles.
-- ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
-- ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
```

## Known Limitation (Ops)
- If `supabase db push` is not allowed to execute `ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin ...`, default ACLs for `supabase_admin` may remain overly permissive.
- In that case, harden default ACLs for `supabase_admin` separately (using a sufficiently privileged DB owner role):
- Ownership/permissions: this typically requires the Supabase project owner / platform team operating as `postgres` (or equivalent).
```sql
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON TABLES FROM anon, authenticated, service_role, PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated, service_role;
```
