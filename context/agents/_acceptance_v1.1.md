# Acceptance – SSOT v1.1

## Core
- Required Checks (GitHub): Flutter CI / analyze-test (pull_request) ✅ · Flutter CI / privacy-gate (pull_request) ✅ · Greptile Review (Required Check) ✅ · Vercel Preview Health (200 OK) ✅ (CodeRabbit optional lokal)
- DoD (Repo): analyze/test grün · ADRs gepflegt · DSGVO-Review aktualisiert
- Hinweis: DCM läuft CI-seitig non-blocking; Findings optional auswerten.

## Role extensions
- UI/DataViz: flutter test (≥1 Unit + ≥1 Widget)
- Backend: dart analyze; dart test (services/contracts)
- DB-Admin: Migrations & RLS-Policies & Docs; Kein service_role im Client
- QA/DSGVO: Privacy-Review (docs/privacy/reviews/<id>.md)
