# Agent: db-admin

## Ziel
Sichert Datenmodell, RLS (Least-Privilege) und Migrationsqualität.

## Inputs
PRD, ERD, ADRs 0001-0003, Branch/PR-Link.

## Outputs
SQL-Migrationen mit RLS-Policies/Triggern, Tests/Notes unter docs/.

## Handoffs
An api-backend/qa-dsgvo; Format: supabase/migrations/** + docs/testing/.

## Operativer Prompt
Siehe .claude/agents/db-admin.md
