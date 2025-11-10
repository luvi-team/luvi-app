# LUVI Gold-Standard Workflow

## Ziel
Reproduzierbarer Solo-Dev-Prozess für DSGVO-konforme FemTech-App. Leitsatz: Architektur vor Interaktion.

## Rollen (5-Agenten)
UI/Frontend (Flutter + GoRouter + Riverpod)
API/Backend (Supabase Edge, Contracts/Validation, MIWF)
DB-Admin (Schema, Migrations, RLS owner-based)
QA/DSGVO (Privacy-Reviews, Opt-in/Opt-out, Audit-Trail)
Dashboard/DataViz (ab M11)

## Governance & ADRs
ADR-0001 RAG-First Wissenshierarchie: interne Refs/ADRs → Codebase → extern (sparsam, belegt) → LLM-Wissen.
ADR-0002 Least-Privilege & RLS: RLS ON, owner-Policies; service_role nie im Client.
ADR-0003 MIWF: Happy Path zuerst; Guards nur nach Evidenz (Sentry/PostHog).

## Definition of Done (DoD)
- CI grün (flutter analyze, flutter test)
- Tests: mind. ≥ 1 Unit + ≥ 1 Widget pro Story
- DSGVO-Review aktualisiert
- ADRs gepflegt
- PR-Template Pflichtfelder inkl. Babysitting-Level, AI pre/post Commit, RLS-Check
- CodeRabbit (Lite) Status grün (Branch-Protection Required)

## Required-Checks (GitHub, exakt)
- Flutter CI / analyze-test (pull_request) ✅
- Flutter CI / privacy-gate (pull_request) ✅
- CodeRabbit ✅

## Rollen-spezifische DoD-Checks
- UI/Frontend & DataViz: flutter analyze ✅ · flutter test (≥ 1 Unit + ≥ 1 Widget) ✅ · CodeRabbit ✅ · ADRs/DSGVO-Note ✅
- API/Backend: dart analyze, dart test (services/contracts) ✅ · Privacy-Gate (bei DB-Touches) ✅ · CodeRabbit ✅ · ADRs ✅
- DB-Admin: Migrations & RLS-Policies/Trigger aktualisiert + dokumentiert ✅ · Kein service_role im Client ✅ · Privacy-Gate ✅ · CodeRabbit ✅ · ADRs ✅
- QA/DSGVO: Privacy-Review (docs/privacy/reviews/.md) ✅ · Privacy-Gate ✅ · CodeRabbit ✅ · ADRs ✅

## Prozessrahmen
BMAD (vor Implementierung):
Business (Ziele, DSGVO) → Modellierung (Flows/ERD, Tabellen/Policies) → Architektur (Schnittstellen, Trigger, Upsert) → DoD/Teststrategie → Rollenabnahme.

PRP (je Story):
Plan (Mini-Plan + Why/What/How) → Run (kleinste Schritte; erst erklären, dann Befehle) → Prove (Lint/Tests/RLS/API-Checks; Diff; DSGVO-Notiz) → Ready for review.

## Soft-Gates
Req’ing Ball (max. 5 Gaps, Was/Warum/Wie, File:Line)
UI-Polisher (Tokens, Kontrast, Spacing, Typo, States)
CodeRabbit Lite (line-by-line)

## Agenten-Governance (aktualisiert)
- AGENTS.md (Repo-Root) als Index, Default Auto-Role, Misch-Tasks role: …
- Dossiers 01–05 unter context/agents/ als Governance-Quelle
- Header-Schema (Front-Matter): role, goal, inputs, outputs, acceptance, acceptance_version: 1.1
  - inputs beinhalten ERD: „PRD, ERD, ADRs 0001–0003, Branch/PR-Link“
  - acceptance verweist nur auf SSOT (Core + Role Extensions)
