# Gold Standard Workflow (LUVI) — Implement → Audit → Proof

(Updates: Claude-Code/Runtime-Minimum-Verweis, UI-Checklist SSOT, Micro-Tasks + UI-Guard-Audit klargezogen)

This is the one document that defines the gold standard for shipping LUVI changes.
If you follow it, you minimize: regressions, privacy mistakes, review ping-pong.

---

## 0) Ziel

- **Sicher shippen:** keine Privacy-/Security-Fehler, keine Datenleaks, keine "quick & dirty" PRs.
- **Reproduzierbar shippen:** jeder PR hat Plan → Änderung → Proof.
- **Schnell bleiben:** Micro-Tasks dürfen schlank sein (ohne Overkill).

---

## 1) Rollen / Agents

> Idee: "Wer macht was?" ist klar, damit nicht *alle alles* machen.

### 1.1 Gemini (Architect & Orchestrator)

- **Fokus:** System-Architektur, Governance, komplexe Planung, Refactoring-Strategien.
- **Startpunkt:** `GEMINI.md`.
- **Aufgabe:** Erstellt Epics, aktualisiert SSOTs und zerlegt Aufgaben für Codex/Claude.

### 1.2 Codex CLI (Dev + Review Agent, Backend/DB/Privacy-first)

- **Fokus:** Backend, DB, RLS, Privacy/QA, Contracts, harte Gates, CI/Checks.
- Arbeitet CLI-first und liefert PRP/patches, inkl. Tests/Proof.
- Wenn UI/Frontend betroffen ist: kann reviewen (oder harte DoD/Gates durchsetzen).

### 1.3 Claude Code (Dev Agent, UI/Frontend + DataViz)

- **Fokus:** Flutter UI, Widgets, Navigation, Design Tokens, A11y, DataViz.
- Startpunkt/"Runtime-Minimum" für Claude Code Sessions: `CLAUDE.md` (operativer Ablauf).
- UI-Regeln als SSOT: `docs/engineering/checklists/ui_claude_code.md` (nicht in PRs duplizieren).

### 1.4 Traycer (Plan Agent)

- Erzeugt Plan/Phasen + Risiken + Test-Notizen (kurz, maximal ~10 Steps).
- Ergebnis landet als Datei unter `docs/traycer/<ticket>.md` (oder als PR-Body-Plan).

### 1.5 Optional: CodeRabbit local

- Optionaler Pre-Flight, um "schnelle" Blocker vor PR zu reduzieren.
- **Wichtig:** Merge-Gate bleibt Greptile (Required Check) + CI + Privacy Gate.

---

## 2) Governance (SSOT)

- **Agent Governance:** `AGENTS.md` + `context/agents/*` (Dossiers, Auto-Role Map, Acceptance).
- **Product SSOT:**
  - `docs/product/app-context.md`
  - `docs/product/roadmap.md`
- **Engineering SSOT:**
  - `docs/engineering/tech-stack.md`
  - `docs/engineering/assistant-answer-format.md`
  - `docs/engineering/ai-reviewer.md`
- **UI SSOT (für Claude Code / UI-PRs):**
  - `docs/engineering/checklists/ui_claude_code.md`
  - (generischer Spickzettel optional: `docs/engineering/checklists/ui.md`)

---

## 3) Definition of Done (DoD)

Ein PR ist "done", wenn:

- **(A) Kontext/Intent klar:** Was ist geändert, warum, welches Risiko?
- **(B) Plan vorhanden** (mindestens BMAD-slim; bei Medium/High: Traycer-Plan).
- **(C) Proof vorhanden:**
  - analyze + tests (zielgerichtet)
  - ggf. Privacy-Review / Evidence
  - keine neuen harten Verstöße (PII, service_role, RLS aus)
- **(D) Reviewbar:**
  - Fokus auf kleine, nachvollziehbare Diffs
  - PRP/Notizen enthalten *was geprüft wurde*

---

## 4) Required Checks (CI-Gates)

