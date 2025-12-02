# LUVI · Claude Code Governance – Frontend Primary

---

## Runtime-Minimum (Cheat-Sheet)

> Dieses Minimum gilt für **jeden LUVI-UI-Task**. Details in den verlinkten Docs.

### MUST-Regeln

1. **Design Tokens:** Keine `Color(0xFF…)` oder Ad-hoc-Farben – nutze `DsColors`, `DsTokens`, `TextColorTokens` aus `lib/core/design_tokens/**`.
2. **Spacing & Radii:** Verwende `Spacing`, `Sizes`, `OnboardingSpacing.of(context)`, `ConsentSpacing` – keine eigenen `EdgeInsets`/`BorderRadius`.
3. **L10n first:** Alle User-Texte (inkl. Semantics-Labels) über `AppLocalizations.of(context)` – Keys in `app_de.arb` + `app_en.arb` pflegen.
4. **Navigation:** GoRouter-Helfer nutzen (`context.goNamed(...)`, `RouteNames`) – niemals rohe Pfad-Strings oder `Navigator.push`.
5. **A11y & Touch:** Interaktive Elemente brauchen `Semantics`-Label und Hitbox ≥ 44 dp (`Sizes.touchTargetMin`).
6. **Widget-Tests:** Neue Screens/Komponenten → mindestens 1 Widget-Test unter `test/features/**` mit `buildTestApp`.
7. **Privacy-Logging:** Nur `log`-Facade aus `lib/core/logging/logger.dart` (nutzt `sanitizeForLog`) – kein `print`/`debugPrint` mit PII.
8. **Kein `service_role`:** Niemals im Client-Code verwenden.

### Micro-Task-Modus

- **Was zählt als Micro:** Copy/L10n-Fix, Spacing-Korrektur, Icon-Tausch, fehlendes Semantics-Label – kein State-/Backend-Impact.
- **Minimal-Checks:** `scripts/flutter_codex.sh analyze` + betroffene Widget-Tests + kurze PR-Notiz.
- **Codex-Review:** nur bei State-/Backend-Berührung nötig; sonst reichen CI-Gates.

### Wann weitere Docs lesen?

| Situation | Lies zusätzlich |
|-----------|-----------------|
| Neuer Screen / komplexes Widget | `docs/engineering/checklists/ui_claude_code.md` |
| DataViz / Charts | `context/agents/04-dataviz.md` |
| State-Änderung / Navigation-Flow | `context/agents/01-ui-frontend.md`, BMAD Global |
| Unsicher bzgl. Gates / DoD | `context/agents/_acceptance_v1.1.md` |
| Dual-Agent-Handoff | `AGENTS.md` (Agent-Binding, Work-Modes) |

---

## 1. Scope & Role

- **Agent:** Claude Code (Anthropic IDE/terminal agent)
- **Primary domains:** ui-frontend, dataviz (Flutter screens, widgets, navigation, charts)
- **Secondary:** DSGVO awareness in UI (no PII logs, no `service_role` in the client)
- **Handoff:** All PRs from Claude Code must go through Codex review + CI + Greptile before merge.

## 2. Shared Governance

Claude Code always operates under the same governance as Codex:

- **AGENTS.md** – global agent index (Codex + Claude Code)
- **Role dossiers:**
  - context/agents/01-ui-frontend.md
  - context/agents/04-dataviz.md
- **Acceptance:** context/agents/_acceptance_v1.1.md
- **BMAD:**
  - Global: docs/bmad/global.md
  - Sprint-level BMADs
- **Product SSOT:**
  - docs/product/app-context.md
  - docs/product/roadmap.md
- **Answer format:** docs/engineering/assistant-answer-format.md
- **AI reviewer policy:** docs/engineering/ai-reviewer.md

## 3. Work Modes for Claude Code

### 3.1 UI / DataViz Feature (normal or large)

- Read BMAD Global + relevant Sprint BMAD.
- Implement the change in the Flutter UI (screens/widgets/navigation/charts).
- Run `flutter analyze` and the relevant `flutter test` cases.
- Open a PR with:
  - `Agent: Claude Code`
  - A short BMAD-slim summary
  - A link to or checklist from docs/engineering/checklists/ui.md (if available).

Then wait for Codex review. No merge without Codex approval.

### 3.2 UI Micro-Task

- Small visual / copy / layout tweaks without backend/state impact.
- Run `flutter analyze` + affected tests.
- PR with `Agent: Claude Code` tag.
- Codex review is only required if state/backend is touched.

## 4. BMAD-slim for UI

For any non-trivial UI/dataviz change, Claude Code should use a mental BMAD-slim structure:

- **Business:** 1–2 sentences about the goal + DSGVO impact (low/medium).
- **Modelling:** Flow: user action → screen → state (Riverpod) → service.
- **Architecture:** Which screens/widgets/providers are involved.
- **DoD (UI):**
  - `flutter analyze` ✅
  - ≥ 1 widget test for new screens/components ✅
  - UI checklist checked ✅
  - no PII in logs/debug output ✅

## 5. Required Checks Before Merge

A PR authored by Claude Code is only mergeable if:

- Flutter CI / analyze-test ✅
- Flutter CI / privacy-gate ✅
- Greptile review ✅
- Vercel preview `/api/health` returns 200 ✅
- Codex review ✅ (architecture, state management, DSGVO aspects)

## 6. Handoff Template to Codex (PR Body)

Claude Code SHOULD structure the PR description roughly like this:

Agent: Claude Code  
Domain: ui-frontend | dataviz  

### BMAD-slim
- Business: …
- Flow: …
- Architecture: …
- DoD: analyze ✅ · widget test ✅ · UI checklist ✅  

### Checklist
- [ ] docs/engineering/checklists/ui.md reviewed (if available)  
- [ ] No PII in logs or debug output  
- [ ] Loading / error / empty states covered  
- [ ] A11y checked (contrast, semantics, touch targets)  

Ready for Codex review ✅

## 7. Guardrails (MIWF)

- Make It Work First: implement the happy path, then harden error handling and edge cases.
- Never use `service_role` in the client.
- Do not log PII or send sensitive data to analytics.
