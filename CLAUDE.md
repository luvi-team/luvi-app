# LUVI Project Memory

## Modus-Wahl (automatisch erkannt)

**Codex CLI:** Nutzt AGENTS.md (nicht diese Datei). `/status` liest AGENTS.md automatisch.
**Claude Code:** Nutzt diese Datei. Auto-Load aktiv. Folge "Claude Code Arbeitsablauf" unten.

---

## Hinweise (Legacy & Format-Gleichheit)

- Legacy-Links: Einige @-Referenzen/Links können historisch (Legacy) sein. Maßgeblich sind die Dossiers unter `context/agents/*` und die SSOT Acceptance v1.1 (`context/agents/_acceptance_v1.1.md`).
- Format-Gleichheit: Die Claude-Checkpoints (Role/BMAD/Prove) verlangen inhaltlich dasselbe wie die Codex-CLI Erfolgskriterien im `docs/engineering/assistant-answer-format.md` — beide basieren auf SSOT v1.1.

---

## Auto-Sizing & Compact Mode

**Ziel:** Weniger Reibung bei Kleinst-Tasks, ohne Governance (SSOT v1.1) zu verwässern.

**Automatische Erkennung (Heuristik):**
- Klein/Low-Impact (Compact Mode geeignet), wenn typisch:
  - Keywords: UI/Widget/Theme/Layout/Copy/Navigation/Test-Kleinigkeit
  - Diff-Scope: nur `lib/` (UI), `docs/` (ohne Privacy), keine `supabase/`, keine Migrations/Edge Functions
  - Kein PII/RLS-Marker: kein `CREATE TABLE`, `CREATE POLICY`, `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`, kein `auth.uid()`, kein `service_role`
  - Umfang: ≤ 2–3 Dateien, ≲ 50 geänderte Zeilen
  - DSGVO-Impact: Low
- Groß/Medium/High-Impact (Vollmodus), wenn u. a.:
  - DB-Migrationen, RLS-Policies/Trigger, neue Tabellen/Spalten, Consent-Scopes
  - Edge Functions/Services, externe Datenübermittlung, neue PII/Health-Daten
  - DSGVO-Impact: Medium/High

**Overrides (du kannst steuern):**
- Im Prompt angeben (optional): `role: <rolle>`, `impact: low|medium|high`, `size: small|large`, `compact: on|off`
- Deine Angaben haben Vorrang vor der Auto-Heuristik.

**Verhalten im Compact Mode** (nur wenn `size: small` UND `impact: low`):
- Checkpoint 1: Role-Line inkl. „Compact Mode“
- Checkpoint 2 (BMAD): ultrakurz (1–3 Zeilen), Impact explizit „Low“
- Checkpoint 3 (Prove): `flutter analyze` + relevante Tests; kein RLS-/Consent-Evidence
- Keine Runbooks/Reviews nötig; weiterhin SSOT-konform

**Verhalten im Vollmodus** (Standard bei `impact: medium|high` oder Unklarheit):
- Vollständiges BMAD (Business/Modellierung/Architektur/DoD)
- Prove mit Evidenz: `flutter analyze`, `flutter test`, RLS-Check (4 Schritte), DSGVO-Note
- Bei Unklarheit stellt Claude 2–3 kurze Klärungsfragen (z. B. DB-Write? neue Policies? Consent?)

**Sicherheitsgeländer (niemals Compact Mode):**
- Verdacht auf PII/Health-Daten, DB-Schreibvorgänge, neue/änderte RLS/Consent, externe Übermittlung
- `impact: high` → immer Vollmodus

**Beispiele:**
- Klein: „UI-Text auf Home-Screen ändern“ → `ui-frontend`, Impact=Low → Compact Mode
- Groß: „Spalte `notes` zu `cycle_logs` hinzufügen“ → `db-admin`, Impact=High → Vollmodus (RLS/Consent/Review)

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
   - SSOT: context/agents/_auto_role_map.md (Änderungen bitte dort pflegen)
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

## Auto-Checks (vor PR-Merge)

**Zweck:** Vibe-Coder Safety-Rails — verhindert vergessene kritische Schritte.

**Checkliste (VOR `git push` / PR-Merge):**

- [ ] **BMAD fertig?** (Business/Modellierung/Architektur/DoD vollständig)
  - Template: `context/templates/bmad-template.md`
  - ⚠️ STOP wenn leer → Template ausfüllen

- [ ] **DSGVO-Impact korrekt?** (Low/Medium/High gem. Definition)
  - Referenz: `docs/privacy/dsgvo-impact-levels.md`
  - ⚠️ STOP wenn Impact = High, aber keine Privacy-Review → erstelle `docs/privacy/reviews/<branch>.md`

- [ ] **RLS-Check grün?** (bei Impact = High/Medium)
  - Runbook: `docs/runbooks/debug-rls-policy.md`
  - 4 Schritte: RLS ON → Policies 4× → Trigger → anon-test denied
  - ⚠️ STOP wenn RLS-Check fails → Fix vor Merge

- [ ] **Tests grün?** (≥1 Unit + ≥1 Widget bei UI/DataViz)
  - `flutter analyze` → 0 errors
  - `flutter test` → all tests passed
  - ⚠️ STOP wenn Tests rot → Fix vor Merge

- [ ] **Runbook befolgt?** (bei Troubleshooting)
  - RLS-Debug: `docs/runbooks/debug-rls-policy.md`
  - Edge Function: `docs/runbooks/test-edge-function-locally.md`
  - Consent: `docs/runbooks/verify-consent-flow.md`

- [ ] **Required Checks grün?** (GitHub Branch-Protection)
  - Siehe: `context/agents/_acceptance_v1.1.md#core`
  - Flutter CI / analyze-test ✅
  - Flutter CI / privacy-gate ✅
  - CodeRabbit ✅

- [ ] **Kein service_role im Client?** (ADR-0002 Least-Privilege)
  - Check: `grep -r "service_role" lib/` → keine Treffer
  - ⚠️ STOP wenn gefunden → service_role nur in Edge Functions

**Wenn ALLE Checkboxen ✅ → Merge erlaubt.**

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

## Templates & Runbooks (bei Bedarf laden)

**Templates (Dokumentation/Planning):**
- BMAD: `context/templates/bmad-template.md` (Business → Modellierung → Architektur → DoD)
- DSGVO-Review: `context/templates/dsgvo-review-template.md` (Privacy-Review für High-Impact Features)
- DSGVO-Impact-Levels: `docs/privacy/dsgvo-impact-levels.md` (Low/Medium/High Definition)

**Runbooks (Troubleshooting/Testing):**
- RLS-Debug: `docs/runbooks/debug-rls-policy.md` (6 Steps: RLS ON → Policies → Trigger → Tests)
- Edge Function Test: `docs/runbooks/test-edge-function-locally.md` (Supabase lokal testen)
- Consent-Flow Verify: `docs/runbooks/verify-consent-flow.md` (Consent End-to-End testen)

**Wann nutzen:**
- Templates: Bei BMAD-Planung (M4+), Privacy-Review (High-Impact)
- Runbooks: Bei RLS-Fehlern, Edge-Function-Deploy, Consent-Bugs

## MIWF Merksatz
Engine darf nackt laufen — Daten nie (Consent/RLS/Secrets sind Pflicht).
