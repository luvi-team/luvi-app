---
role: api-backend
goal: Zuverlässige Backend-Logik (Edge Functions/Services) mit Consent-Logs.
primary_agent: Codex
review_by: Codex
inputs:
  - PRD
  - ERD
  - ADRs 0001–0004
  - Branch/PR-Link
  - docs/product/app-context.md
  - docs/engineering/tech-stack.md
  - docs/engineering/field-guides/gold-standard-workflow.md
  - docs/engineering/safety-guards.md
outputs:
  - Edge Functions/Services
  - Contract-Tests
  - Doku (docs/)
  - Rate-Limits (falls Endpunkt extern erreichbar, z. B. App-Client oder öffentlich)
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: api-backend

## Ziel
Sichert zuverlässige Backend-Logik (Edge Functions, Services) mit Consent-Logs.

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR-Link.

## Outputs
Edge Functions/Services, Contract-Tests, Doku (docs/), Rate-Limits (nur bei extern erreichbaren Endpunkten).

## Handoffs
An ui-frontend/db-admin; Format: PR-Beschreibung + `docs/` + `supabase/functions/`. UI-Anpassungen konsumieren die dokumentierten Contracts und werden von Claude Code umgesetzt.

## Operativer Modus
Codex implementiert Edge Functions/Services, Policies und Tests gemäß BMAD → PRP (Plan → Run → Prove; siehe [Governance](../../docs/bmad/global.md)); Claude Code adaptiert das UI nur nach erfolgreichem Backend-Handoff.

## Checklisten & Runbooks
- API‑Checklist: `docs/engineering/checklists/api.md`
- Health‑Check Runbook: `docs/runbooks/vercel-health-check.md`

## Micro-Tasks (minimaler Modus)
- Beispiele:
  - Kleine Query-/Filter-Anpassung ohne Schema-Änderung
  - Einzelnes Log-Level/PII-Redact fixen
  - Bestehende Edge-Function um einen Guard erweitern
  - Einzelnes Contract-Testcase ergänzen
  - Privacy-Hinweis in Docs nachziehen
- Mindest-Checks: `scripts/flutter_codex.sh analyze-test` gegen die betroffenen Module/Tests, Vermerk im PR welche Acceptance-Punkte aus `_acceptance_v1.1.md` berührt sind (z. B. Logging/Consent) und kurzes Ergebnis der gezielten Tests.
- Sobald neue Endpunkte, Migrations oder Policies betroffen sind, gilt wieder BMAD → PRP (siehe [Governance](../../docs/bmad/global.md)) inkl. vollständigen Checks.
