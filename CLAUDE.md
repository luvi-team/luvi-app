# LUVI Project Memory

## Leitplanken (immer laden)
- [Make It Work First](docs/engineering/field-guides/make-it-work-first.md)
- [Definition of Done](docs/definition-of-done.md)
- [ADR-0001: RAG-First](context/ADR/0001-rag-first.md)
- [ADR-0002: Least-Privilege RLS](context/ADR/0002-least-privilege-rls.md)
- [ADR-0003: Dev-Taktik MIWF](context/ADR/0003-dev-tactics-miwf.md)

## Rollen (Agenten-Dossiers als Governance)
- [UI Frontend](context/agents/ui-frontend.md)
- [API Backend](context/agents/api-backend.md)
- [DB Admin](context/agents/db-admin.md)
- [Dashboard DataViz](context/agents/dataviz.md)
- [QA DSGVO Monitor](context/agents/qa-dsgvo.md)

## Gold-Standards
- **Architektur vor Interaktion**  
  → Erst Schema/RLS modellieren (db-admin), dann API (api-backend), dann UI (ui-frontend)
- **RAG-First Wissenshierarchie**  
  → Nutze zuerst interne Refs/ADRs, dann Code, erst zuletzt externes Wissen
- **BMAD/PRP Workflow**  
  → BMAD: Business (Ziel, DSGVO) → Modell (Flows, Tabellen) → Architektur (APIs, Trigger) → DoD (Tests, Reviews)  
  → PRP: Plan (Mini-Plan + Why/What/How) → Run (kleinster Schritt) → Prove (Lint/Tests/RLS)
- **Kuratierter Minimalismus**  
  → Nur das Nötige implementieren (Happy Path). Guards, Edge-Cases erst nach echten Fehlern

## MIWF Merksatz
Engine darf nackt laufen — Daten nie (Consent/RLS/Secrets sind Pflicht).

## Antwortformat (für alle Agents und Assistenten)
1. **Mini-Kontext-Check** - Sprint-Goal, DoD, relevante ADRs, Memory
2. **Warum** - Business-Grund für diese Aktion
3. **Schritte** - Deterministisch, copy-paste-fähig
4. **Erfolgskriterien** - flutter analyze ✅ · flutter test (≥1 Unit + ≥1 Widget) ✅ · RLS/Consent (falls relevant) ✅ · Sentry/PostHog Smoke (bei UI) ✅
5. **Undo/Backout** - Befehle zur Rücknahme (als Code-Block, nicht ausführen!)
6. **Nächster minimaler Schritt** - Was kommt direkt danach
7. **Stop-Kriterien** - Was zum sofortigen Abbruch führt

## Operative Routinen
- **Project-Memory:** `context/debug/memory.md` - Fokus, Bugs, Fix-Log (2-3 Zeilen pro PR)
- **Privacy-Reviews:** `docs/privacy/reviews/<branch>.md` - DSGVO-Checks dokumentiert
- **Figma-Tokens:** Immer `@figma get_variable_defs` VOR Code-Generation
- **Self-Documenting PRs:** CI erzeugt `context/changes/pr-<number>.md`

## Git/PR Workflow
1. Feature-Branch erstellen (`feat/`, `fix/`, `docs/`)
2. Draft-PR früh öffnen für Transparenz
3. Soft-Gates als PR-Comments (Req'ing Ball, UI-Polisher)
4. qa-dsgvo Review vor Merge (Privacy Gate bei DB-Änderungen)
5. Nach Merge: Branch cleanup (`git fetch -p`)
