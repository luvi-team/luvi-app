# Tech-Stack · FemTech App (DSGVO-first) — MVP+

**Ziel:** Solo-Dev-freundlicher, skalierbarer, EU-konformer Stack für iOS-first (Flutter).

## English Summary

This document defines the technology stack for LUVI, a GDPR-first FemTech application built for the EU market. Key architectural decisions include:
- **Frontend:** Flutter (iOS-first) with Riverpod state management and GoRouter navigation
- **Backend:** Supabase (EU/Frankfurt) with PostgreSQL, Row Level Security, and pgvector for semantic search
- **AI Layer:** Multi-provider routing (OpenAI EU, Claude/Bedrock EU, Gemini/Vertex EU) with Redis caching and Langfuse observability
- **Compliance:** EU-only regions, consent logging, PII redaction at edge, no health data in push notifications

## Glossary

| Term | Definition |
|------|------------|
| **Archon** | MCP server providing knowledge base (SSOT) for AI agents |
| **Codex CLI** | AI coding assistant specialized for backend/DB/privacy work |
| **DSGVO** | German GDPR (Datenschutz-Grundverordnung) |
| **Greptile Review** | GitHub Required Check for AI-powered code review |
| **Langfuse** | LLM observability platform for tracing, costs, latency |
| **MCP** | Model Context Protocol - AI tool integration standard |
| **pgvector** | PostgreSQL extension for vector similarity search |
| **PII** | Personally Identifiable Information |
| **RLS** | Row Level Security - database access control per user |
| **SSOT** | Single Source of Truth |
| **Supabase MCP** | Dev-only read-only MCP bridge for schema introspection |
| **Vercel Preview Health** | Required check that `/api/health` returns 200 before merge |

---

## 0) Leitgedanke

- **SQL-first**, **Edge-nah**, **Privacy by Design** (EU-Residency, PII-Redaction, Consent-Logs).
- **Vibe-Coding** mit einem starken Agenten (**Codex CLI**), **Wissens-SSOT** (**Archon**) und **LLM-Observability** (**Langfuse**).
- **CI-geführte Änderungen**: Alles Schreibende per **PR/Migration** + **Greptile-Review-Gate** (GitHub Required Check) + **Preview-Health (200)** vor Merge; CodeRabbit nur noch lokal als optionaler Preflight.

---

## 1) Development Environment

### 1.1 IDE & Workstation

- **Cursor IDE** *(Repo-Explorer, minimale Bearbeitung)*  
  **Funktion:** Projekt/Repo-Navigation.  
  **Warum:** Bewährt im Flow; Haupt-Editing via Terminal-Clients.

- **Terminal**  
  **Funktion:** Shell für Builds, Tests, CI-Tasks.

### 1.2 AI-Coding (Primary & Review)

- **Gemini**  
  **Funktion:** Primärer Agent für Architekstrierung und systemweite Analysen. Erstellt Epics und pflegt Governance-Dokumente.
  **Einsatz:** Planung, System-Analyse, Refactoring-Strategien.

- **Codex CLI**  
  **Funktion:** Spezialisierter AI-Code-Assistent für Backend, DB und Privacy. Fungiert als Review-Agent für Frontend-PRs.
  **Einsatz:** Daily Dev + Planung/Refactor (Backend/DB); formales PR-Review via **Greptile Review** (Required Check).

- **Claude Code**  
  **Funktion:** Spezialisierter AI-Agent für das Flutter-Frontend (UI und DataViz).
  **Einsatz:** Implementierung von Screens, Widgets und Charts gemäß `CLAUDE.md`.

- **CodeRabbit (nur lokal)**  
  **Funktion:** Lokales Pre-PR-Review (CLI/IDE).  
  **Einsatz:** Optionales Qualitäts-/Security-Preflight vor dem Push; **kein GitHub-Required-Check**, keine Branch-Protection. Siehe `docs/engineering/ai-reviewer.md`.

- **Greptile (GitHub App)**  
  **Funktion:** AI-Code-Review im Pull Request mit GitHub-Statuscheck.  
  **Einsatz:** Offizieller Merge-Gatekeeper (Required Check `Greptile Review`).

### 1.3 Archon — MCP-Wissens/Task „SSOT“

