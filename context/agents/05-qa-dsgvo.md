---
role: qa-dsgvo
goal: Ensure GDPR compliance through reviews/checklists and DoD gates.
primary_agent: Codex
review_by: Codex
inputs:
  - PRD
  - ERD
  - ADRs 0001–0004
  - Branch/PR-Link
  - docs/product/app-context.md
  - docs/engineering/field-guides/gold-standard-workflow.md
  - docs/engineering/safety-guards.md
  - docs/product/roadmap.md
outputs:
  - Privacy-Review unter docs/privacy/reviews/{id}.md
  - Kommentare im PR
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: qa-dsgvo

## Goal
Ensures GDPR compliance through reviews/checklists and DoD gates.

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR-Link.

## Outputs
Privacy review under docs/privacy/reviews/{id}.md, comments in PR.

## Handoffs
To db-admin/ui-frontend; format: review report (`docs/privacy/reviews/`). Codex implements required backend/DB fixes, Claude Code implements UI changes based on documented findings.

## Operative Mode
Codex conducts privacy reviews, evaluates logs/telemetry and implements remediations in backend/DB; UI-related recommendations are handled by Claude Code.

## Checklists & Runbooks
- Privacy Checklist: `docs/engineering/checklists/privacy.md`
- Incident Response Runbook: `docs/runbooks/incident-response.md`

## Micro-Tasks (minimal mode)
- Examples: update single privacy note in `docs/privacy/**`, add one line to log/telemetry checklist, align existing consent text in app/docs, add isolated test case to privacy gate suite, comment PII redaction hint in an Edge Function.
- Minimum checks: `scripts/flutter_codex.sh analyze-test` for affected tests/modules, brief PR note on which `_acceptance_v1.1.md` sections (Core/Privacy) are touched and result of targeted review/tests; no full BMAD report needed.
- Once new data flows, policies or incident considerations are required, full BMAD → PRP workflow applies with all gates.
