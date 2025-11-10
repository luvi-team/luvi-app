# Privacy Review — 20251110133500_log_consent_guard_owner.sql

## Change
Härtung der `public.log_consent_if_allowed(...)` Funktion:
- Erzwingt Owner‑Match: `IF p_user_id <> auth.uid() THEN RAISE EXCEPTION ... '42501'`
- Keine Änderung der Datenschemata; Security‑Invoker bleibt erhalten

## Data Impact
- Keine neuen Felder/Tabellen; Schreibpfad bleibt auf `public.consents`
- Fehlercode 42501 bei falschem Owner statt stiller Ablehnung → klareres Verhalten

## Purpose / Risk
- Hardening: Explizites Verbot fremder Writes, verkleinert Fehlkonfigurations‑Risiko
- Keine Erhöhung des Datenschutzrisikos; eher Reduktion

## RLS / Access Control
- RLS bleibt aktiv; Funktion schreibt weiterhin unter RLS (Invoker)
- Owner‑Check verhindert Missbrauch selbst bei fehlerhaften Caller‑Parametern

## DPIA/DSGVO
- Kein neuer Verarbeitungsvorgang, keine neuen Empfänger

## Evidence
- Unit/Smoke: erwarteter 42501 bei `p_user_id != auth.uid()`; OK bei Match

## Result
✅ Privacy‑neutral (Zugriffshärtung, klarere Fehlersemantik).