- **Funktion:** Single-Source-of-Truth für **Dossiers/Policies/Runbooks**; via **MCP** direkt in AI-Tools abrufbar.  
- **Warum:** Stabiler Agent-Kontext, weniger Prompt-Drift, reproduzierbare Ergebnisse.  
- **Einsatz:**  
  - `context/`-Dossiers: **Phase-Logik**, **Consent-Texte**, **Ranking-Heuristiken**, **AGENTS.md**  
  - Direkt in **Codex** konsumierbar (MCP-Bridge).

---

## 2) Frontend (Mobile)

- **Flutter / Dart** *(see `context/refs/tech_stack_current.yaml` for CI-pinned versions)*
  **Funktion:** Cross-platform UI; iOS-first Rollout.
  **Warum:** Beste Time-to-Market im bestehenden Setup.
  **Note:** Canonical versions defined in `context/refs/tech_stack_current.yaml`. CI pins ensure reproducible builds. See `.github/workflows/*.yml` for CI configuration.

- **State & Navigation:** `Riverpod`, `GoRouter` *(see `context/refs/tech_stack_current.yaml` for pinned versions)*
  **Einsatz:** Home/„Heute in der Phase", Stream, Coach, Profil.

- **Health-Integration (Baseline-Roadmap):** HealthKit-Anbindung

- **Offline & Security:**  
  - **SQLCipher** für lokale verschlüsselte DB (Crash Protection bei laufenden Workouts)  
  - **flutter_secure_storage** für Encryption Keys  
  - `is_session_active` Flag nach App-Crash

---

## 3) Backend & Daten

### 3.1 Supabase (EU/Frankfurt) — Postgres + Auth + Storage + Realtime

- **Funktion:** Verwaltete Postgres-Plattform (RLS), plus Auth/Storage/Realtime.  
- **Einsatz:**  
  - **`pgvector`** für semantische Suche/Empfehlungen im Stream  
  - **Auth** (Abo-Gates), **Storage** (Metadaten), **Consent-Logs**  
- **EU-Residency:** Rechenzentrum DE; **keine** `service_role` im Client.

### 3.2 Supabase MCP (Dev-only, read-only)

- **Zweck:** LLM-Assistent (Codex) kann **Schema lesen / erklären / Migrationspläne vorschlagen**.  
- **Guardrails:** **Keine Prod-Writes.** **DB-Änderungen nur via Migrations-PR → CI-Dry-Run → Apply (Dev) → RLS-Smoke.**  
- **Setup-Hinweis:** `docs/dev/mcp_setup.md` (Codex via **command-Server**; **PAT lokal**, `chmod 600`).

### 3.3 API-Gateway: Vercel Edge (`region: 'fra1'`)

- **Funktion:** Edge-Functions nahe den EU-Usern/DBs; CORS/Rate-Limit/PII-Redaction.  
- **Routen:** `/api/health` (200 + timestamp), `/api/ai/*`, **Quality Gate:** **Vercel Preview Health (200 OK)** als **Required Check** vor Merge/Promotion.

---

## 4) AI-Layer

### 4.1 Router: Vercel AI SDK (Multi-Provider)

- **Funktion:** Abstraktion + Retry/Circuit-Breaker; **OpenAI EU**, **Claude via Bedrock EU**, **Gemini/Vertex EU**.  
- **Einsatz:** Semantische Suche, „Heute in der Phase“, Playlist-Vorschläge.

### 4.2 Cache: Redis

- **Funktion:** Key-Value-Cache für Ergebnislisten/Prompt-Antworten.  
- **Einsatz:** Schneller App-Start, Kostensenkung.

### 4.3 Langfuse — LLM Observability

- **Funktion:** End-to-End-Tracing: Prompt → Antwort, **Token/Kosten**, **Latenzen**, **Tool-Calls**, **Evals**.  
- **Warum:** „**Cannot skip**“ — zentrale Qualität & Kostenkontrolle.  
- **Einsatz:** Monitoring & Debug für alle `/api/ai/*`-Calls; Prompt-Tuning, Budget-Kontrolle.

---

## 5) Services & Infrastruktur

- **Analytics:** **PostHog (EU)**  
- **Push:** **OneSignal** (DPA/SCCs)  
  **Privacy-Policy (ADR-0006):** Payloads dürfen **KEINE** sensiblen Daten (Zyklusphase, Symptome) enthalten. Content-First-Strategie.  
- **Crash/Performance:** **Sentry**  
- **CI/CD:** **GitHub Actions** + **Vercel** (PR-Previews, Prod-Deploy on merge) + **Greptile Review** (Required Check im PR; optional lokales CodeRabbit-Review als Preflight, kein GitHub-Check)

