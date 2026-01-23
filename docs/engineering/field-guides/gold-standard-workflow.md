# Gold Standard Workflow (LUVI) — Implement → Audit → Proof

Version: 2026-01-13

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
- **Startpunkt:** `CLAUDE.md` (operativer Ablauf).
- **UI-Regeln SSOT:** `docs/engineering/checklists/ui_claude_code.md`

### 1.4 Optional: CodeRabbit local

- Optionaler Pre-Flight, um "schnelle" Blocker vor PR zu reduzieren.
- **Wichtig:** Merge-Gate bleibt Greptile (Required Check) + CI + Privacy Gate.

> **Vollständige Rollen-Dossiers:** `context/agents/01-05.md`

---

## 2) Governance (SSOT)

| Bereich | Dokument |
|---------|----------|
| Agent Governance | `AGENTS.md` + `context/agents/*` |
| Product SSOT | `docs/product/app-context.md`, `docs/product/roadmap.md` |
| Engineering SSOT | `docs/engineering/tech-stack.md`, `docs/engineering/ai-reviewer.md` |
| UI SSOT | `docs/engineering/checklists/ui_claude_code.md` |
| BMAD Framework | `docs/bmad/global.md` |

---

## 3) Definition of Done (DoD)

Ein PR ist "done", wenn:

- **(A) Kontext/Intent klar:** Was ist geändert, warum, welches Risiko?
- **(B) Plan vorhanden** (mindestens BMAD-slim; bei Medium/High: vollständiger BMAD).
- **(C) Proof vorhanden:**
  - analyze + tests (zielgerichtet)
  - ggf. Privacy-Review / Evidence
  - keine neuen harten Verstöße (PII, service_role, RLS aus)
- **(D) Reviewbar:**
  - Fokus auf kleine, nachvollziehbare Diffs
  - PRP/Notizen enthalten *was geprüft wurde*

> **Vollständige DoD:** `docs/definition-of-done.md` + `context/agents/_acceptance_v1.1.md`

---

## 4) Required Checks (CI-Gates)

Vor Merge müssen grün sein:

- Flutter analyze-test (CI)
- privacy-gate (CI)
- Greptile Review (Required Check)
- Vercel Preview Health: `/api/health` liefert 200

---

## 5) Role-spezifische DoD-Checks

| Rolle | Mindest-Checks |
|-------|----------------|
| ui-frontend | UI-Checklist SSOT + `flutter analyze` + passende Widget-Tests |
| dataviz | UI-Checklist SSOT + Chart-/Widget-Tests + States/A11y |
| api-backend | Contract/Unit-Tests + privacy-gate relevant + kein service_role |
| db-admin | RLS ON + Policies + least-privilege + Migration geprüft |
| qa-dsgvo | Privacy-Impact + Logging/PII geprüft + Consent korrekt |

> **Hinweis:** Für UI gilt zusätzlich ein Guard: Neue hardcodierte Farben/deutsche Strings können den Audit-Test triggern (`test/dev/audit/ui_guard_audit_test.dart`).

---

## 6) Prozess-Rahmen

```
1. Classify Impact
   └── Micro / Normal / High Impact (DB/PII/AI/Security = High)

2. Plan
   ├── Architect (Optional): Gemini plant Epics/Architektur
   ├── Feature: BMAD ausfüllen
   └── Micro: Mini-Plan (3 bullets)

3. Implement
   ├── UI/Dataviz → Claude Code
   └── Backend/DB/Privacy → Codex

4. Prove
   ├── analyze + gezielte Tests
   ├── ggf. Privacy-Review (High)
   └── Health-Gate (wenn API/Edge/Deploy relevant)

5. Review
   └── Greptile + (Codex Review bei UI-PRs) + (Human Review bei Gemini-PRs)

6. Merge
```

---

## 7) Tooling

| Tool | Zweck |
|------|-------|
| Gemini | Architektur & Orchestrierung, Governance-Updates |
| Codex CLI | Implementation/Review (Backend/DB/Privacy) |
| Claude Code | Implementation (UI/Dataviz), folgt `CLAUDE.md` |
| Archon/MCP | Tasks + RAG zu SSOTs |
| Supabase MCP | Schema/RLS/Policies read-only Kontext |
| Langfuse | Traces für `/api/ai/*` |
| Vercel | Preview/Health Gate |

> **Vollständige Tool-Matrix:** `docs/engineering/tech-stack.md`

---

## 8) Operative Routinen

- **Archon/MCP nicht erreichbar?** Arbeite direkt mit Repo-SSOTs und notiere kurz, welche Quellen du genutzt hast.
- **Unsicher ob Micro?** Konservativ eskalieren → "Normal Feature" (kurzer BMAD).
- **DB/PII betroffen?** Sofort High-Impact behandeln (Privacy/RLS nicht "nachziehen").

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

