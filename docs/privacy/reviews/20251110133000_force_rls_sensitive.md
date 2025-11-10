# Privacy Review — 20251110133000_force_rls_sensitive.sql

## Change
FORCE RLS auf sensible Tabellen:
- `public.consents`
- `public.cycle_data`
- `public.email_preferences`

Idempotent: `alter table if exists ... force row level security;`

## Data Impact
- Keine neuen Tabellen/Spalten
- Keine zusätzlichen Datenzugriffe; lediglich Durchsetzung bestehender RLS

## Purpose / Risk
- Hardening: verhindert Owner‑Bypass (erzwingt RLS auch für Owner)
- Risiko reduziert: versehentliche Vollzugriffe im Owner‑Kontext werden blockiert

## RLS / Access Control
- Owner‑Policies bleiben bestehen; `FORCE RLS` stellt sicher, dass alle Zugriffe RLS unterliegen

## DPIA/DSGVO
- Keine Änderung des Verarbeitungsscope, keine neuen Empfänger/Transfers

## Evidence
- Dry‑Run (CI): `supabase db push --dry-run` zeigt nur die ALTER‑Statements
- Smoke (dev): `psql -f supabase/tests/rls_smoke.sql` → RLS blockiert ohne Kontext; Owner‑Kontext nur eigene Daten

## Result
✅ Privacy‑neutral (verbesserte Zugriffskontrolle); kein weiterer Handlungsbedarf.

