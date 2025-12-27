# Privacy Review — 20251222 DB Drift Hardening (Grants + Constraints)

## Purpose
Diese Änderung behebt bestätigte DB-Drifts in Supabase/Postgres, um:
- Save-Retry-Loops im Onboarding zu verhindern (Constraint-Mismatch),
- Least-Privilege/Defense-in-depth (Grants) durchzusetzen,
- Birthdate-Policy (16–120) gate-sicher zu enforce’n **ohne** Bestandsdaten zu sprengen.

## Findings (Live-DB)
- `public.cycle_data` hatte zusätzliche CHECKs, die nicht im Repo sind:
  - `chk_period_duration` (<= 10)
  - `chk_cycle_length` (>= 21)
- `anon` und `authenticated` hatten unerwünscht breite Table-Privileges (u. a. `TRUNCATE`, `TRIGGER`, `REFERENCES`, `MAINTAIN`) auf sensitiven Tabellen.
- `public.profiles.birth_date` war nullable; mindestens eine Zeile war `has_completed_onboarding=true` bei `birth_date IS NULL` (Gate-Risiko).

## Changes (Repo SSOT)
### 1) cycle_data Constraint Drift
- Migration: `supabase/migrations/20251222112000_fix_cycle_data_constraint_drift.sql`
- Drop der driftigen Constraints (`chk_cycle_length`, `chk_period_duration`), sodass wieder die SSOT-Bounds gelten:
  - `cycle_length` > 0 und <= 60
  - `period_duration` > 0 und <= 15

### 2) Least-Privilege Grants + Default Privileges
- Migration: `supabase/migrations/20251222112100_harden_table_grants_least_privilege.sql`
- Für `profiles`, `consents`, `cycle_data`, `email_preferences`, `daily_plan`:
  - `REVOKE ALL` von `anon`, `authenticated`, `PUBLIC`
  - `GRANT SELECT, INSERT, UPDATE, DELETE` an `authenticated` (+ `service_role` für Ops)
- Root Cause Fix: `ALTER DEFAULT PRIVILEGES` in Schema `public`:
  - **Applied:** Defaults für den ausführenden Owner-Role-Kontext (typisch `postgres`) werden gehärtet.
  - **Best-effort:** Für `supabase_admin` wird der Fix versucht; wenn die DB-Connection keine Rechte hat, wird nur ein `NOTICE` geloggt (kein Migration-Fail).
  - Verifikation via `pg_default_acl` empfohlen (siehe Evidence).

### 3) Birthdate required when onboarding complete
- Migration: `supabase/migrations/20251222112200_profiles_birth_date_gate_constraint.sql`
- Repair/Backfill:
  - Wenn `has_completed_onboarding=true` aber `birth_date` fehlt/invalid → setze `has_completed_onboarding=false` und `onboarding_completed_at=NULL`.
- CHECK:
  - Wenn `has_completed_onboarding=true` → `birth_date` NOT NULL und innerhalb `[today-120y, today-16y]`.

## Evidence / Proof
- Smoke (positive + grants): `supabase/tests/rls_smoke.sql`
- Smoke (negative constraints): `supabase/tests/rls_smoke_negative.sql`
- Run (recommended, no `SUPABASE_DB_URL` required):
  - `set -a; source .env.local; set +a`
  - `PGPASSWORD="$SUPABASE_DB_PASSWORD" psql "postgresql://postgres@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres?sslmode=require" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke.sql`
  - `PGPASSWORD="$SUPABASE_DB_PASSWORD" psql "postgresql://postgres@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres?sslmode=require" -v ON_ERROR_STOP=1 -P pager=off -f supabase/tests/rls_smoke_negative.sql`
- Default-ACL Check (optional): `SELECT defaclrole::regrole, defaclnamespace::regnamespace, defaclobjtype, defaclacl FROM pg_default_acl WHERE defaclnamespace = (SELECT oid FROM pg_namespace WHERE nspname='public') AND defaclobjtype='r';`

## Backout / Undo (operational snippets)
```sql
-- 1) Re-add drift constraints (nur falls unbedingt nötig; nicht empfohlen)
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

-- 3) Re-open broad grants (nicht empfohlen; nur zum Debuggen)
GRANT ALL ON TABLE public.consents TO anon, authenticated;
GRANT ALL ON TABLE public.cycle_data TO anon, authenticated;
GRANT ALL ON TABLE public.email_preferences TO anon, authenticated;
GRANT ALL ON TABLE public.profiles TO authenticated;

-- 4) Re-open broad DEFAULT PRIVILEGES (nicht empfohlen; nur zum Debuggen)
-- Hinweis: Das ist ein globaler Hebel. Vorher Zustand prüfen via:
--   SELECT defaclrole::regrole, defaclnamespace::regnamespace, defaclobjtype, defaclacl FROM pg_default_acl;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
```

## Known Limitation (Ops)
- Wenn `supabase db push` nicht berechtigt ist, `ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin ...` auszuführen, bleiben Default-ACLs für `supabase_admin` ggf. breit.
- In dem Fall: Default-ACLs für `supabase_admin` separat (mit entsprechend privilegiertem DB-Owner) härten:
```sql
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public REVOKE ALL ON TABLES FROM anon, authenticated, service_role, PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated, service_role;
```
