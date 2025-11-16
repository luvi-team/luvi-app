# Gold-Standard Workflow (Flutter · Supabase · DSGVO-first)
Version: 2025-10-15

## 0) Ziel & Leitsatz
- Ziel: Reproduzierbarer Solo-Dev-Prozess für eine DSGVO-konforme FemTech-App.  
- Leitsatz: Architektur vor Interaktion.

## 1) Rollen (5-Agenten)
1. UI/Frontend — Flutter, GoRouter, Riverpod  
2. API/Backend — Supabase Edge, Contracts/Validation, MIWF  
3. DB-Admin — Schema, Migrations, RLS (owner-based)  
4. QA/DSGVO — Privacy-Reviews, Opt-in/Opt-out, Audit-Trail  
5. Dashboard/DataViz — ab M11 (Statistics)

## 2) Governance & ADRs
- ADR-0001 · RAG-First Wissenshierarchie  
  Interne Refs/ADRs → Codebase → extern (sparsam, belegt) → LLM-Wissen.
- ADR-0002 · Least-Privilege & RLS  
  RLS ON, owner-Policies; service_role niemals im Client.
- ADR-0003 · MIWF  
  Happy Path zuerst; Guards nach Evidenz (Sentry/PostHog).
- ADR-0004 · Vercel Edge Gateway (EU/fra1)  
  Edge Functions als einzige Einstiegsschicht; `/api/health` als Betriebs-Gate; PII-Redaction & CORS-Whitelist.

## 3) Definition of Done (DoD)
- CI grün: `flutter analyze` · `flutter test`  
- Tests: ≥ 1 Unit + ≥ 1 Widget pro Story  
- DSGVO-Review aktualisiert; ADRs gepflegt  
- PR-Template Pflichtfelder inkl. Babysitting-Level, AI pre/post Commit, RLS-Check  
- CodeRabbit (Lite) grün (Branch-Protection required)  
- Traycer-Plan verlinkt; Traycer Self-Check; Privacy-Mode ON; keine PII/Secrets  
- Neu (Video): Archon aktualisiert (Dossier/Policy, die Story betrifft, verlinkt)  
- Neu (Video): Langfuse verlinkt (Trace-URL + kurze Notiz zu Token/Kosten & Latenz, falls `/api/ai/*` betroffen)  
- Neu (Dev): Supabase MCP Guard (MCP nur gegen Staging; Änderungen via Migrations PR, nicht direkt in Prod)

Vercel Health-Gate  
- Vor Merge: Preview testen → `/api/health → 200 OK` ✅  
- Nach Merge: Production Smoke → `/api/health → 200` ✅  
- Ergebnis im PR verlinken (`docs/runbooks/vercel-health-check.md`)

## 4) Required Checks (GitHub)
- Flutter CI / analyze-test ✅  
- Flutter CI / privacy-gate ✅  
- CodeRabbit ✅  
- Vercel Preview Health (`/api/health → 200`) ✅  
- (Empfohlen für AI-Features) Langfuse Trace vorhanden (Link im PR)

## 5) Rollen-spezifische DoD-Checks
| Rolle | Muss-Kriterien |
|---|---|
| UI/Frontend & DataViz | `flutter analyze` ✅ · ≥1 Unit + ≥1 Widget ✅ · CodeRabbit ✅ · ADR/DSGVO-Notiz ✅ |
| API/Backend | `dart analyze` · `dart test` ✅ · Privacy-Gate bei DB-Touches ✅ · Vercel Health Preview/Prod ✅ · CodeRabbit ✅ · ADRs ✅ |
| DB-Admin | Migrations & RLS/Trigger aktualisiert + dokumentiert ✅ · kein `service_role` im Client ✅ · Privacy-Gate ✅ · CodeRabbit ✅ · ADRs ✅ |
| QA/DSGVO | Privacy-Review (`docs/privacy/reviews/*.md`) ✅ · Privacy-Gate ✅ · Vercel Health Preview/Prod ✅ · CodeRabbit ✅ · ADRs ✅ |

## 6) Prozessrahmen
### BMAD (vor Implementierung)
Business (Ziele/DSGVO) → Modellierung (Flows/ERD, Tabellen/Policies) → Architektur (Schnittstellen, Trigger, Upsert) → DoD/Teststrategie → Rollenabnahme.

### PRP (je Story) – Two-Model-Review integriert
Plan (Mini-Plan + Why/What/How) → Run (kleinste Schritte; erst erklären, dann ausführen) →  
Prove (Lint/Tests/RLS/API-Checks; Diff; DSGVO-Notiz; Langfuse-Link, falls AI) → Preview Health-Gate (Vercel) →  
Ready for Review (CodeRabbit-Review).

