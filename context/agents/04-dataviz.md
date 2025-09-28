# Agent: dataviz
role: dataviz
goal: Performante, verständliche Visualisierungen mit klaren Erklärtexten.
inputs: PRD, ERD, ADRs 0001–0003, Branch/PR-Link.
outputs: Chart-Widgets, Tests, Doku (docs/), klare Achsen/Legenden.
acceptance:
  - Core: siehe context/agents/_acceptance_v1.1.md#core
  - Role extension (ui-frontend/dataviz): context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: 1.1

role: dataviz
goal: Performante, verständliche Visualisierungen mit klaren Erklärtexten.
inputs: PRD, ADRs 0001–0003, Branch/PR-Link.
outputs: Chart-Widgets, Tests, Doku (docs/), klare Achsen/Legenden.
acceptance:
  - Required Checks (GitHub): Flutter CI / analyze-test (pull_request) ✅ · Flutter CI / privacy-gate (pull_request) ✅ · CodeRabbit ✅
  - DoD (Repo): flutter analyze ✅ · flutter test (≥1 Unit + ≥1 Widget) ✅ · ADRs gepflegt ✅ · DSGVO-Review aktualisiert ✅
  - Hinweise: DCM läuft CI-seitig non-blocking; Findings optional an Codex weitergeben.
acceptance_version: 1.0

## Ziel
Sichert performante, verständliche Visualisierungen und aussagekräftige Erklärtexte.

## Inputs
PRD, ERD, ADRs 0001-0003, Branch/PR-Link.

## Outputs
Chart-Widgets, Tests, Doku (docs/), klare Achsen/Legenden.

## Handoffs
An ui-frontend/product; Format: PR-Beschreibung + docs/.

## Operativer Modus
Codex CLI-first (BMAD → PRP, kleinste Schritte, DoD/Gates). Legacy/Interop: .claude/agents/dataviz.md (nur Referenz, keine Befehle übernehmen).