Vor Merge müssen grün sein:

- Flutter analyze-test (CI)
- privacy-gate (CI)
- Greptile Review (Required Check)
- Vercel Preview Health: `/api/health` liefert 200

---

## 5) Role-spezifische DoD-Checks (Minimum)

| Rolle | Mindest-Checks |
|-------------|----------------|
| ui-frontend | UI-Checklist SSOT + `flutter analyze` + passende Widget-Tests |
| dataviz | UI-Checklist SSOT + Chart-/Widget-Tests + States/A11y |
| api-backend | Contract/Unit-Tests + privacy-gate relevant + kein service_role |
| db-admin | RLS ON + Policies + least-privilege + Migration geprüft |
| qa-dsgvo | Privacy-Impact + Logging/PII geprüft + Consent korrekt |

> **Hinweis:** Für UI gilt zusätzlich ein Guard: Neue hardcodierte Farben/deutsche Strings können den Audit-Test triggern (`test/dev/audit/ui_guard_audit_test.dart`).
> **Sinn:** Tokens + AppLocalizations erzwingen, ohne "Legacy" sofort zu blocken.

---

## 6) Prozess-Rahmen (Gold Standard)

1. **Classify Impact**
   - Micro / Normal / High Impact (DB/PII/AI/Security = High)

2. **Plan**
   - **Architect (Optional):** Gemini plant Epics/Architektur.
   - **Feature:** Traycer-Plan + BMAD.
   - **Micro:** Mini-Plan (3 bullets).

3. **Implement**
   - Dev-Agent je Domäne:
     - UI/Dataviz → Claude Code
     - Backend/DB/Privacy → Codex

4. **Prove**
   - analyze + gezielte Tests
   - ggf. Privacy-Review (High)
   - Health-Gate (wenn API/Edge/Deploy relevant)

5. **Review**
   - Greptile + (Codex Review bei UI-PRs) + (Human Review bei Gemini-PRs)

6. **Merge**

---

## 7) Tooling (was wir einsetzen)

- **Gemini:** Architektur & Orchestrierung, Governance-Updates.
- **Codex CLI:** Implementation/Review (Backend/DB/Privacy), läuft über Wrapper-Scripts.
- **Claude Code:** Implementation (UI/Dataviz), folgt `CLAUDE.md` Runtime-Minimum + UI-Checklist SSOT.
- **Archon/MCP:** Tasks + RAG zu SSOTs (wenn verfügbar); sonst Repo-SSOT-Fallback.
- **Supabase MCP:** Schema/RLS/Policies read-only Kontext.
- **Langfuse:** Traces, wenn `/api/ai/*` betroffen.
- **Vercel:** Preview/Health Gate.

---

## 8) Operative Routinen (damit es "in der Praxis" klappt)

- Wenn Archon/MCP nicht erreichbar ist: arbeite direkt mit den Repo-SSOTs (App-Kontext, Roadmap, Tech-Stack, Dossiers) und notiere kurz, welche Quellen du genutzt hast.
- Wenn du unsicher bist, ob Micro oder nicht: konservativ eskalieren → "Normal Feature" (kurzer BMAD).
- Wenn DB/PII betroffen: sofort High-Impact behandeln (Privacy/RLS nicht "nachziehen").

---

## 9) Micro-Tasks (Fast Lane)

**Micro** = kleine, lokale Änderung ohne neue Datenflüsse, ohne neue Routen, ohne neue Provider/DB.

**Beispiele:**
- Copy/L10n Fix
- Spacing/Token Fix
- Semantics/Label ergänzen

**Mindestanforderung:**
- `flutter analyze`
- betroffene Tests laufen lassen (gezielt)
- PR-Notiz: "Warum micro", "was getestet", Link auf relevante Acceptance/Dossier-Section

Alles darüber hinaus → Normal Flow (BMAD → PRP).

---

## 10) Output Template (für PR / Review)

