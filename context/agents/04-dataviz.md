---
role: dataviz
goal: Performante, verständliche Visualisierungen mit klaren Erklärtexten.
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
  - Chart-Widgets
  - Tests
  - Doku (docs/)
  - Klare Achsen/Legenden
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: dataviz

## Ziel
Sichert performante, verständliche Visualisierungen und aussagekräftige Erklärtexte.

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR-Link.

## Outputs
Chart-Widgets, Tests, Doku (docs/), klare Achsen/Legenden.

## Handoffs
PRs an ui-frontend/Product + Codex-Review: PR-Beschreibung + `docs/` + Charts. Codex prüft Architektur, State-Management und Datenschutz vor Merge.

## Operativer Modus
Claude Code implementiert Charts/Widgets/Tests gemäß BMAD-slim, Codex reviewed jede Änderung für Konsistenz und DSGVO-Konformität (Analyse/Test via `scripts/flutter_codex.sh`).

## Checklisten & Runbooks
- DataViz‑Checklist: `docs/engineering/checklists/dataviz.md`
- Analytics‑Taxonomie: `docs/analytics/taxonomy.md`
- Chart‑A11y‑Checklist: `docs/analytics/chart-a11y-checklist.md`
- Backfill Runbook: `docs/runbooks/analytics-backfill.md`