- SSOT Acceptance: context/agents/_acceptance_v1.1.md
- Interop/Legacy: .claude/*, CLAUDE.md nur Referenz; operativ Codex CLI-first.

## GitHub / Branch-Protection
Required Checks: Siehe „Required-Checks (GitHub, exakt)" oben (Zeile 26-29).


## Praktische Anleitung · Ultra-Slim (Traycer + BMAD + DSGVO + Health-Gate)
Version: 2025-10-15

### 0) Überblick – Was ändert sich?
Vorher (ohne B+): Idee → Code → Merge → (hoffentlich keine Fehler)
Jetzt (mit B+ + Traycer): Idee → Traycer-Plan (5–8 Min) → BMAD (10–15 Min) → Code → Prove (Self-Check + DSGVO, 5–10 Min) → Merge ✅
Zusatzaufwand: +15–20 Min bei High-Impact-Features (M4–M9) → spart typ. >30 Min Hotfix-Stress später.

Links: Traycer Prompt `docs/engineering/traycer/prompt-mini.md`, BMAD Template `context/templates/bmad-template.md`, RLS Runbook `docs/runbooks/debug-rls-policy.md`, Health Runbook `docs/runbooks/vercel-health-check.md`.

### 1) Haupt-Aufgaben (mit Traycer)

#### 1.1 BMAD ausfüllen & Traycer-Plan erstellen (vor dem Coden)
Wann: bei jedem neuen Feature mit DSGVO-Impact = Medium/High
Dauer: Traycer-Plan 5–8 Min · BMAD 10–15 Min (ab dem 3. Mal schneller)

Vorgehen:
1) Traycer in Cursor öffnen → Generate Plan/Phases (max. 10 Schritte inkl. Tests & Fehlerfälle)
2) Datei speichern: `docs/traycer/<ticket>.md` (Ziel · Plan/Checkliste · Risiken · Test-Notizen)
3) BMAD-Template: Business (Ziel + DSGVO-Impact) · Modellierung (Daten/Flows) · Architektur (Screens/Services/DB + RLS) · DoD
4) In PR-Body oder separate Datei einfügen
5) BMAD an Codex / Claude posten → Umsetzung starten
6) Archon (MCP): Relevantes Dossier (Phase, Consent, Ranking) kurz aktualisieren und im PR verlinken

#### 1.2 Runbook nutzen (bei Problemen)
Wann: Troubleshooting (z. B. RLS-Fail, Edge-Function 500, Consent-Bug)
Dauer: 3–5 Min

Vorgehen:
1) Passendes Runbook öffnen (z. B. `docs/runbooks/debug-rls-policy.md`, `docs/runbooks/vercel-health-check.md`)
2) Kommandos ausführen → Output an Codex/Claude
3) Fix anwenden → Redeploy (Preview)

#### 1.3 Prove nach dem Code (Self-Check & DSGVO-Review)
Wann: nach Implementierung · DSGVO-Review nur bei High-Impact
Dauer: Self-Check 2–3 Min · DSGVO-Review 6–10 Min

Vorgehen:
1) Traycer-Self-Check: Plan ↔ Diff vergleichen; Abweichungen in `docs/traycer/<ticket>.md` unter „Ergebnis/Abweichungen“ notieren; im PR Feld „Traycer-Self-Check“ ✅ setzen
2) DSGVO-Review: Template öffnen → neues File `docs/privacy/reviews/feat-<feature>.md` (9 Abschnitte: Purpose · Data-Flow · PII · Consent · Evidence/RLS-Test-Output) → Sign-off
3) Langfuse: Bei AI-Touches (`/api/ai/*`) Trace öffnen und Link + kurze Notiz (Token/Kosten, Latenz) in den PR aufnehmen

#### 1.4 Supabase MCP (DB-Änderungen)
Wann: Schema-/Policy-Änderungen, Migrations, Reviews

Vorgehen:
1) Staging + read-only Role für `describe`/`plan`/`explain` nutzen (Supabase MCP)
2) SQL-Migrationen im PR bereitstellen (kein direkter Prod-Write), Review via CodeRabbit, Rollout via CI
3) Langfuse-Trace optional verlinken, falls AI-gestützte Planung verwendet wurde

### 2) Aufgaben-Übersicht (Quick-Table)
| Aufgabe           | Wann                    | Dauer    | Schritte                                                     |
|-------------------|-------------------------|----------|--------------------------------------------------------------|
| Traycer-Plan      | Vor Code (Medium/High)  | 5–8 Min  | Plan/Phases → `docs/traycer/<ticket>.md`                     |
| BMAD              | Vor Code (Medium/High)  | 10–15 Min| Template ausfüllen → PR-Body/Datei                           |
| Runbook           | Troubleshooting          | 3–5 Min  | Runbook öffnen → Commands → Output an Codex/Claude           |
| Prove             | Nach Code                | 5–10 Min | Self-Check → DSGVO-Review → Sign-off                         |
| Langfuse-Trace    | Nach Code (bei AI-Touch) | 1–2 Min  | Trace öffnen → Link + Notiz (Token/Kosten, Latenz) in PR     |
| Supabase MCP      | Bei DB-Änderungen        | 5–10 Min | `describe/plan` in Staging → Migration per PR/CI             |

### 3) Praxis-Use-Case: M4 Cycle-Input
Feature: Nutzerin gibt `cycle_length`, `period_length`, `lmp_date` ein · Impact: High (Gesundheitsdaten)

09:00 Traycer-Plan (5–8 Min) → Datei anlegen
09:10 BMAD (10–12 Min)
09:25 Codex/Claude: Code + Migration (~20 Min)
09:47 Runbook: RLS-Check (5 Min)
10:00 Tests schreiben (~15 Min)
10:20 Prove: Self-Check (2–3 Min) + DSGVO-Review (8–10 Min) → Evidence ergänzen; Langfuse (falls AI) verlinken
10:45 PR → CodeRabbit → Merge

Ergebnis: ~70–75 Min (davon ~30–35 Min du) · Vorher: ~120 Min → ≈ 40 % schneller, weniger Hotfix-Risiko ✅

### 4) Lernkurve
M4 ≈ 30 Min Eigenaufwand · M5 ≈ 23 Min (–23 %) · M8 ≈ 18 Min → nahezu Autopilot (Plan/Checklisten wiederverwendbar)

### 5) Final-Checklist (pro Feature)
- Traycer-Plan verlinkt (PR-Feld) & Privacy-Mode ON
- BMAD ausgefüllt (Business / Modellierung / Architektur / DoD)
- Traycer-Self-Check ✅ (Abweichungen dokumentiert)
- DSGVO-Review (falls High-Impact) mit Evidence
- Langfuse-Trace (falls AI) verlinkt (Token/Kosten & Latenz notiert)
- Supabase MCP: Migrations per PR/CI (kein Prod-Write)
- CodeRabbit grün · CI/Privacy-Gate grün · Merge

### 6) Health-Gate (DoD-Referenz)
1) Preview öffnen → `/api/health` muss 200 liefern (Proof: Edge-Gateway läuft).  
2) Nach Merge: Production prüfen → `/api/health` erneut 200.  
3) Ergebnis im PR verlinken (siehe `docs/runbooks/vercel-health-check.md`).
