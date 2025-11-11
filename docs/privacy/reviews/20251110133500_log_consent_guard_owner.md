# Privacy Review — 20251110133500_log_consent_guard_owner.sql

## Change
Harden the `public.log_consent_if_allowed(...)` function:
- Enforce owner match: `IF p_user_id <> auth.uid() THEN RAISE EXCEPTION ... '42501'`.
- No schema changes; the security invoker context stays as-is.

## Data Impact
- No new tables or fields; writes continue to target `public.consents`.
- Caller now receives `42501` for mismatched owners instead of a silent denial, giving clearer signals.

## Purpose / Risk
- Hardening: explicitly blocks cross-user writes, shrinking misconfiguration risk.
- No added privacy risk; enforcement strictly reduces possible exposure.

## RLS / Access Control
- RLS remains enabled; the function still executes with invoker security.
- The owner check prevents misuse even when callers pass incorrect `p_user_id`.

## DPIA / GDPR
- No new processing purpose or recipients introduced.

## Evidence
- Unit/smoke tests: expect `42501` when `p_user_id != auth.uid()`; happy path remains green.

## Result
✅ Privacy-neutral access hardening with clearer failure semantics.
