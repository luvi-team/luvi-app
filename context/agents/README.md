# Agenten-Dossiers

Kurzpreamble: 5 Rollen (ui-frontend · api-backend · db-admin · dataviz · qa-dsgvo). Operativ: BMAD → PRP, DoD/Gates.
Steuerung: Auto-Role (Default) oder explicit role: … bei Misch-Tasks.
Required Checks: Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · Greptile Review (Required Check) · Vercel Preview Health (200 OK).
AI review setup (Greptile merge gate, local CodeRabbit preflight) is defined in docs/engineering/ai-reviewer.md. If anything else contradicts it, ai-reviewer.md wins.
SSOT Acceptance: context/agents/_acceptance_v1.1.md (non-blocking Drift-Check via acceptance_version).

| Rolle | Dossier | Haupt-Hand-off | Primary Agent |
|---|---|---|---|
| ui-frontend | context/agents/01-ui-frontend.md | → api-backend (PR + Tests/Docs) | Claude Code |
| api-backend | context/agents/02-api-backend.md | → ui-frontend/db-admin (Docs + Functions) | Codex |
| db-admin | context/agents/03-db-admin.md | → api-backend (Migrations + Docs) | Codex |
| dataviz | context/agents/04-dataviz.md | → ui-frontend (Docs + PR) | Claude Code |
| qa-dsgvo | context/agents/05-qa-dsgvo.md | → db-admin/ui-frontend (Privacy Reviews) | Codex |
