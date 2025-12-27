# Sprint 01 – Zyklus-Logik & Today-Badge

## 0. Meta

- Zeitraum: TODO
- Fokus/Thema: Zyklus-Logik & Today-Badge (Home + Kalender)
- Relevante Dossiers/ADRs: Phase-Definitionen, ADR-0002 (Least-Privilege & RLS), Roadmap S1
- DSGVO-Impact-Schwerpunkte (Low/Medium/High + warum): Medium – CycleData sind sensibel, aber Lifestyle-orientiert, kein Medizinprodukt; RLS owner-based, kein `service_role`

## 1. Business/Ziel

- 1.1 Sprint-Ziele (Was soll sich durch diesen Sprint für Nutzerinnen verändern?): Nutzerinnen sehen klar, in welcher Phase sie sind (Phase/Tag) und bekommen einen kurzen Heute-Hinweis; Today-Badge/Week-Strip basieren deterministisch auf ihren CycleData statt auf Platzhaltern; Home vermittelt Nutzen, ohne medizinische Beratung zu suggerieren.
- 1.2 Zielgruppe/Segment (falls enger als global): Zyklusbewusste Nutzerinnen (DACH, 18–45), die Alltag/Training/Regeneration grob an ihrem Zyklus ausrichten wollen und eine einfache, nicht-medizinische Darstellung bevorzugen.
- 1.3 Probleme, die adressiert werden (2–3 Bulletpoints):
  - Keine verständliche Phasenanzeige im Alltag; Badge/Week-Strip fehlen oder wirken ungenau.
  - Zyklus-Apps wirken oft medizinisch oder kompliziert, statt schnelle Orientierung zu geben.
  - Unklar, ob eingegebene CycleData überhaupt sichtbar wirken (wenig Feedback/Nutzengefühl).
- 1.4 Erwartete Verhaltens-/Outcome-Änderungen (z. B. Daily-Usage, Vertrauen, Feature-Adoption):
  - Today wird häufiger geöffnet, um Phase + kurzen Tipp zu prüfen.
  - Nutzerinnen pflegen CycleData vollständiger, weil Badge/Week-Strip Nutzen zeigen.
  - Trainings-/Alltagsplanung orientiert sich eher an der Phase-Hinweisgebung.
  - Phase-Badge wird als klar und lifestyle-orientiert verstanden, nicht als Diagnose.
- 1.5 Erfolgskriterien (2–3 KPIs/Messpunkte für diesen Sprint):
  - Mehr aktive Nutzerinnen haben vollständige CycleData (letzte Periode, Zykluslänge, Periodendauer) erfasst.
  - Anteil aktiver Nutzerinnen, die den Today/Home-View mindestens wöchentlich öffnen, steigt.
  - Qualitatives Feedback/Support-Hinweise zeigen, dass Phase-Badge und Today-Hinweis verstanden werden (keine medizinische Erwartung).

> Hinweis: Lehn dich an BMAD Global Kapitel 1 + den Roadmap-Eintrag für diesen Sprint an.

## 2. Modellierung

- 2.1 Betroffene Domänen (z. B. CycleData, DailyPlan, Content/Video, Consent, UserEvent …):
  - User – Besitzerin der CycleData, Referenz über `user_id` in allen Tabellen.
  - CycleData – enthält `last_period`, `cycle_length`, `period_duration`, `age` als Basis für Berechnung.
  - Phase – fachliches Modell (Menstruation/Follikel/Ovulation/Luteal), wird berechnet, nicht gespeichert.
  - Cycle/Phase Computation („TodayState“) – `compute_cycle_info` berechnet Phase/Tag aus CycleData für Badge/Week-Strip.
  - DailyPlan (optional Kontext) – Tagesprotokoll, kann zur Phase-Einordnung herangezogen werden, bleibt inhaltlich unverändert.
  - AnalyticsEvent (Today/Home) – Events wie `home_phase_rendered` und `cycle_input_completed` messen Nutzung/Vollständigkeit.

- 2.2 Betroffene Tabellen/Views (Supabase-Schema, inkl. Ist vs. Geplant):
  - `public.cycle_data` (Ist) – Basis für Zyklusberechnung, owner-based RLS.
  - `public.daily_plan` (Ist) – Tagesdaten; keine Schemaänderung geplant, optional für Kontext.
  - Analytics-Events (Logik-only, PostHog) – kein DB-Table; Events werden clientseitig gesendet.

- 2.3 Neue/angepasste Felder/Invarianten (z. B. neue Events, Phase-Scores, Flags):
  - CycleData-Felder im Fokus: `last_period` (Datum), `cycle_length` (Tage), `period_duration` (Tage), `age` (Jahre).
  - Mindestbasis für Berechnung: `last_period`, `cycle_length`, `period_duration` müssen gesetzt sein; sonst kein Badge/Week-Strip, stattdessen Prompt zur Datenerfassung.
  - Berechnung ist deterministisch und läuft clientseitig auf Basis der gespeicherten CycleData (kein `service_role`).
  - Werte außerhalb plausibler Grenzen werden gemäß Vertrag von `compute_cycle_info` geklammert/abgefangen; unplausible Eingaben verhindern die Phase-Anzeige und zeigen einen sicheren Fallback-Text (Hinweis auf Datenprüfung).
  - Heute-Badge/Week-Strip zeigen nur dann Phase/Tag, wenn Daten valide sind; unsichere/fehlende Daten → Fallback-Text statt Phase.

