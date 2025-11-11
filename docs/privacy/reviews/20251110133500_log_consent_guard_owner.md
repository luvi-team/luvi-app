# Privacy Review — 20251110133500_log_consent_guard_owner.sql

## Change
Logikwechsel von „geplanter DB-Funktion“ hin zu einem Edge-Guard:
- Die Edge Function `log_consent` ruft `supabase.auth.getUser()` auf und setzt `user_id = auth.uid()`.
- Falls der Body eine fremde `user_id` mitliefert, antwortet die Edge Function mit `403 Forbidden`.
- Schreibversuche ohne gültigen JWT enden mit `401 Unauthorized`.
- RLS (`WITH CHECK user_id = auth.uid()`) bleibt aktiv und liefert im DB-Pfad weiterhin `42501`, falls jemand später versucht, fremde Daten zu schreiben.
- Eine eigenständige DB-Funktion `public.log_consent_if_allowed` bleibt als zukünftiges Hardening dokumentiert.

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
- Edge Function Response:
  - 401 ohne Authorization-Header.
  - 403 bei `body.user_id != auth.uid()`.
  - 201 mit `user_id = auth.uid()` bei gültiger Einwilligung.
- RLS-Smokes (`supabase/tests/rls_smoke.sql`) belegen, dass der DB-Pfad weiterhin `42501` liefert, wenn eine fremde `user_id` eingesetzt wird.

## Result
✅ Sofort wirksamer Owner-Guard (403 an der Edge) plus bestehende RLS-Erzwingung im DB-Pfad. Defense-in-depth durch eine DB-Funktion bleibt als Option für spätere Sprints erhalten.
