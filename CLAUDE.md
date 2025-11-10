# LUVI Project Memory

## Modus-Wahl (automatisch erkannt)

**Codex CLI:** Nutzt AGENTS.md (nicht diese Datei). `/status` liest AGENTS.md automatisch.
**Claude Code:** Nutzt diese Datei. Auto-Load aktiv. Folge "Claude Code Arbeitsablauf" unten.

---

## Quickstart / Where to start (SSOT)
- App‑Kontext: `docs/product/app-context.md:1`
- Tech‑Stack: `docs/engineering/tech-stack.md:1`
- Roadmap: `docs/product/roadmap.md:1`
- Gold‑Standard Workflow (inkl. „Praktische Anleitung · Ultra‑Slim“): `docs/engineering/gold-standard-workflow.md:62`

---

## Claude Code Arbeitsablauf (immer befolgen bei Claude Code Sessions)

**KRITISCHE REGEL: Checkpoints sind PFLICHT, nicht optional.**

Jede Antwort MUSS enthalten:
1. **Checkpoint 1** (erste Zeile): 🔵 Role + Keywords
2. **Checkpoint 2** (nach Plan): 🟢 BMAD fertig [Details]
3. **Checkpoint 3** (nach Prove): ✅ Prove abgeschlossen [Results]

**Fehlt ein Checkpoint → Task ist nicht vollständig.**

---

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
     - Mehrere Matches → Primär = höchste Priorität (siehe unten), sekundär erwähnen
     - Kein Match → User fragen
   - **Priorität bei Multi-Match:**
     - P1 (höchste): db-admin (Security/RLS), qa-dsgvo (DSGVO/Privacy)
     - P2 (mittel): api-backend (Backend-Logik)
     - P3 (niedrig): ui-frontend, dataviz (UI/Visualization)
     - Bei gleicher Priorität: Stärkstes Keyword-Match (explizit > implizit)
   - **Ankündigen:** "Arbeite als [rolle] (erkannt: [keywords])"
   - **Checkpoint 1 (Pflicht):** Erste Zeile jeder Antwort:
     ```
     🔵 Role: [rolle] | Keywords: [keyword1, keyword2, ...]
     ```

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
   - **Checkpoint 2 (Pflicht):** Nach BMAD explizit ankündigen:
     ```
     🟢 BMAD fertig
     Business: [1 Satz Ziel + DSGVO-Impact]
     Modellierung: [Datentypen/Flows]
     Architektur: [Schnittstellen]
     DoD: [Teststrategie]
     ```
   - **PRP (Run → Prove):**
     - Plan: Mini-Plan (Why/What/How)
     - Run: Kleinste Schritte (erst erklären, dann Code)
     - Prove: `flutter analyze`, `flutter test`, RLS-Check, DSGVO-Note
   - **Checkpoint 3 (Pflicht):** Nach Prove explizit bestätigen:
     ```
     ✅ Prove abgeschlossen
     - flutter analyze: ✅ [oder ❌ mit Fehler]
     - flutter test: ✅ [X Unit + Y Widget]
     - RLS-Check (bei DB-Ops):
       1. RLS ON für Tabelle: `SELECT relrowsecurity FROM pg_class WHERE relname='<table>';`
       2. Policies existieren: `SELECT * FROM pg_policies WHERE tablename='<table>';`
       3. Test als anon-user: `psql -U anon -> SELECT * FROM <table>; → denied`
     - DSGVO-Note: ✅ [Low/Medium/High] (bei PII-Ops)
     ```
   - **Output:** PR + Tests + Docs (gemäß Rolle-spezifischem DoD)

7. **Soft-Gates (VOR PR-Erstellung, als finales Selbst-Review)**
   - Req'ing Ball: max. 5 Gaps (priorisiert nach Severity: Critical > High > Medium > Low; Was/Warum/Wie, File:Line)
   - UI-Polisher: 5 Verbesserungen (Kontrast/Spacing/Typo/Tokens/States)
   - QA-DSGVO: Privacy-Impact (Low/Medium/High)
   - CodeRabbit: "0 blocking issues" vor Merge

---

## Konflikt-Regeln (bei Unklarheiten)

**User vs DoD:**
- DoD hat Priorität. Bei Widerspruch: User informieren, DoD-Anforderung erklären, Kompromiss anbieten.

**Prove-Fehler:**
- Stop sofort. Task als "blocked" markieren. User informieren + konkrete Fehler zeigen. Fix anbieten oder User um Entscheidung bitten.

**Unklare Task:**
- Nicht raten. User fragen: "Für Klarheit benötige ich: [Context/PRD/ERD/etc.]"

**Fehlende Inputs:**
- PRD/ERD fehlt? → User fragen.
- Optional: Mock-Daten anbieten ("Soll ich mit Placeholder arbeiten?").

---

## Versions-Historie (historisch, nicht mehr gültig)

> **Historisch (vor Dual-Primary, nicht mehr gültig):**
> - Ursprünglich war CLAUDE.md "nur Referenz", operativ galt nur Codex.
> - Inhalte waren passive @-Referenzen zu Leitplanken (ADRs, DoD, MIWF).
>
> **Aktuell (ab Commit ba5b7d8):**
> - Dual-Primary Modus: AGENTS.md für Codex, CLAUDE.md für Claude Code.
> - Beide Tools nutzen gleiche Governance (Dossiers, DoD, ADRs, SSOT v1.1).
> - CLAUDE.md enthält jetzt operative Anweisungen (Auto-Role, BMAD → PRP, Compliance-Checks).

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
