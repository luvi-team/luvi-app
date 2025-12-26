# Acceptance – SSOT v1.1

## Core
- Required Checks (GitHub): Flutter CI / analyze-test (pull_request) ✅ · Flutter CI / privacy-gate (pull_request) ✅ · Greptile Review (Required Check) ✅ · Vercel Preview Health (200 OK) ✅
- DoD (Repo): analyze/test grün · ADRs gepflegt · DSGVO-Review aktualisiert
- Hinweis: DCM läuft CI-seitig non-blocking; Findings optional auswerten.

## Role extensions
- UI/DataViz: flutter test (≥1 Unit + ≥1 Widget)
- Backend: dart analyze; dart test (services/contracts)
- DB-Admin: Migrations & RLS-Policies & Docs; Kein service_role im Client
- QA/DSGVO: Privacy-Review (docs/privacy/reviews/<id>.md)

## Multi-Agent Review
- **Architect-Level (Gemini):** PRs von Gemini (`architect-orchestrator`), die Governance oder Architektur betreffen (z.B. ADRs, `bmad/global.md`), erfordern ein manuelles Review durch einen **Human Architect/Lead Dev**.
- **Dual-Agent (Claude → Codex):** PRs von Claude Code (`ui-frontend`, `dataviz`) erfordern die Standard-CI-Checks **plus** ein manuelles Codex-Review (Architektur, State, DSGVO) vor dem Merge.
- **Codex-Internal:** PRs von Codex (`api-backend`, `db-admin`, `qa-dsgvo`) erfordern die Standard-CI-Checks. Ein Review durch Claude Code ist optional, falls signifikante UI-Anteile betroffen sind.