- 2.4 RLS-/Policy-Änderungen oder -Risiken (inkl. DSGVO-Impact):
  - RLS owner-based auf `public.cycle_data` (ADR-0002) gilt; nur Besitzerin liest/schreibt eigene Datensätze; kein cross-user read.
  - `public.daily_plan` ebenfalls owner-based; keine neuen Policies für Sprint 01 nötig.
  - Berechnung erfolgt im Client; Edge/Server sieht keine zusätzlichen CycleData-Aufrufe außer regulären CRUD.
  - DSGVO-Impact: CycleData sind sensible Lifestyle-Daten; Minimierung (nur nötige Felder), kein `service_role` im Client, Zugriff strikt user-gebunden.

> Hinweis: Nutze BMAD Global Kapitel 2 und die Roadmap-/Schema-Abschnitte als Quelle.

## 3. Architektur

- 3.1 Betroffene Komponenten (UI-Features, Services, Edge Functions, AI-Calls, Analytics):
  - Flutter Home/Today-Screen (`heute`) – zeigt Phase-Badge/Heute-Hinweis und Week-Strip auf Basis berechneter Phase.
  - Kalender/Zyklus-View – nutzt dieselbe Berechnung, um vergangene/kommende Phasen im Strip anzuzeigen.
  - Cycle-Input-Form (Onboarding/Edit) – erfasst/aktualisiert `last_period`, `cycle_length`, `period_duration`, `age`.
  - Services (`luvi_services` / SupabaseService) – CRUD auf `public.cycle_data` (optional read `daily_plan` für Kontext), owner-based.
  - Supabase-Tabellen: `public.cycle_data` (Pflicht), `public.daily_plan` (optional Kontext).
  - Analytics-Events: `cycle_input_completed`, `home_phase_rendered` (ggf. weitere Today-Events) zur Nutzungsmessung.

- 3.2 Haupt-Flow(s) dieses Sprints (in Alltagssprache, 3–5 Sätze):
  - Nutzerin gibt Zyklusdaten ein oder aktualisiert sie → App schreibt in `cycle_data` (owner-basiert) → Client berechnet Phase/Tag mit `compute_cycle_info` → Today-Badge und Week-Strip zeigen die aktuelle Phase + kurzen Hinweis.
  - Nutzerin öffnet Today → App lädt vorhandene CycleData → berechnet TodayState lokal → rendert Phase-Text/Label; fehlen Daten oder sind unplausibel, erscheint stattdessen ein freundlicher Prompt/Fallback.
  - Nutzerin wechselt in die Kalender-/Zyklus-Ansicht → dieselbe Berechnung liefert historische/kommende Phasen → Darstellung im Strip/Calendar; optionale Events loggen Aufruf/Anzeige.

- 3.3 Abhängigkeiten (Use-Cases, Screen-Contracts, Dossiers, ADRs, Runbooks):
  - `docs/product/screens/heute.md` – Screen-Contract für Today/Home inkl. Week-Strip und Hinweise.
  - Phase-Definitionen (`docs/phase_definitions.md`) – Namen/Dauern/Wechselkriterien als Grundlage für `compute_cycle_info`.
  - BMAD Global (Kap. 2 Modellierung, Kap. 3 Architektur) – Domänen- und Systemkontext.
  - Roadmap S1 (Zyklus-Logik & Home-Bindung) – Zielbild und Performance-Anforderung.
  - ADR-0002 (Least-Privilege & RLS) – Zugriffsvorgaben für `cycle_data`.
  - Healthcheck/Observability (platform/healthcheck.md) – Today-Badge soll Preview/Prod-Health nicht verletzen; Monitoring-Hinweise.

- 3.4 Technische Risiken & Constraints (Performance, Offline, Edge-Limits, Provider, Kosten):
  - Zeit-/Datums-Handling (Zeitzonen, lange/kurze Zyklen) → `compute_cycle_info` muss clampen/offen dokumentieren; Tests für Offsets/Edge-Cases.
  - Unvollständige oder unplausible CycleData → keine Phase-Anzeige, stattdessen Fallback/Prompt; keine „falschen“ Phasen rendern.
  - Performance im Client → Berechnung leichtgewichtig (P95 ≤ 50 ms laut Roadmap); keine Netzwerk-abhängigen Schritte für Phase-Compute.
  - RLS/Privacy → owner-based RLS auf `cycle_data`; kein `service_role` im Client; nur eigene Daten sichtbar.
  - UX-Risiko (keine Diagnosen) → Texte klar als Lifestyle-Hinweis formulieren, keine Gesundheitsversprechen.
  - Resilienz gegen fehlende Daten → UI muss ohne Crash rendern, auch wenn `cycle_data` leer ist; Prompts statt Exceptions.

