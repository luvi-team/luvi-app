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
- Claude-Code UI-Checklist (Navigation/Tokens/L10n Regeln): `docs/engineering/checklists/ui_claude_code.md`
- DataViz‑Checklist: `docs/engineering/checklists/dataviz.md`
- Analytics‑Taxonomie: `docs/analytics/taxonomy.md`
- Chart‑A11y‑Checklist: `docs/analytics/chart-a11y-checklist.md`
- Backfill Runbook: `docs/runbooks/analytics-backfill.md`

## Micro-Tasks (minimaler Modus)
- Beispiele:
  - Copy/L10n bei Chart-Legenden über ARB korrigieren
  - Spacing/Radius in bestehenden Widgets mit `Spacing`/`DashboardLayoutTokens` anpassen
  - Icon/Color-Token gegen DS-Werte tauschen
  - Fehlende `Semantics`/`Tooltip`-Labels ergänzen
  - Chart auf bestehenden Komponenten (z. B. `SectionHeader`) umstellen
- Mindest-Checks: `scripts/flutter_codex.sh analyze` plus betroffene Widget-/Chart-Tests (`test/features/dashboard/...`) laufen lassen; kurze PR-Notiz mit Verweis auf `_acceptance_v1.1.md` (UI/Dataviz Core) und welche Tests/Files geprüft wurden. Kein BMAD-Report, aber nachvollziehbare Mini-DoD.
- Größere Datenfluss-/State-Änderungen oder neue Widgets/Screens fallen zurück in den vollständigen BMAD → PRP-Prozess.
