---
role: api-backend
goal: Reliable backend logic (Edge Functions/Services) with consent logs.
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
  - Edge Functions/Services
  - Contract-Tests
  - Doku (docs/)
  - Rate-Limits (falls Endpunkt extern erreichbar, z. B. App-Client oder öffentlich)
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: api-backend

## Goal
Ensures reliable backend logic (Edge Functions, Services) with consent logs.

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR-Link.

## Outputs
Edge Functions/Services, contract tests, docs (docs/), rate limits (only for externally accessible endpoints).

## Handoffs
To ui-frontend/db-admin; format: PR description + `docs/` + `supabase/functions/`. UI adjustments consume documented contracts and are implemented by Claude Code.

## Operative Mode
Codex implements Edge Functions/Services, policies and tests per BMAD → PRP (Plan → Run → Prove; see [Governance](../../docs/bmad/global.md)); Claude Code adapts UI only after successful backend handoff.

## Checklists & Runbooks
- API Checklist: `docs/engineering/checklists/api.md`
- Health Check Runbook: `docs/runbooks/vercel-health-check.md`

## Micro-Tasks (minimal mode)
- Examples:
  - Small query/filter adjustment without schema change
  - Fix single log level/PII redaction
  - Extend existing Edge Function with a guard
  - Add single contract test case
  - Update privacy note in docs
- Minimum checks: `scripts/flutter_codex.sh analyze-test` against affected modules/tests, note in PR which acceptance points from `_acceptance_v1.1.md` are touched (e.g., Logging/Consent) and brief result of targeted tests.
- Once new endpoints, migrations or policies are affected, BMAD → PRP applies again (see [Governance](../../docs/bmad/global.md)) incl. full checks.