- **Was & Warum** (1–3 Sätze)
- **Scope** (Micro/Normal/High + Begründung)
- **SSOTs genutzt** (Links)
- **Proof:**
  - analyze ✅/❌
  - tests ✅/❌ (welche)
  - privacy ✅/n/a
  - health ✅/n/a
- **Risiken/Edge Cases** (kurz)
- **Undo/Backout** (wie revert)

---

## 11) UX / UI Mini Rules (Frontend)

Nicht hier ausformulieren — sondern SSOT nutzen:

- **UI-Regeln (kanonisch):** `docs/engineering/checklists/ui_claude_code.md`
- **Kerngedanke:**
  - Tokens statt hardcoded values
  - L10n statt deutscher Strings
  - Navigation über Named Routes
  - Semantics/A11y standardmäßig

---

## 12) Safety Guards (DSGVO & Security)

- Kein `service_role` im Client.
- Keine PII in Logs (sanitize/redact; keine freien Formtexte loggen).
- RLS ist Default für sensitive Daten; least-privilege.
- Consent ist nicht optional: wenn Datenfluss/Tracking, dann Consent sauber.

---
---

# Praktische Anleitung · Ultra-Slim (Traycer + BMAD + DSGVO + Health-Gate)

(Updates: "Dev-Agent je Domäne" statt "immer Codex", Verweis auf Claude Code Runtime-Minimum + UI-Checklist + UI-Guard-Audit)

---

## 0) Überblick – Was ändert sich?

**Vorher (ohne B+):** Idee → Code → Merge → (hoffentlich keine Fehler)

**Jetzt (mit B+ + Traycer):** Idee → Traycer-Plan (5–8 Min) → BMAD (10–15 Min) → Code → Prove (Self-Check + DSGVO, 5–10 Min) → Merge ✅

**Zusatzaufwand:** +15–20 Min bei High-Impact-Features → spart typ. >30 Min Hotfix-Stress später.

> **Micro-Tasks** (Mini-Fixes) sind eine Ausnahme: dort reicht der Micro-Task-Flow aus den Rollen-Dossiers (kein voller Traycer/BMAD nötig).

---

## 1) Haupt-Aufgaben (mit Traycer)

### 1.1 BMAD ausfüllen & Traycer-Plan erstellen (vor dem Coden)

**Wann:** bei jedem neuen Feature mit DSGVO-Impact = Medium/High

**Dauer:** Traycer-Plan 5–8 Min · BMAD 10–15 Min

**Vorgehen:**

0. **Archon-Dossier verlinken:** Im PR unter „Verwendete Dossiers" das passende Dossier nennen (z. B. Phase-Definitionen v1.x / Consent-Texte v1.x / Ranking-Heuristik v1.x).

1. Traycer öffnen → *Generate Plan / Phases* (max. 10 Schritte inkl. Tests & Fehlerfälle)

2. Datei speichern: `docs/traycer/<ticket>.md` (Ziel · Plan/Checkliste · Risiken · Test-Notizen)

3. BMAD-Template: **Business** (Ziel + DSGVO-Impact) · **Modellierung** (Daten/Flows) · **Architektur** (Screens/Services/DB + RLS) · **DoD**

4. In PR-Body oder separate Datei einfügen

5. BMAD an den ausführenden Dev-Agent posten → Umsetzung starten
   - **UI/Dataviz:** Claude Code (Startpunkt: `CLAUDE.md` + UI-Checklist `docs/engineering/checklists/ui_claude_code.md`)
   - **Backend/DB/Privacy:** Codex CLI (Startpunkt: `AGENTS.md` + Dossiers)

### 1.2 Runbook nutzen (bei Problemen)

**Wann:** Troubleshooting (z. B. RLS-Fail, Edge-Function 500, Consent-Bug)

**Dauer:** 3–5 Min

**Vorgehen:**

1. Passendes Runbook öffnen (z. B. `docs/runbooks/debug-rls-policy.md`, `docs/runbooks/vercel-health-check.md`)

