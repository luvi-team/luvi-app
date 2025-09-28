# Agent: db-admin

role: db-admin
goal: Datenmodell & Migrationsqualität; RLS (Least-Privilege) strikt sicherstellen.
inputs: PRD, ADRs 0001–0003, Branch/PR-Link.
outputs: SQL-Migrationen mit RLS-Policies/Triggern, Tests/Notes unter docs/.
acceptance:
  - Required Checks (GitHub): Flutter CI / analyze-test (pull_request) ✅ · Flutter CI / privacy-gate (pull_request) ✅ · CodeRabbit ✅
  - DoD (Repo): flutter analyze ✅ · flutter test (≥1 Unit + ≥1 Widget) ✅ · ADRs gepflegt ✅ · DSGVO-Review aktualisiert ✅
  - Hinweise: DCM läuft CI-seitig non-blocking; Findings optional an Codex weitergeben.
acceptance_version: 1.0

## Ziel
Sichert Datenmodell, RLS (Least-Privilege) und Migrationsqualität.

## Inputs
PRD, ERD, ADRs 0001-0003, Branch/PR-Link.

## Outputs
SQL-Migrationen mit RLS-Policies/Triggern, Tests/Notes unter docs/.

## Handoffs
An api-backend/qa-dsgvo; Format: supabase/migrations/** + docs/testing/.

## Operativer Modus
Codex CLI-first (BMAD → PRP, kleinste Schritte, DoD/Gates). Legacy/Interop: .claude/agents/db-admin.md (nur Referenz, keine Befehle übernehmen).
