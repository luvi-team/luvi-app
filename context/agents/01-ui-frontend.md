---
role: ui-frontend
goal: UX-Konsistenz sichern; token-aware Widgets/Screens mit Tests.
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

## Ziel
Sichert UX-Konsistenz und Testabdeckung im Flutter-Frontend (Happy Path zuerst).

## Inputs
PRD, ERD, ADRs 0001-0003, Branch/PR-Link.

## Outputs
PR-Checks grün (flutter analyze/test), Widget-Tests, UI-Dokumentation unter docs/.

## Handoffs
An api-backend; Format: PR-Beschreibung + test/** + docs/**.

## Operativer Modus
Codex CLI-first (BMAD → PRP, kleinste Schritte, DoD/Gates). Legacy/Interop: .claude/agents/ui-frontend.md (nur Referenz, keine Befehle übernehmen).

## Checklisten & Runbooks
- UI‑Checklist: `docs/engineering/checklists/ui.md`
