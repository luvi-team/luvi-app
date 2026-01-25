---
role: db-admin
goal: Data model & migration quality; strictly ensure RLS (Least-Privilege).
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

## Goal
Ensures data model, RLS (Least-Privilege) and migration quality.

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR-Link.

## Outputs
SQL migrations with RLS policies/triggers, tests/notes under docs/.

## Handoffs
To api-backend/qa-dsgvo; format: `supabase/migrations/**` + notes. Backend services (Codex) consume new schemas, UI adjustments are done by Claude Code.

## Operative Mode
Codex owns schema/migration/RLS (Supabase MCP, BMAD → PRP). Claude Code only accesses documented views/APIs and adapts UI after backend signal.

> **Definitions:**
> - **MCP:** Model Context Protocol
> - **BMAD:** Business Goals, Domain Modeling, Architecture Decisions, and Definition of Done.
> - **PRP:** Project Roadmap & Plan (execution phase following BMAD (Plan → Run → Prove)).

## Checklists & Runbooks
- DB Checklist: `docs/engineering/checklists/db.md`
- RLS Debug Runbook: `docs/runbooks/debug-rls-policy.md`

## Micro-Tasks (minimal mode)
- Examples: lightly adjust existing view/query (no new tables), correct one RLS predicate line, add existing trigger comment, extend single migration with default/check, add test case in `supabase/tests`.
- Minimum checks: targeted `scripts/flutter_codex.sh analyze-test` for affected data paths and Supabase MCP checks, brief PR note on relevant `_acceptance_v1.1.md` sections (RLS/Least-Privilege) and which migration/test files ran.
- Once structure or policy development is needed, back to full BMAD → PRP process with all gates.
