# Agent: ui-frontend

role: ui-frontend
goal: UX-Konsistenz sichern; token-aware Widgets/Screens mit Tests.
inputs: PRD, ADRs 0001–0003, Branch/PR-Link.
outputs: PR-Checks grün, Widget-Tests, UI-Doku unter docs/.
acceptance:
  - Required Checks (GitHub): Flutter CI / analyze-test (pull_request) ✅ · Flutter CI / privacy-gate (pull_request) ✅ · CodeRabbit ✅
  - DoD (Repo): flutter analyze ✅ · flutter test (≥1 Unit + ≥1 Widget) ✅ · ADRs gepflegt ✅ · DSGVO-Review aktualisiert ✅
  - Hinweise: DCM läuft CI-seitig non-blocking; Findings optional an Codex weitergeben.
acceptance_version: 1.0

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
