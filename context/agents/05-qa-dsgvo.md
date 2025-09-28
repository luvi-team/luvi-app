# Agent: qa-dsgvo

role: qa-dsgvo
goal: DSGVO-Compliance durch Reviews/Checklisten und DoD-Gates sicherstellen.
inputs: PRD, ERD, ADRs 0001–0003, Branch/PR-Link.
outputs: Privacy-Review unter docs/privacy/reviews/<id>.md, Kommentare im PR.
acceptance:
  - Required Checks (GitHub): Flutter CI / analyze-test (pull_request) ✅ · Flutter CI / privacy-gate (pull_request) ✅ · CodeRabbit ✅
  - DoD (QA/DSGVO): DSGVO-Review aktualisiert (docs/privacy/reviews/<id>.md) ✅ · Privacy-Gate ✅ · CodeRabbit ✅ · ADRs gepflegt ✅
  - Hinweise: DCM läuft CI-seitig non-blocking; Findings optional an Codex weitergeben.
acceptance_version: 1.0

## Ziel
Sichert DSGVO-Compliance durch Reviews/Checklisten und DoD-Gates.

## Inputs
PRD, ERD, ADRs 0001-0003, Branch/PR-Link.

## Outputs
Privacy-Review unter docs/privacy/reviews/<id>.md, Kommentare im PR.

## Handoffs
An db-admin/ui-frontend; Format: Review-Report (docs/privacy/reviews/).

## Operativer Modus
Codex CLI-first (BMAD → PRP, kleinste Schritte, DoD/Gates). Legacy/Interop: .claude/agents/qa-dsgvo.md (nur Referenz, keine Befehle übernehmen).