> Hinweis: Lehn dich an BMAD Global Kapitel 3 + die passenden ADRs/Screen-Docs an.

## 4. Definition of Done (Sprint)

- 4.1 Tests  
  - Unit-Tests für `compute_cycle_info`/TodayState: normale/lange/kurze Zyklen, Offsets/Edge-Cases, unplausible Eingaben → Fallback.  
  - Widget-Tests für Today-Screen/Week-Strip: Phase-Anzeige korrekt bei validen Daten, Fallback/Prompt bei fehlenden/unplausiblen Daten.  
  - Optional manuell: CycleData ändern/speichern → Today-Label/Week-Strip aktualisiert; kein Crash bei leerem `cycle_data`.
- 4.2 Privacy/DSGVO  
  - DSGVO-Checklist (`docs/compliance/dsgvo_checklist.md`) für CycleData-Änderungen durchgehen (Minimierung, Zugriff, Zweck).  
  - Privacy-Review für Sprint 01 unter `docs/privacy/reviews/` anlegen/aktualisieren (CycleData Nutzung, keine Diagnose).  
  - Klarstellung in Doku/UI: CycleData lifestyle-orientiert, keine Heilversprechen/Diagnosen; owner-based Zugriff.
- 4.3 Observability  
  - Events gemäß Taxonomy nutzen: `cycle_input_completed`, `home_phase_rendered` (ggf. weitere Today-Events) und prüfen, dass sie gesendet werden.  
  - Sentry überwacht Today-/Cycle-Flow (keine Crashes in Phase-Badge/Week-Strip/Save).  
  - Einfaches Dashboard/Log-Check: Anteil, der Today öffnet + vollständige CycleData hat; Plausibilitätsblick auf Eventzahlen.
- 4.4 Weitere Gates  
  - Greptile Review grün; CI (analyze/test/privacy-gate) grün. (CodeRabbit optional lokal als Preflight, kein GitHub-Check; Policy siehe `docs/engineering/ai-reviewer.md`)  
  - `/api/health` bleibt grün; keine Regression laut platform/healthcheck.  
  - ADR-0002 geprüft: RLS owner-based, kein `service_role` im Client.  
  - Docs/ADR-Updates prüfen, falls Logik/Verträge angepasst wurden.

> Hinweis: Nutze BMAD Global Kapitel 4 + `docs/engineering/checklists/*.md` und `docs/compliance/dsgvo_checklist.md`.

## 5. Stories (Kurzüberblick)

- Story 1: S1-01 – CycleData Eingabe/Update (Onboarding & Settings) – Nutzerinnen erfassen/aktualisieren Basisdaten, damit Today-Badge und Hinweise spürbar persönlicher Nutzen stiften.
- Story 2: S1-02 – Today-Phasenanzeige mit Fallbacks – Heute-Screen zeigt klare Phase + kurzen Tipp; bei fehlenden/unplausiblen Daten erscheint ein sicherer Fallback statt falscher Phase.
- Story 3: S1-03 – Kalender-/Zyklus-Ansicht (Phase-Historie/Vorschau) – Nutzerinnen sehen vergangene/kommende Phasen auf einen Blick, was Planung und Erwartungsmanagement erleichtert.
- Story 4: S1-04 – Today/Cycle Analytics-Events – Relevante Events messen Datenerfassung und Phase-Rendering, um Adoption/Wertbeitrag sichtbar zu machen und Korrekturen zu ermöglichen.

> Hinweis: Hier kein volles Story-Template, nur Überblick. Details leben in Use-Cases, Traycer-Plan, PRs.

## 6. Referenzen

- Roadmap-Sprint: `docs/product/roadmap.md` (Abschnitt „S1 — Zyklus-Logik & Home-Bindung (deterministisch)`)
- Relevante Use-Cases (`docs/product/use-cases.md`): TODO – passenden Today/Cycle-Use-Case verlinken
- Relevante Screen-Contracts (`docs/product/screens/*.md`): `docs/product/screens/heute.md`
- Relevante Dossiers (Phase/Consent/Ranking): `docs/phase_definitions.md`, `docs/consent_texts.md`, `docs/ranking_heuristic.md`
- Relevante ADRs: `context/ADR/0002-least-privilege-rls.md`
- Traycer-Plan-File (falls gespeichert, z. B. `docs/traycer/sprint-XX-*.md`): TODO – Traycer-Plan verlinken
- Checklisten/DoD: `docs/definition-of-done.md`, `docs/engineering/checklists/ui.md`, `docs/engineering/checklists/db.md`, `docs/engineering/checklists/privacy.md`, `docs/analytics/taxonomy.md`
