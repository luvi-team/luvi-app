# LUVI Project Memory

## Modus-Wahl (automatisch erkannt)

**Codex CLI:** Nutzt AGENTS.md (nicht diese Datei). `/status` liest AGENTS.md automatisch.
**Claude Code:** Nutzt diese Datei. Auto-Load aktiv. Folge "Claude Code Arbeitsablauf" unten.

---

## Claude Code Arbeitsablauf (immer befolgen bei Claude Code Sessions)

**Vor JEDER Task:**

1. **Task-Analyse**
   - Keywords extrahieren: Widget/Screen/UI/RLS/Migration/Chart/Privacy/API/etc.
   - User-Intent verstehen: Feature? Fix? Refactor? Test?

2. **Auto-Role (Keyword-Mapping)**
   - **ui-frontend:** Widget, Screen, UI, UX, Flutter, Navigation, Theme, Layout, GoRouter
   - **api-backend:** Edge Function, Service, API, Backend, Consent-Log, Webhook, Rate-Limit, Gateway
   - **db-admin:** RLS, Migration, SQL, Supabase, Policy, Trigger, Database, Schema, Postgres
   - **dataviz:** Chart, Dashboard, Visualization, Metric, Graph, Plot, Analytics, PostHog
   - **qa-dsgvo:** Privacy, DSGVO, Review, Compliance, PII, Consent, GDPR, Data-Protection, Audit
   - **Anwendung:**
     - Match Keywords → Rolle wählen
     - Mehrere Matches → Primär = erste Match, sekundär erwähnen
     - Kein Match → User fragen
   - **Ankündigen:** "Arbeite als [rolle] (erkannt: [keywords])"

3. **Dossier laden**
   - `context/agents/XX-[rolle].md` lesen (siehe @-Referenzen unten)
   - YAML-Frontmatter beachten: `role`, `goal`, `inputs`, `outputs`, `acceptance_refs`
   - "## Operativer Modus" beachten: BMAD → PRP

4. **Compliance (SSOT Acceptance v1.1)**
   - `context/agents/_acceptance_v1.1.md` lesen (Core + Role Extensions)
   - DoD checken: `docs/definition-of-done.md`
   - Required Checks: Flutter CI (analyze-test, privacy-gate), CodeRabbit

5. **MIWF (Make It Work First)**
   - `docs/engineering/field-guides/make-it-work-first.md` befolgen
   - Happy Path zuerst, Guards nach Evidenz (Sentry/PostHog)
   - Engine darf nackt laufen — **Daten nie** (Consent/RLS/Secrets Pflicht)

6. **Arbeiten (BMAD → PRP)**
   - **BMAD (Plan):**
     - Business: Ziel/DSGVO-Impact
     - Modellierung: Flows/ERD/Datentypen
     - Architektur: Schnittstellen/Trigger/Upsert
     - DoD: Teststrategie (≥1 Unit + ≥1 Widget bei UI/DataViz)
   - **PRP (Run → Prove):**
     - Plan: Mini-Plan (Why/What/How)
     - Run: Kleinste Schritte (erst erklären, dann Code)
     - Prove: `flutter analyze`, `flutter test`, RLS-Check, DSGVO-Note
   - **Output:** PR + Tests + Docs (gemäß Rolle-spezifischem DoD)

7. **Soft-Gates (bei PR)**
   - Req'ing Ball: max. 5 Gaps (Was/Warum/Wie, File:Line)
   - UI-Polisher: 5 Verbesserungen (Kontrast/Spacing/Typo/Tokens/States)
   - QA-DSGVO: Privacy-Impact (Low/Medium/High)
   - CodeRabbit: "0 blocking issues" vor Merge

---

## Legacy-Hinweis (historisch, für Kontext)

> Legacy (vor Codex). Siehe context/agents/README.md für aktuelle Rollen/Governance.
> Interop: Inhalte hier nur als Referenz verwenden; operative Ausführung erfolgt Codex CLI-first (BMAD → PRP, DoD/Gates, CodeRabbit, DCM non-blocking).
> Hinweis: Links/Pfade können veraltet sein; maßgeblich ist AGENTS.md + context/agents/*.
> **Aktuell (Dual-Primary):** AGENTS.md für Codex, CLAUDE.md für Claude Code. Beide nutzen gleiche Dossiers/DoD/ADRs.

## Leitplanken (immer laden)
@docs/engineering/field-guides/make-it-work-first.md
@docs/definition-of-done.md
@context/ADR/0001-rag-first.md
@context/ADR/0002-least-privilege-rls.md
@context/ADR/0003-dev-tactics-miwf.md

## Rollen (Agenten-Dossiers als Governance)
@context/agents/01-ui-frontend.md
@context/agents/02-api-backend.md
@context/agents/03-db-admin.md
@context/agents/04-dataviz.md
@context/agents/05-qa-dsgvo.md

## Gold-Standards
- Architektur vor Interaktion
- RAG-First Wissenshierarchie
- Struktur vor Improvisation (BMAD/PRP)
- Kuratierter Minimalismus & Pragmatismus

## MIWF Merksatz
Engine darf nackt laufen — Daten nie (Consent/RLS/Secrets sind Pflicht).
