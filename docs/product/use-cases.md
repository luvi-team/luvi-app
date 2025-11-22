# Beispiel-Use-Case – Slim v1.3 (UI-Screen)

Ziel: Figma „Onboarding-Screen 02“ nach Flutter portieren – token-aware, gemäß Agenten-Governance & Soft-Gates.
SSOT Acceptance: context/agents/_acceptance_v1.1.md (Core + Role Extensions, Version 1.1).
Index: AGENTS.md im Repo-Root verweist auf Dossiers & SSOT.

---

## A) BMAD (Plan)
- Business: Willkommensscreen; keine PII → DSGVO-Low.
- Modellierung: Stateless UI; Design-Tokens maßgeblich.
- Architektur: Neues Widget + GoRouter-Route; keine Edge Function.
- DoD/Test (UI-spezifisch): flutter analyze ✅ · flutter test (≥1 Unit + ≥1 Widget) ✅ · Sentry/PostHog Smoke (UI) ✅ · UI-Polisher ok.
- Artefakte: Draft-PR öffnen; context/debug/memory.md kurz aktualisieren.

## B) Kontext holen & Code-Vorschlag
- In Codex arbeiten (CLI-first); Claude Code MCP nur falls Figma-MCP notwendig ist (Legacy/Interop).
- Tokenliste sichern, Figma-Frame/Node-Id referenzieren.
- Task (role: ui-frontend): Figma-Frame importieren & token-aware abbilden.

## C) Implementieren (PRP – Run)
- AI-pre Commit: Code einfügen/adaptieren (Tokens, saubere Imports/Theme).
- AI-post Commit-Notiz: Was/Warum/Wie sehr kurz.

## D) Prove (lokal)
- flutter analyze
- flutter test
- Widget-Test prüft Überschrift + Primär-Button; ggf. Semantik-Label (A11y).
- Optional: coderabbit review --plain -t uncommitted
- Optional: dart run dcm analyze (non-blocking)

## E) Soft-Gates (PR-Kommentare / Agenten)
- Req’ing-Ball: max. 5 Gaps (Was/Warum/Wie, File:Line; „none“, wenn vollständig).
- UI-Polisher: 5 konkrete Verbesserungen (Kontrast/Lesbarkeit, Spacing, Typo-Hierarchy, Token-Konformität, States).
- QA-DSGVO: „Low – keine DB/PII, kein Tracking, kein Consent-Impact“.
- Greptile Review: „0 blocking issues“ (Required Check); CodeRabbit (Lite) optional lokal.

## F) CI & Merge (Einzeiler)
- CI grün → Greptile Review grün → PR-Change-Report → Squash & Merge → Branch cleanup.
- Required Checks: Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · Greptile Review (Required Check). (CodeRabbit optional lokal)

## G) Memory aktualisieren
- context/debug/memory.md (1–3 Zeilen: Fokus, Fix-Log, Lesson Learned).

## Agenten – komprimierte Prompts
- UI-Frontend (Implementierung): keine Hardcodes, Tokens nutzen, GoRouter, Semantik-Labels; Aufgabe: Struktur, Snippets, Tokenliste, A11y-Hinweise.
- Req’ing-Ball (Requirement-Validator): max 5 Gaps; sonst „none“.
- UI-Polisher (visuelle Qualität): 5 konkrete Verbesserungen.
- QA-DSGVO (Low): knappe Bestätigung ohne DB/PII/Tracking.

## Mikro-Verbesserungen (optional)
- DoD explizit (3 Punkte): analyze ✅ · Widget-Test ✅ · UI-Polisher „0 blocking issues“.
- A11y Kurzliste: min. Tap-Target 44×44 pt; Semantics für Überschrift & CTA; Focus-Order logisch.
- Visual-Smoke: 1 Screenshot-/Golden-Test (optional).
- Token-Mapping: kurzer Satz „Figma→Flutter Mapping“ im PR.

## Ergänzungen v1.3 (Sept 2025 • Add-ons)
- DCM non-blocking in CI, Flutter-Version pinnen, Greptile Review als Required Check (CodeRabbit-Reviews optional lokal bei Ready for review).