### Soft-Gates
- Req’ing Ball: max 5 Gaps (Was/Warum/Wie, File:Line)  
- UI-Polisher: Tokens, Kontrast, Spacing, Typo, States  
- Traycer Plan/Verification: non-blocking (frühe Plan-Konformität)  
- Vercel Health-Preview: non-blocking für Dev, blocking vor Merge

## 7) Tooling & Konventionen
- IDE: Cursor (Repo-Explorer; leichte Edits)  
- Terminal: frei wählbar (Warp entfernt)  
- AI-Coding:  
  - Claude Code (Primary, Video-Empfehlung): Multi-File, Migrations, agentische Steps  
  - Codex/GPT 5 High (Review & Plan): Zweitmeinung vor PR; erzeugt Mini Plan/Tests  
- Knowledge SSOT (neu, Video): Archon (MCP) – Dossiers/Policies/Runbooks, MCP abrufbar in Claude/Codex  
- LLM Observability (neu, Video): Langfuse – Traces/Token/Kosten/Latenz/Tool Calls/Evals  
- DB Ops (neu, Dev): Supabase MCP – Staging + read only→Review→CI; keine direkten Prod Writes  
- Deployment: Vercel (EU/fra1 Edge Functions) · Preview je PR · Prod nach grünem CI/Health  
- Code Qualität: `flutter_lints` · DCM (findings ja, Gate nein) · CodeRabbit (Lite) GitHub App + CLI  
- `.coderabbit.yaml`: `reviews.profile=assertive`, `auto_review.drafts=false`, `commit_status.enabled=true`  
- Branch Protection: Require PR; Required Checks (analyze test, privacy gate, CodeRabbit, Vercel Preview Health); Conversation resolution empfohlen

## 8) Operative Routinen
- Project Memory (SSOT): `context/debug/memory.md`  
- Self Documenting PRs: CI erstellt `context/changes/pr-<nr>.md`  
- Branch Hygiene: nach Merge lokal & remote löschen (`git fetch -p`)  
- Privacy Reviews: `docs/privacy/reviews/<branch>.md`  
- Deployment Review: `docs/runbooks/vercel-health-check.md` (Health 200 = Proof)

## 9) Assistenten Antwortformat (v2)
Mini Kontext Check → Warum → Schritte (copy fähig) → Erfolgskriterien (rollenbasiert + RLS/Consent, Sentry/PostHog Smoke, CodeRabbit, Vercel Health) → Undo/Backout (nur Code Block) → Nächster Schritt → Stop Kriterien.

## 10) Safety Guards
Keine destruktiven Commands (DROP/RESET/--hard) · Undo/Backout nur als Code Block · UI Assets read only · Secrets Deny (`.env*`) · Kein Admin Merge bei rotem CodeRabbit · Pre commit Secret Hook nicht umgehen · MCP: keine write Scopes auf Prod; destructive SQL default deny.

## 11) Versionierung / Stack Hinweis
Flutter 3.35.4 / Dart 3.9.0 (pinned) · Abgleich mit Tech Stack & Roadmap (M0–M13) · Health Check (`/api/health`) Pflicht Gate.


# Praktische Anleitung · Ultra-Slim (Traycer + BMAD + DSGVO + Health-Gate)
Version: 2025-10-15

## 0) Überblick – Was ändert sich?
Vorher (ohne B+): Idee → Code → Merge → (hoffentlich keine Fehler)  
Jetzt (mit B+ + Traycer): Idee → Traycer-Plan (5–8 Min) → BMAD (10–15 Min) → Code → Prove (Self-Check + DSGVO, 5–10 Min) → Merge ✅  
Zusatzaufwand: +15–20 Min bei High-Impact-Features (M4–M9) → spart typ. >30 Min Hotfix-Stress später.

---

## 1) Haupt-Aufgaben (mit Traycer)

### 1.1 BMAD ausfüllen & Traycer-Plan erstellen (vor dem Coden)
Wann: bei jedem neuen Feature mit DSGVO-Impact = Medium/High  
Dauer: Traycer-Plan 5–8 Min · BMAD 10–15 Min (ab dem 3. Mal schneller)