```markdown
**Was & Warum** (1–3 Sätze)

**Scope:** Micro/Normal/High + Begründung

**SSOTs genutzt:** (Links)

**Proof:**
- analyze ✅/❌
- tests ✅/❌ (welche)
- privacy ✅/n/a
- health ✅/n/a

**Risiken/Edge Cases** (kurz)

**Undo/Backout** (wie revert)
```

---

## 11) UX / UI Mini Rules

> **SSOT:** `docs/engineering/checklists/ui_claude_code.md`

Kerngedanke:
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

# Teil 2: Praktische Anleitung · Ultra-Slim (Quick-Reference)

> Für den täglichen Gebrauch — die wichtigsten Schritte auf einen Blick.

---

## Überblick — Was ändert sich?

**Vorher (ohne BMAD+):** Idee → Code → Merge → (hoffentlich keine Fehler)

**Jetzt (mit BMAD+):** Idee → BMAD (10–15 Min) → Code → Prove (5–10 Min) → Merge ✅

**Zusatzaufwand:** +15–20 Min bei High-Impact-Features → spart typ. >30 Min Hotfix-Stress später.

---

## Haupt-Aufgaben

### BMAD ausfüllen (vor dem Coden)

**Wann:** Feature mit DSGVO-Impact = Medium/High
**Dauer:** 10–15 Min

1. Archon-Dossier verlinken (Phase-Definitionen / Consent-Texte / Ranking-Heuristik)
2. BMAD-Template: **Business** · **Modellierung** · **Architektur** · **DoD**
3. In PR-Body oder separate Datei
4. An Dev-Agent posten:
   - UI/Dataviz → Claude Code (`CLAUDE.md` + `ui_claude_code.md`)
   - Backend/DB/Privacy → Codex (`AGENTS.md` + Dossiers)

### Runbook nutzen (bei Problemen)

**Wann:** Troubleshooting
**Dauer:** 3–5 Min

1. Runbook öffnen (`docs/runbooks/*.md`)
2. Commands ausführen → Output an Dev-Agent
3. Fix anwenden → Redeploy

### Prove (nach dem Code)

**Wann:** Nach Implementierung
**Dauer:** Self-Check 2–3 Min · DSGVO-Review 6–10 Min (nur High)

1. DSGVO-Review: `docs/privacy/reviews/feat-<feature>.md`
2. Falls `/api/ai/*` betroffen: Langfuse-Trace verlinken

---

## Quick-Table

| Aufgabe | Wann | Dauer | Schritte |
|---------|------|-------|----------|
| BMAD | Vor Code (Medium/High) | 10–15 Min | Template → PR-Body |
| Runbook | Troubleshooting | 3–5 Min | Runbook → Commands → Output |
| Prove | Nach Code | 5–10 Min | Self-Check → (High: DSGVO-Review) |

---

## Praxis-Use-Case: M4 Cycle-Input

**Feature:** Nutzerin gibt `cycle_length`, `period_length`, `lmp_date` ein
**Impact:** High (Gesundheitsdaten)

| Zeit | Aktivität |
|------|-----------|
| 09:10 | BMAD (10–12 Min) |
| 09:25 | Dev-Agent: Code + Migration (~20 Min) |
| 09:47 | Runbook: RLS-Check (5 Min) |
| 10:00 | Tests schreiben (~15 Min) |
| 10:20 | Prove: Self-Check + DSGVO-Review (10–13 Min) |
| 10:45 | PR → Greptile Review → Merge |

**Ergebnis:** ~70–75 Min · Vorher: ~120 Min → **≈ 40 % schneller**

---

## Lernkurve

| Meilenstein | Eigenaufwand | Trend |
|-------------|--------------|-------|
| M4 | ~30 Min | Baseline |
| M5 | ~23 Min | –23 % |
| M8 | ~18 Min | Autopilot |

---

## Final-Checklist (pro Feature)

- [ ] BMAD ausgefüllt (Business / Modellierung / Architektur / DoD)
- [ ] DSGVO-Review (falls High-Impact) mit Evidence
- [ ] Greptile Review grün
- [ ] CI/Privacy-Gate grün
- [ ] (UI) UI-Checklist beachtet + keine hardcoded Farben/Strings
- [ ] Merge

---

## Health-Gate

1. Preview öffnen → `/api/health` muss **200** liefern
2. Nach Merge Production prüfen → `/api/health` erneut **200**
3. Ergebnis im PR verlinken (siehe `docs/runbooks/vercel-health-check.md`)
