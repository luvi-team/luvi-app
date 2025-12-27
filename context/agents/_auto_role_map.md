# Auto-Role Map (SSOT)

Zentraler Keyword→Rollen‑Match für Auto‑Role in Codex CLI und Claude Code.
Änderungen ausschließlich hier pflegen. Einstiegspunkt: AGENTS.md.
Operativer Prozess: BMAD → PRP.

> **Claude Code Custom Agents:** Keywords sind synchronisiert mit `.claude/agents/*.md`.
> Änderungen hier müssen auch in den Custom Agent `description` Feldern reflektiert werden.

## Keyword‑Mapping

### Primary Roles
- architect-orchestrator: Architecture, Governance, Planning, Epic, Refactoring, System, Orchestration, Architektur, Planung, Roadmap, Struktur
- ui-frontend: Widget, Screen, UI, UX, Flutter, Navigation, Theme, Layout, GoRouter, Bildschirm, Ansicht, Oberfläche, Design
- api-backend: Edge Function, Service, API, Backend, Consent-Log, Webhook, Rate-Limit, Gateway, Endpunkt, Schnittstelle, Server
- db-admin: RLS, Migration, SQL, Supabase, Policy, Trigger, Database, Schema, Postgres, Datenbank, Tabelle, View, Richtlinie
- dataviz: Chart, Dashboard, Visualization, Metric, Graph, Plot, Analytics, PostHog, Visualisierung, Diagramm, Metrik
- qa-dsgvo: Privacy, DSGVO, Review, Compliance, PII, Consent, GDPR, Data-Protection, Audit, Datenschutz, Einwilligung, Pruefung, Prüfung

### Soft-Gate Agents (Claude Code)
- reqing-ball: PRD, ADR, Requirements, Validation, Schema, Policy, Cross-feature
- ui-polisher: polish, tokens, A11y, accessibility, contrast, touch-targets, spacing
- qa-reviewer: logging, PII, user-data, health-data, cycle, period, sanitize

## Priorität bei Multi‑Match
- P0 (Strategic): architect-orchestrator (Governance/Architektur)
- P1 (höchste): db-admin (Security/RLS), qa-dsgvo (DSGVO/Privacy)
- P2 (mittel): api-backend (Backend‑Logik)
- P3 (niedrig): ui-frontend, dataviz (UI/Visualization)
- Bei gleicher Priorität: Stärkstes Keyword‑Match (explizit > implizit)

## Anwendung
- Match Keywords → Rolle wählen
- Mehrere Matches → Primär = höchste Priorität; sekundär erwähnen
- Kein Match → User um Klarstellung bitten
- Ankündigen (erste Zeile der Antwort, falls Rollenpflicht):
  `[Role: <rolle> | Keywords: k1, k2, …]`

## Agent-Binding pro Rolle (Primary)

| Rolle        | Primary Agent |
|--------------|---------------|
| architect-orchestrator | Gemini |
| ui-frontend  | Claude Code   |
| dataviz      | Claude Code   |
| api-backend  | Codex         |
| db-admin     | Codex         |
| qa-dsgvo     | Codex         |

Hinweise:
- Security/Privacy/DB (db-admin, qa-dsgvo) gehen immer an Codex als Primary (Security > UI).
- Reine UI/Dataviz-Matches → Claude Code ist Primary, Codex übernimmt die Review.
