# Agenten-Dossiers

Kurzpreamble: 5 Rollen (ui-frontend · api-backend · db-admin · dataviz · qa-dsgvo). Operativ: BMAD → PRP, DoD/Gates.
Steuerung: Auto-Role (Default) oder explicit role: … bei Misch-Tasks.
Required Checks: Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · CodeRabbit.
SSOT Acceptance: context/agents/_acceptance_v1.1.md (non-blocking Drift-Check via acceptance_version).
Auto-Role Map (SSOT): context/agents/_auto_role_map.md

| Rolle | Dossier | Interop-Prompt (Legacy) | Haupt-Hand-off |
|---|---|---|---|
| ui-frontend | context/agents/01-ui-frontend.md | .claude/agents/ui-frontend.md | an api-backend (PR + tests/docs) |
| qa-dsgvo | context/agents/05-qa-dsgvo.md | .claude/agents/qa-dsgvo.md | an db-admin/ui-frontend (docs/privacy/reviews) |
| db-admin | context/agents/03-db-admin.md | .claude/agents/db-admin.md | an api-backend (migrations + docs) |
| dataviz | context/agents/04-dataviz.md | .claude/agents/dataviz.md | an ui-frontend (docs + PR) |
| api-backend | context/agents/02-api-backend.md | .claude/agents/api-backend.md | an ui-frontend/db-admin (docs + functions) |
