---
role: dataviz
goal: Performant, understandable visualizations with clear explanatory texts.
primary_agent: Claude Code
review_by: Codex
inputs:
  - PRD
  - ERD
  - ADRs 0001–0004
  - Branch/PR-Link
  - docs/product/app-context.md
  - docs/engineering/tech-stack.md
  - docs/product/roadmap.md
  - docs/engineering/assistant-answer-format.md
outputs:
  - Chart widgets
  - Tests
  - Documentation (docs/)
  - Clear axes/legends
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: dataviz

## Goal
Ensures performant, understandable visualizations and meaningful explanatory texts.

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR-Link.

## Outputs
Chart widgets, Tests, Documentation (docs/), Clear axes/legends.

## Handoffs
PRs to ui-frontend/Product + Codex review: PR description + `docs/` + charts. Codex checks architecture, state management and privacy before merge.

## Operative Mode
Claude Code implements charts/widgets/tests per BMAD-slim, Codex reviews every change for consistency and GDPR compliance (analyze/test via `scripts/flutter_codex.sh`).

## Checklists & Runbooks
- Claude Code UI Checklist (navigation/tokens/L10n rules): `docs/engineering/checklists/ui_claude_code.md`
- DataViz Checklist: `docs/engineering/checklists/dataviz.md`
- Analytics Taxonomy: `docs/analytics/taxonomy.md`
- Chart A11y Checklist: `docs/analytics/chart-a11y-checklist.md`
- Backfill Runbook: `docs/runbooks/analytics-backfill.md`

## Micro-Tasks (minimal mode)
- Examples:
  - Correct copy/L10n in chart legends via ARB
  - Adjust spacing/radius in existing widgets with `Spacing`/`DashboardLayoutTokens`
  - Swap icon/color token for DS values
  - Add missing `Semantics`/`Tooltip` labels
  - Switch chart to existing components (e.g., `SectionHeader`)
- Minimum checks: Run `scripts/flutter_codex.sh analyze` plus affected widget/chart tests (`test/features/dashboard/...`); short PR note with reference to `_acceptance_v1.1.md` (UI/Dataviz Core) and which tests/files were checked. No BMAD report, but traceable mini-DoD.
- Larger data flow/state changes or new widgets/screens fall back to full BMAD → PRP process.