Vorgehen:
0) Archon-Dossier verlinken: Im PR unter „Verwendete Dossiers“ das passende Dossier nennen (z. B. Phase-Definitionen v1.x / Consent-Texte v1.x / Ranking-Heuristik v1.x).  
1) Traycer in Cursor öffnen → Generate Plan / Phases (max. 10 Schritte inkl. Tests & Fehlerfälle)  
2) Datei speichern: `docs/traycer/<ticket>.md` (Ziel · Plan/Checkliste · Risiken · Test-Notizen)  
3) BMAD-Template: Business (Ziel + DSGVO-Impact) · Modellierung (Daten/Flows) · Architektur (Screens/Services/DB + RLS) · DoD  
4) In PR-Body oder separate Datei einfügen  
5) BMAD an Codex / Claude posten → Umsetzung starten

### 1.2 Runbook nutzen (bei Problemen)
Wann: Troubleshooting (z. B. RLS-Fail, Edge-Function 500, Consent-Bug)  
Dauer: 3–5 Min

Vorgehen:
1) Passendes Runbook öffnen (z. B. `docs/runbooks/debug-rls-policy.md`, `docs/runbooks/vercel-health-check.md`)  
2) Kommandos ausführen → Output an Codex/Claude  
3) Fix anwenden → Redeploy (Preview)

### 1.3 Prove nach dem Code (Self-Check & DSGVO-Review)
Wann: nach Implementierung · DSGVO-Review nur bei High-Impact  
Dauer: Self-Check 2–3 Min · DSGVO-Review 6–10 Min

Vorgehen:
1) Traycer-Self-Check: Plan ↔ Diff vergleichen; Abweichungen in `docs/traycer/<ticket>.md` unter „Ergebnis/Abweichungen“ notieren; im PR Feld „Traycer-Self-Check“ ✅ setzen  
2) DSGVO-Review: Template öffnen → neues File `docs/privacy/reviews/feat-<feature>.md` (9 Abschnitte: Purpose · Data-Flow · PII · Consent · Evidence/RLS-Test-Output) → Sign-off  
3) (falls AI-Route `/api/ai/*` betroffen) Langfuse-Trace verlinken: Im PR die zugehörige Trace-URL (Request-ID) einfügen, damit Prompt/Token/Latenz belegbar sind.

---

## 2) Aufgaben-Übersicht (Quick-Table)

| Aufgabe        | Wann                    | Dauer     | Schritte                                              |
|----------------|-------------------------|-----------|-------------------------------------------------------|
| Traycer-Plan   | Vor Code (Medium/High)  | 5–8 Min   | Plan/Phases → `docs/traycer/<ticket>.md`              |
| BMAD           | Vor Code (Medium/High)  | 10–15 Min | Template ausfüllen → PR-Body/Datei                    |
| Runbook        | Troubleshooting         | 3–5 Min   | Runbook öffnen → Commands → Output an Codex/Claude    |
| Prove          | Nach Code               | 5–10 Min  | Self-Check → DSGVO-Review → Sign-off                  |

---

## 3) Praxis-Use-Case: M4 Cycle-Input
Feature: Nutzerin gibt `cycle_length`, `period_length`, `lmp_date` ein · Impact: High (Gesundheitsdaten)

09:00 Traycer-Plan (5–8 Min) → Datei anlegen  
09:10 BMAD (10–12 Min)  
09:25 Codex/Claude: Code + Migration (~20 Min)  
09:47 Runbook: RLS-Check (5 Min)  
10:00 Tests schreiben (~15 Min)  
10:20 Prove: Self-Check (2–3 Min) + DSGVO-Review (8–10 Min) → Evidence ergänzen  
10:45 PR → CodeRabbit → Merge

Ergebnis: ~70–75 Min (davon ~30–35 Min du) · Vorher: ~120 Min → ≈ 40 % schneller, weniger Hotfix-Risiko ✅

---

## 4) Lernkurve
M4 ≈ 30 Min Eigenaufwand · M5 ≈ 23 Min (–23 %) · M8 ≈ 18 Min → nahezu Autopilot (Plan/Checklisten wiederverwendbar)

---

## 5) Final-Checklist (pro Feature)
- Traycer-Plan verlinkt (PR-Feld) & Privacy-Mode ON  
- BMAD ausgefüllt (Business / Modellierung / Architektur / DoD)  
- Traycer-Self-Check ✅ (Abweichungen dokumentiert)  
- DSGVO-Review (falls High-Impact) mit Evidence  
- CodeRabbit grün · CI/Privacy-Gate grün · Merge

---

## 6) Health-Gate (optional, DoD-Referenz)
-(für Parität mit Gold-Standard & Tech-Stack; Roadmap koppelt Health-Baseline in M4.5)  
1) Preview öffnen → `/api/health` muss 200 liefern (Proof Edge-Gateway läuft).  
2) Nach Merge Production prüfen → `/api/health` erneut 200.  
3) Ergebnis im PR verlinken (siehe `docs/runbooks/vercel-health-check.md`).
