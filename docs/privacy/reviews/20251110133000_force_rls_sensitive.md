# Privacy Review — 20251110133000_force_rls_sensitive.sql

## Change

Force Row-Level Security on the following sensitive tables:
- `public.consents`
- `public.cycle_data`
- `public.email_preferences`

Statements stay idempotent via `ALTER TABLE IF EXISTS ... FORCE ROW LEVEL SECURITY;`.

## Data Impact

- No new tables or columns.
- No additional data access; enforcement only ensures existing RLS is always applied.

## Purpose / Risk

- Hardening: removes the residual owner bypass by forcing RLS even for table owners.
- Risk reduction: prevents accidental full-table reads or writes in owner contexts.

## RLS / Access Control

- Existing owner policies remain; `FORCE RLS` ensures every request is evaluated by RLS.

## DPIA / GDPR

- Processing scope is unchanged; no new recipients or transfers introduced.

## Evidence

- Dry-run (CI): `supabase db push --dry-run` reports only the `ALTER TABLE ... FORCE RLS` statements.
- Smoke (dev): `psql -f supabase/tests/rls_smoke.sql` confirms unauthorized contexts are blocked while owners read only their own rows.

## Undo

Rollback `FORCE ROW LEVEL SECURITY` if required so operators can revert quickly:
```sql
ALTER TABLE IF EXISTS public.consents NO FORCE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.cycle_data NO FORCE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.email_preferences NO FORCE ROW LEVEL SECURITY;
```

## Result

✅ Privacy-neutral hardening (improved access control); no further action required.
