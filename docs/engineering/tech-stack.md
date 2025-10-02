# Tech-Stack Slim v2.1

Projekt: FemTech Mobile (AT), DSGVO-first • Ziel: Solo-Dev-freundlich, skalierbar, EU-rechtskonform.

## 1) Development Environment
IDE: Cursor · Terminal: Warp (Workflows für Supabase/CI/API-Tests)

AI-Coding:
- Codex CLI (Terminal-basiert; schnelle Fixes, CI/Refactor, Checklist-Diffs). Auto-Rolle standardmäßig; bei Misch-Tasks role: … explizit.
- Claude Code (Multi-File, Refactoring, Migrationen, RLS-Policies, Tests; Interop/Legacy wenn .claude/* referenziert wird).

Code-Qualität:
- flutter_lints (Basis)
- Dart Code Metrics (DCM): lokal nutzbar; in CI informativ (non-blocking)
- CodeRabbit (Lite): GitHub-App + IDE/CLI, line-by-line PR-Reviews; Required Check

Required Checks (exakt):
Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · CodeRabbit

## 2) Frontend (Flutter)
Flutter 3.35.4 (Dart 3.9.0, in CI gepinnt)
State: Riverpod 3 · Nav: GoRouter
UI: Figma NovaHealth → Dualite (Figma→Flutter)
Health: Flutter Health Package (Apple Health/Google Fit/Wearables)

## 3) Backend & Daten
Supabase (EU/Frankfurt): Postgres + Auth + Storage + Realtime
DB: PostgreSQL + pgvector (semantische Suche/Empfehlungen)
Edge Functions: Consent-Handling, Audit-Trail, Pseudonymisierung
RLS: owner-based; kein service_role im Client/Terminal

## 4) AI-Layer
Router: Node Gateway mit Vercel AI SDK (Cost/Failover/Policy)
Provider: OpenAI API (EU-Project, zero retention) · Claude via Bedrock (EU) · Gemini via Vertex (EU)
Caching: Upstash Redis · Guards: Rate-Limit + Circuit-Breaker

## 5) Services & Infrastruktur
Analytics: PostHog Cloud EU · Push: OneSignal (EU) · Crash: Sentry · CDN/Security: Cloudflare · CI/CD: GitHub Actions
Consent: Web: Cookiebot · App: In-App-Consent + Supabase-Logging {version, ts}
Documentation: Linear

## 6) Compliance
DSFA/DPIA: einmalig (Updates bei größeren Änderungen)
Datenflüsse: EU-Regionen (OpenAI EU / Bedrock EU / Vertex EU)
DSAR: Export/Delete-Pfad; Audit-/Consent-Logs vorhanden

## 7) Kosten-Leitplanken
Ø KI-Request: ~0,6 ct (ohne Cache); mit Cache ~0,2 ct
Mehrkosten AI/DSGVO: ~€0,49 / Premium-User / Monat

## 8) Agenten-Governance (aktualisiert)
- AGENTS.md (Root) → Dossiers
- Header-Schema: role, goal, inputs, outputs, acceptance, acceptance_version: 1.1
- SSOT Acceptance: context/agents/_acceptance_v1.1.md
- Interop/Legacy: .claude/*, CLAUDE.md nur Referenz

## 9) Branch-Protection (Empfehlung)
Required Checks: Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · CodeRabbit
