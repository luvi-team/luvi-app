# Agent Dossiers

Preamble: 5 roles (ui-frontend · api-backend · db-admin · dataviz · qa-dsgvo). Workflow: BMAD → PRP, DoD/Gates.
Control: Auto-Role (default) or explicit `role: ...` for mixed tasks.
Required Checks: Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · Greptile Review (Required Check) · Vercel Preview Health (200 OK).
AI review setup (Greptile merge gate, local CodeRabbit preflight) is defined in docs/engineering/ai-reviewer.md. If anything else contradicts it, ai-reviewer.md wins.
SSOT Acceptance: context/agents/_acceptance_v1.1.md (non-blocking Drift-Check via acceptance_version).
Dossier Convention: YAML frontmatter (inputs/outputs) is machine-readable; the "Inputs" text section is human-readable shortform. Both intentional.

| Role | Dossier | Main Handoff | Primary Agent |
|---|---|---|---|
| architect-orchestrator | GEMINI.md | → api-backend/ui-frontend (tasks in Archon) | Gemini |
| ui-frontend | context/agents/01-ui-frontend.md | → api-backend (PR + Tests/Docs) | Claude Code |
| api-backend | context/agents/02-api-backend.md | → ui-frontend/db-admin (Docs + Functions) | Codex |
| db-admin | context/agents/03-db-admin.md | → api-backend (Migrations + Docs) | Codex |
| dataviz | context/agents/04-dataviz.md | → ui-frontend (Docs + PR) | Claude Code |
| qa-dsgvo | context/agents/05-qa-dsgvo.md | → db-admin/ui-frontend (Privacy Reviews) | Codex |
