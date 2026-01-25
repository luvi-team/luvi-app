# Sprint XX – <Kurzname>

## 0. Meta

- Zeitraum:
- Fokus/Thema:
- Relevante Dossiers/ADRs:
- DSGVO-Impact-Schwerpunkte (Low/Medium/High + warum):

## 1. Business/Ziel

- 1.1 Sprint-Ziele (Was soll sich durch diesen Sprint für Nutzerinnen verändern?):
- 1.2 Zielgruppe/Segment (falls enger als global):
- 1.3 Probleme, die adressiert werden (2–3 Bulletpoints):
- 1.4 Erwartete Verhaltens-/Outcome-Änderungen (z. B. Daily-Usage, Vertrauen, Feature-Adoption):
- 1.5 Erfolgskriterien (2–3 KPIs/Messpunkte für diesen Sprint):

> Hinweis: Lehn dich an BMAD Global Kapitel 1 + den Roadmap-Eintrag für diesen Sprint an.

## 2. Modellierung

- 2.1 Betroffene Domänen (z. B. CycleData, DailyPlan, Content/Video, Consent, UserEvent …):
- 2.2 Betroffene Tabellen/Views (Supabase-Schema, inkl. Ist vs. Geplant):
- 2.3 Neue/angepasste Felder/Invarianten (z. B. neue Events, Phase-Scores, Flags):
- 2.4 RLS-/Policy-Änderungen oder -Risiken (inkl. DSGVO-Impact):

> Hinweis: Nutze BMAD Global Kapitel 2 und die Roadmap-/Schema-Abschnitte als Quelle.

## 3. Architektur

- 3.1 Betroffene Komponenten (UI-Features, Services, Edge Functions, AI-Calls, Analytics):
- 3.2 Haupt-Flow(s) dieses Sprints (in Alltagssprache, 3–5 Sätze):
- 3.3 Abhängigkeiten (Use-Cases, Screen-Contracts, Dossiers, ADRs, Runbooks):
- 3.4 Technische Risiken & Constraints (Performance, Offline, Edge-Limits, Provider, Kosten):

> Hinweis: Lehn dich an BMAD Global Kapitel 3 + die passenden ADRs/Screen-Docs an.

## 4. Definition of Done (Sprint)

- 4.1 Tests  
  - Welche Tests müssen mindestens da sein (Unit, Widget, Integration/Manual) und für welche Teile?
- 4.2 Privacy/DSGVO  
  - Welche DSGVO-Checklisten, Impact-Level, Reviews sind Pflicht?
- 4.3 Observability  
  - Welche Events, Traces, Health-Checks müssen für diesen Sprint stehen?
- 4.4 Weitere Gates  
  - Spezifische Anforderungen an Greptile Review (Required Check), CI, ADR-Updates, Runbooks, Maintenance-Log (CodeRabbit optional lokal).

> Hinweis: Nutze BMAD Global Kapitel 4 + `docs/engineering/checklists/*.md` und `docs/compliance/dsgvo_checklist.md`.

## 5. Stories (Kurzüberblick)

- Story 1: <Id/Name> – 1 Satz Business/Ziel
- Story 2: …
- …

> Hinweis: Hier kein volles Story-Template, nur Überblick. Details leben in Use-Cases und PRs.

## 6. Referenzen

- Roadmap-Sprint: …
- Relevante Use-Cases (`docs/product/use-cases.md`): …
- Relevante Screen-Contracts (`docs/product/screens/*.md`): …
- Relevante Dossiers (Phase/Consent/Ranking): `docs/phase_definitions.md`, `docs/consent_texts.md`, `docs/ranking_heuristic.md`
- Relevante ADRs: …
- Checklisten/DoD: `docs/definition-of-done.md`, `docs/engineering/checklists/*.md`
