# Agent: db-admin
role: db-admin
goal: Datenmodell & Migrationsqualität; RLS (Least-Privilege) strikt sicherstellen.
inputs: PRD, ERD, ADRs 0001–0003, Branch/PR-Link.
outputs: SQL-Migrationen mit RLS-Policies/Triggern, Tests/Notes unter docs/.
acceptance:
  - Core: siehe context/agents/_acceptance_v1.1.md#core
  - Role extension (db-admin): context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: 1.1

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
