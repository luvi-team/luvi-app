---
role: api-backend
goal: Zuverlässige Backend-Logik (Edge Functions/Services) mit Consent-Logs.
inputs:
  - PRD
  - ERD
  - ADRs 0001–0003
  - Branch/PR-Link
  - docs/product/app-context.md
  - docs/engineering/tech-stack.md
  - docs/engineering/gold-standard-workflow.md
  - docs/engineering/safety-guards.md
outputs:
  - Edge Functions/Services
  - Contract-Tests
  - Doku (docs/)
  - Rate-Limits
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: api-backend

## Ziel
Sichert zuverlässige Backend-Logik (Edge Functions, Services) mit Consent-Logs.

## Inputs
PRD, ERD, ADRs 0001-0003, Branch/PR-Link.

## Outputs
Edge Functions/Services, Contract-Tests, Doku (docs/), Rate-Limits.

## Handoffs
An ui-frontend/db-admin; Format: PR-Beschreibung + docs/ + supabase/functions/.

## Operativer Modus
Codex CLI-first (BMAD → PRP, kleinste Schritte, DoD/Gates). Legacy/Interop: .claude/agents/api-backend.md (nur Referenz, keine Befehle übernehmen).
