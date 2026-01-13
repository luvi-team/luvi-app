---
role: db-admin
goal: Datenmodell & Migrationsqualität; RLS (Least-Privilege) strikt sicherstellen.
primary_agent: Codex
review_by: Codex
inputs:
  - PRD
  - ERD
  - ADRs 0001–0004
  - Branch/PR-Link
  - docs/product/app-context.md
  - docs/engineering/tech-stack.md
  - docs/engineering/field-guides/gold-standard-workflow.md
  - docs/engineering/safety-guards.md
outputs:
  - SQL-Migrationen mit RLS-Policies/Triggern
  - Tests/Notes unter docs/
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: db-admin

## Ziel
Sichert Datenmodell, RLS (Least-Privilege) und Migrationsqualität.

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR-Link.

## Outputs
SQL-Migrationen mit RLS-Policies/Triggern, Tests/Notes unter docs/.

## Handoffs
An api-backend/qa-dsgvo; Format: `supabase/migrations/**` + Notes. Backend-Services (Codex) konsumieren neue Schemas, UI-Anpassungen erfolgen durch Claude Code.

## Operativer Modus
Codex verantwortet Schema/Migration/RLS (Supabase MCP, BMAD → PRP). Claude Code greift nur auf dokumentierte Views/APIs zu und passt UI nach Backend-Signal an.

## Checklisten & Runbooks
- DB‑Checklist: `docs/engineering/checklists/db.md`
- RLS‑Debug Runbook: `docs/runbooks/debug-rls-policy.md`

## Micro-Tasks (minimaler Modus)
- Beispiele: bestehende View/Query leicht anpassen (keine neuen Tabellen), eine RLS-Predicate-Zeile korrigieren, bestehenden Trigger-Kommentar ergänzen, einzelne Migration um Default/Check erweitern, Test-Case in `supabase/tests` ergänzen.
- Mindest-Checks: gezielt `scripts/flutter_codex.sh analyze-test` für betroffene Datenpfade und Supabase-MCP-Checks, kurzer PR-Hinweis auf die relevanten `_acceptance_v1.1.md`-Abschnitte (RLS/Least-Privilege) und welche Migration/Test-Dateien liefen.
- Sobald Struktur- oder Policy-Neuentwicklungen nötig sind, zurück in den vollen BMAD → PRP-Prozess mit allen Gates.
