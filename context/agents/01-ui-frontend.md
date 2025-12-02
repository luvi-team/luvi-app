---
role: ui-frontend
goal: UX-Konsistenz sichern; token-aware Widgets/Screens mit Tests.
primary_agent: Claude Code
review_by: Codex
inputs:
  - PRD
  - ERD
  - ADRs 0001–0004
  - Branch/PR-Link
  - docs/product/app-context.md
  - docs/engineering/tech-stack.md
  - docs/product/use-cases.md
  - docs/engineering/assistant-answer-format.md
outputs:
  - PR-Checks grün
  - Widget-Tests
  - UI-Doku unter docs/
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: ui-frontend

## Ziel
Sichert UX-Konsistenz und Testabdeckung im Flutter-Frontend (Happy Path zuerst).

## Inputs
PRD, ERD, ADRs 0001–0004, Branch/PR-Link.

## Outputs
PR-Checks grün (flutter analyze/test), Widget-Tests, UI-Dokumentation unter docs/.

## Handoffs
PRs gehen an Codex zur technischen Review (Architektur, State-Management, DSGVO). Danach Übergabe an api-backend mit PR-Beschreibung + `test/**` + `docs/**`.

## Operativer Modus
Claude Code implementiert Screens/Widgets/Navigation inkl. Tests und BMAD-slim, Codex reviewed jeden PR vor Merge (Architecture + Privacy Checks).

## Checklisten & Runbooks
- Claude-Code UI-Checklist (kanonische UI-Regeln): `docs/engineering/checklists/ui_claude_code.md`
- UI‑Checklist (generischer Spickzettel): `docs/engineering/checklists/ui.md`

## Micro-Tasks (minimaler Modus)
- Beispiele: kleine Copy-/L10n-Anpassung via `lib/l10n/app_{de,en}.arb`, Abstandskorrektur mit `Spacing`/`OnboardingSpacing`/`ConsentSpacing`, Ersetzen eines hardcodierten `Text` durch `AppLocalizations`, Icon-Tausch oder Einsatz eines DS-Widgets (z. B. `BackButtonCircle`, `LinkText`), fehlendes `Semantics`-Label/Key ergänzen.
- Mindest-Checks: `scripts/flutter_codex.sh analyze` ausführen und betroffene Widget-Tests (bestehende `test/features/...`) laufen lassen; kurze PR-Beschreibung inkl. Hinweis auf getestete Dateien, Referenz auf `_acceptance_v1.1.md` für die Gate-Liste.
- Alles darüber hinaus (State-Änderungen, Navigation, neue Widgets) benötigt den regulären BMAD → PRP-Flow mit vollständigen Acceptance-Checks.
