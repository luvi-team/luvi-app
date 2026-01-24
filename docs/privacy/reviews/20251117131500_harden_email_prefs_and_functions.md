# Privacy Review — 20251117131500_harden_email_prefs_and_functions

## Change
- Pin `search_path` for optional helper/Archon functions via a DO-Block with `IF EXISTS` checks.
- Update the four `email_preferences` policies to use `(user_id = (SELECT auth.uid()))`.
- Add an `IF NOT EXISTS` index on `public.archon_tasks(parent_task_id)`.

## Data Impact
- **No new tables/columns**
- **No additional data read/write paths**
- Trigger and helper function bodies remain unchanged.

## Purpose / Risk
- Hardening: protects against `search_path` hijacking and migration failures when optional functions are missing.
- Reduces RLS overhead by avoiding per-row `auth.*()` calls.
- Risk: no functional privacy risk; RLS semantics remain unchanged.

## RLS / Access Control
- Owner-based RLS on `email_preferences` (`user_id = auth.uid()`) remains in place.
- Policies now use the subquery pattern `(SELECT auth.uid())` per Supabase RLS best practices.

## DPIA/DSGVO
- No change to processing scope or data categories.
- No new processors/transfers.

## Result
- ✅ Privacy- and security-hardening migration; no further action required.
