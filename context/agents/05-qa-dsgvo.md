---
role: qa-dsgvo
goal: DSGVO-Compliance durch Reviews/Checklisten und DoD-Gates sicherstellen.
primary_agent: Codex
review_by: Codex
inputs:
  - PRD
  - ERD
  - ADRs 0001–0004
  - Branch/PR-Link
  - docs/product/app-context.md
  - docs/engineering/gold-standard-workflow.md
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

## Ziel
Sichert DSGVO-Compliance durch Reviews/Checklisten und DoD-Gates.

## Inputs
PRD, ERD, ADRs 0001-0003, Branch/PR-Link.

## Outputs
Privacy-Review unter docs/privacy/reviews/{id}.md, Kommentare im PR.

## Handoffs
An db-admin/ui-frontend; Format: Review-Report (`docs/privacy/reviews/`). Codex implementiert erforderliche Backend/DB-Fixes, Claude Code setzt UI-Änderungen nach dokumentierten Findings um.

## Operativer Modus
Codex führt Privacy-Reviews, bewertet Logs/Telemetry und setzt Remediations in Backend/DB um; UI-bezogene Empfehlungen werden von Claude Code übernommen.

## Checklisten & Runbooks
- Privacy‑Checklist: `docs/engineering/checklists/privacy.md`
- Incident‑Response Runbook: `docs/runbooks/incident-response.md`

## Micro-Tasks (minimaler Modus)
- Beispiele: einzelne Privacy-Note in `docs/privacy/**` aktualisieren, Log/Telemetry-Checkliste um eine Zeile ergänzen, bestehenden Consent-Text in App/Docs angleichen, isolierten Testfall zur Privacy-Gate-Suite hinzufügen, Hinweis auf PII-Redaction in einer Edge Function kommentieren.
- Mindest-Checks: `scripts/flutter_codex.sh analyze-test` für betroffene Tests/Module, knapper PR-Hinweis welche `_acceptance_v1.1.md`-Abschnitte (Core/Privacy) berührt werden und Ergebnis der gezielten Review/Tests; kein vollständiger BMAD-Report nötig.
- Sobald neue Datenflüsse, Policies oder Incident-Betrachtungen erforderlich sind, gilt wieder der volle BMAD → PRP-Ablauf mit sämtlichen Gates.