2. Kommandos ausführen → Output an den Dev-Agent (und ggf. an Reviewer)

3. Fix anwenden → Redeploy (Preview)

### 1.3 Prove nach dem Code (Self-Check & DSGVO-Review)

**Wann:** nach Implementierung · DSGVO-Review nur bei High-Impact

**Dauer:** Self-Check 2–3 Min · DSGVO-Review 6–10 Min

**Vorgehen:**

1. **Traycer-Self-Check:** Plan ↔ Diff vergleichen; Abweichungen in `docs/traycer/<ticket>.md` unter „Ergebnis/Abweichungen" notieren; im PR Feld „Traycer-Self-Check" ✅ setzen

2. **DSGVO-Review:** Template öffnen → neues File `docs/privacy/reviews/feat-<feature>.md` (Purpose · Data-Flow · PII · Consent · Evidence/RLS-Test-Output) → Sign-off

3. **(falls AI-Route `/api/ai/*` betroffen)** Langfuse-Trace verlinken: Trace-URL (Request-ID) ins PR, damit Prompt/Token/Latenz belegbar sind.

---

## 2) Aufgaben-Übersicht (Quick-Table)

| Aufgabe | Wann | Dauer | Schritte |
|-------------|------------------------|-----------|----------|
| Traycer-Plan | Vor Code (Medium/High) | 5–8 Min | Plan/Phases → `docs/traycer/<ticket>.md` |
| BMAD | Vor Code (Medium/High) | 10–15 Min | Template ausfüllen → PR-Body/Datei |
| Runbook | Troubleshooting | 3–5 Min | Runbook öffnen → Commands → Output |
| Prove | Nach Code | 5–10 Min | Self-Check → (High: DSGVO-Review) |

---

## 3) Praxis-Use-Case: M4 Cycle-Input (Beispiel)

**Feature:** Nutzerin gibt `cycle_length`, `period_length`, `lmp_date` ein · Impact: High (Gesundheitsdaten)

- 09:00 Traycer-Plan (5–8 Min) → Datei anlegen
- 09:10 BMAD (10–12 Min)
- 09:25 Dev-Agent: Code + Migration (~20 Min)
- 09:47 Runbook: RLS-Check (5 Min)
- 10:00 Tests schreiben (~15 Min)
- 10:20 Prove: Self-Check (2–3 Min) + DSGVO-Review (8–10 Min) → Evidence ergänzen
- 10:45 PR → Greptile Review (Required Check) → Merge (optional: lokales CodeRabbit-Review vor dem PR)

**Ergebnis:** ~70–75 Min · Vorher: ~120 Min → ≈ 40 % schneller, weniger Hotfix-Risiko ✅

---

## 4) Lernkurve

M4 ≈ 30 Min Eigenaufwand · M5 ≈ 23 Min (–23 %) · M8 ≈ 18 Min → nahezu Autopilot (Plan/Checklisten wiederverwendbar)

---

## 5) Final-Checklist (pro Feature)

- Traycer-Plan verlinkt (PR-Feld) & Privacy-Mode ON
- BMAD ausgefüllt (Business / Modellierung / Architektur / DoD)
- Traycer-Self-Check ✅ (Abweichungen dokumentiert)
- DSGVO-Review (falls High-Impact) mit Evidence
- Greptile Review grün · CI/Privacy-Gate grün · Merge
- (UI-relevant) UI-Checklist beachtet (`ui_claude_code.md`) + keine neuen hardcoded Farben/Strings (UI-Guard-Audit kann anschlagen)

---

## 6) Health-Gate (optional, DoD-Referenz)

*(für Parität mit Gold-Standard & Tech-Stack; Roadmap koppelt Health-Baseline in M4.5)*

1. Preview öffnen → `/api/health` muss **200** liefern (Proof Edge-Gateway läuft).

2. Nach Merge Production prüfen → `/api/health` erneut **200**.

3. Ergebnis im PR verlinken (siehe `docs/runbooks/vercel-health-check.md`).
