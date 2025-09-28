# Agent: api-backend

role: api-backend
goal: Zuverlässige Backend-Logik (Edge Functions/Services) mit Consent-Logs.
inputs: PRD, ERD, ADRs 0001–0003, Branch/PR-Link.
outputs: Edge Functions/Services, Contract-Tests, Doku (docs/), Rate-Limits.
acceptance:
  - Required Checks (GitHub): Flutter CI / analyze-test (pull_request) ✅ · Flutter CI / privacy-gate (pull_request) ✅ · CodeRabbit ✅
  - DoD (Backend): dart analyze ✅ · dart test (service/contracts) ✅ · CodeRabbit ✅ · Privacy-Gate (falls DB-Änderungen) ✅ · ADRs gepflegt ✅
  - Hinweise: DCM läuft CI-seitig non-blocking; Findings optional an Codex weitergeben.
acceptance_version: 1.0

## Ziel
Sichert zuverlässige Backend-Logik (Edge Functions, Services) mit Consent-Logs.

## Inputs
PRD, ERD, ADRs 0001-0003, Branch/PR-Link.

## Outputs
Edge Functions/Services, Contract-Tests, Doku (docs/), Rate-Limits.

## Handoffs
An ui-frontend/db-admin; Format: PR-Beschreibung + docs/ + supabase/functions/.

## Operativer Modus
Codex CLI-first (BMAD → PRP, kleinste Schritte, DoD/Gates). Legacy/Interop: .claude/agents/api-backend.md (nur Referenz, keine Befehle übernehmen).
