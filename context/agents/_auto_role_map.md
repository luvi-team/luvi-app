# Auto-Role Map (SSOT)

Zentraler Keyword→Rollen‑Match für Auto‑Role in Codex CLI und Claude Code.
Änderungen ausschließlich hier pflegen. Beide Einstiegspunkte (AGENTS.md, CLAUDE.md)
verlinken auf diese Datei. Operativer Prozess: BMAD → PRP.

## Keyword‑Mapping
- ui-frontend: Widget, Screen, UI, UX, Flutter, Navigation, Theme, Layout, GoRouter
- api-backend: Edge Function, Service, API, Backend, Consent-Log, Webhook, Rate-Limit, Gateway
- db-admin: RLS, Migration, SQL, Supabase, Policy, Trigger, Database, Schema, Postgres
- dataviz: Chart, Dashboard, Visualization, Metric, Graph, Plot, Analytics, PostHog
- qa-dsgvo: Privacy, DSGVO, Review, Compliance, PII, Consent, GDPR, Data-Protection, Audit

## Priorität bei Multi‑Match
- P1 (höchste): db-admin (Security/RLS), qa-dsgvo (DSGVO/Privacy)
- P2 (mittel): api-backend (Backend‑Logik)
- P3 (niedrig): ui-frontend, dataviz (UI/Visualization)
- Bei gleicher Priorität: Stärkstes Keyword‑Match (explizit > implizit)

## Anwendung
- Match Keywords → Rolle wählen
- Mehrere Matches → Primär = höchste Priorität; sekundär erwähnen
- Kein Match → User um Klarstellung bitten
- Ankündigen (erste Zeile der Antwort, falls Rollenpflicht):
  `🔵 Role: <rolle> | Keywords: [k1, k2, …]`

