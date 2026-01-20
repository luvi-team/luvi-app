---
role: ui-frontend
goal: Ensure UX consistency; token-aware widgets/screens with tests.
primary_agent: Claude Code
review_by: Codex
inputs:
  - PRD
  - ERD
  - ADRs 0001–0004
  - Branch/PR-Link
  - docs/product/app-context.md
  - docs/engineering/tech-stack.md
  - docs/product/use-cases.md
  - docs/engineering/assistant-answer-format.md
outputs:
  - PR-Checks grün
  - Widget-Tests
  - UI-Doku unter docs/
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: ui-frontend

## Goal
Ensures UX consistency and test coverage in Flutter frontend (Happy Path first).

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR link.

## Outputs
PR checks green (flutter analyze/test), widget tests, UI documentation under docs/.

## Handoffs
PRs go to Codex for technical review (architecture, state management, GDPR). Then handoff to api-backend with PR description + `test/**` + `docs/**`.

## Operative Mode
Claude Code implements screens/widgets/navigation incl. tests and BMAD-slim, Codex reviews every PR before merge (Architecture + Privacy Checks).

## Checklists & Runbooks
- Claude Code UI Checklist (canonical UI rules): `docs/engineering/checklists/ui_claude_code.md`
- UI Checklist (generic cheat sheet): `docs/engineering/checklists/ui.md`

## Micro-Tasks (minimal mode)
- Examples:
  - Small copy/L10n adjustment via `lib/l10n/app_{de,en}.arb`
  - Spacing correction with `Spacing`/`OnboardingSpacing`/`ConsentSpacing`
  - Replace hardcoded `Text` with `AppLocalizations`
  - Icon swap or use of DS widget (e.g., `BackButtonCircle`, `LinkText`)
  - Add missing `Semantics` label/key
- Minimum checks: Run `scripts/flutter_codex.sh analyze` and affected widget tests (existing `test/features/...`); short PR description incl. note on tested files, reference to `_acceptance_v1.1.md` for gate list.
- Anything beyond (state changes, navigation, new widgets) requires regular BMAD → PRP flow with full acceptance checks.