### 5.1 Newsletter (Baseline, wieder explizit)

- **Tool (z. B. Brevo, DOI)**  
  **Funktion:** Versand von Transaktions-/Marketing-Mails mit **Double-Opt-In**.  
  **Einsatz:** Onboarding-Sequenzen, Feature-Updates, „Coach startet“-Mails.  
  **Hinweis:** SPF/DKIM/DMARC, Abmeldelogik & Consent-Status mit Supabase verknüpfen.

### 5.2 Payments & Subscriptions

- **RevenueCat**  
  **Funktion:** IAP-Abo-Verwaltung (StoreKit / Play Billing), Entitlements, Analytics.  
  **Einsatz:** 7-Tage-Trial, Abo-Gates für Premium-Features, Workout-Einzelkäufe in LUVI Coach, Restore Purchases.  
  **Integration:** Supabase-Sync für Entitlements, Webhook für Abo-Events.  
  **Preis-Range:** ~10–15 €/Monat (Abo), Einzelkaufpreise ab 4,99 €.

---

## 6) Compliance & Governance

- **DSFA/DPIA (Initial)**; **EU-Residency** über alle Kern-Dienste (Supabase DE, Vercel `fra1`, EU-Regionen der AI-Provider).  
- **Consent-Logs** (App), **PII-Redaction** im Gateway, **/api/health** als Betriebsnachweis.  
- **Agenten-Governance:** `AGENTS.md` + Dossiers (Archon SSOT).  
- **Review-Gates:** optional lokales CodeRabbit → **Greptile Review** (Required Check im PR) → **Preview Health 200** → Merge.

---

## 7) Kosten-Leitplanken (Baseline)

- Ø LLM-Call **~0,6 ct** (ohne Cache) / **~0,2 ct** (mit Cache).

---

## 8) Tool-Matrix (Herkunft & Zweck)

| Tool/Komponente                 | Kategorie        | Status             | Funktion/Kernnutzen                                  | Herkunft   |
|---------------------------------|------------------|--------------------|------------------------------------------------------|-----------|
| **Gemini**                      | Dev-AI (Arch)    | Neu                | Architektur & Orchestrierung               | Session   |
| **Codex CLI**                   | Dev-AI (Back)    | Bestätigt          | Agentisches Coding (Backend/DB/Privacy)              | Video     |
| **Claude Code**                 | Dev-AI (Front)   | Bestätigt          | UI/Dataviz Implementierung                           | Session   |
| **Archon (MCP)**                | Knowledge/SSOT   | Neu                | Dossiers/Policies + MCP-Bridge für AI-Kontext        | Video     |
| **Langfuse**                    | LLM Observability| Neu                | Traces/Costs/Latency/Evals                           | Video     |
| **Supabase (EU) + pgvector**    | DB/Auth          | Beibehalten        | SQL + Vektor + RLS                                   | Baseline  |
| **Supabase MCP (Dev-only, RO)** | DB-Ops via MCP   | Neu (User-Wunsch)  | AI-gestützte Schema/Plan-Ops mit Guardrails          | Anfrage   |
| **Vercel Edge (fra1)**          | API/Edge         | Beibehalten        | `/api/health`, `/api/ai/*`, Previews                 | Baseline  |
| **Vercel Preview Health 200**   | QA/Gate          | Reaktiviert        | Required Check auf PR-Preview-Erreichbarkeit         | Baseline  |
| **Redis**                       | Cache            | Beibehalten        | Schnelle Feeds, geringere Kosten                     | Baseline  |
| **PostHog (EU)**                | Analytics        | Beibehalten        | Events/Funnel/Retention                              | Baseline  |
| **Sentry**                      | Crash/Perf       | Beibehalten        | Stabilitäts-Monitoring                               | Baseline  |
| **GitHub Actions + Greptile Review** | CI/QA        | Aktualisiert       | Build/Test + AI-PR-Review (Greptile Review als Required Check); optional lokales CodeRabbit-Preflight (kein GitHub-Check) | Baseline  |
| **Newsletter (Brevo/DOI)**      | Comms            | Wieder aufgenommen | Opt-in Mailversand, Onboarding/Updates               | Baseline  |
| **Flutter (iOS-first)**         | App-UI           | Beibehalten        | UI-Implementierung, Time-to-Market                   | Baseline  |
