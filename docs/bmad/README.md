# LUVI – BMAD Framework (Global & Sprints)

Dieses Verzeichnis beschreibt, **wie BMAD in LUVI verwendet wird** –
für mich selbst, für Agents (Codex, Traycer, GPT) und für zukünftige
Team-Mitglieder.

BMAD = Business → Modellierung → Architektur → Definition of Done.

Es gibt zwei Ebenen:

1. **BMAD Global** – beschreibt das System als Ganzes.  
2. **BMAD Sprint** – beschreibt einen konkreten Sprint / ein Feature.

---

## 1. BMAD Global

**Datei:** `docs/bmad/global.md`

BMAD Global ist das „Master Brain“ für LUVI. Es fasst kurz zusammen:

- **1. Business (Global)**  
  Vision, Zielgruppe, Hauptprobleme, Value Proposition, Rolle von
  Zyklus/Hormonen, globale KPIs. Basierend auf App-Kontext, Roadmap und
  Dossiers.

- **2. Modellierung (Domain & Daten)**  
  Domänen (User, CycleData, Phase, Content/Video, Consent, Events,
  Programme, …) inkl. Mapping auf Supabase-Tabellen/Views und Status
  (Ist/Geplant/Logik-only/Copy).

- **3. Architektur (System & Flows)**  
  Hauptbausteine (App, Supabase, Vercel Edge, AI-/Observability-Layer,
  Analytics/Push, CI/CD, Security) und zentrale Flows (FTUE, Today,
  Stream, Coach, Kalender, Healthcheck).

- **4. Definition of Done (DoD & Quality Gates)**  
  Globales DoD, rollen-spezifische DoD-Erweiterungen (ui-frontend,
  api-backend, db-admin, qa-dsgvo, dataviz), Required Checks (CI,
  Greptile Review, Health, Privacy; CodeRabbit optional lokal als Preflight, kein GitHub-Check; Details: `docs/engineering/ai-reviewer.md`), AI-/MCP-Gates und Runbooks.

- **5. Quellen & Referenzen**  
  Verweise auf App-Kontext, Roadmap, Dossiers, Tech-Stack, ADRs,
  Checklisten, Privacy-Docs, Runbooks.

> **Regel:** BMAD Global erfindet nichts Neues, sondern fasst nur
> die existierenden SSOT-Dokumente zusammen und verlinkt sie.  
> Änderungen an der „Wahrheit“ passieren in App-Kontext, Roadmap,
> Dossiers, ADRs, Checklisten etc. – BMAD Global wird nur angepasst,
> wenn sich das System wirklich ändert (z. B. neue Domäne, neue ADR).

---

## 2. BMAD Sprint

**Template:** `docs/bmad/sprints/sprint-00-template.md`  
**Beispiel:** `docs/bmad/sprints/sprint-01-cycle-today.md`

Ein Sprint-BMAD ist ein **leichtgewichtiges Briefing-Dokument** für einen
Sprint / ein Feature. Es hat diese Struktur:

- **0. Meta**  
  Zeitraum, Fokus/Thema, relevante Dossiers/ADRs, DSGVO-Impact.

- **1. Business/Ziel**  
  Sprint-Ziele, Zielgruppe (falls enger), Probleme, erwartete Outcomes,
  Sprint-spezifische Erfolgskriterien (2–3 KPIs/Messpunkte).

- **2. Modellierung**  
  Betroffene Domänen und Tabellen/Views, neue/angepasste Felder,
  Invarianten (z. B. Mindestdaten, Fallback-Regeln), RLS-/Policy-Risiken.

- **3. Architektur**  
  Betroffene Komponenten (UI, Services, Edge/AI, Analytics), Haupt-Flows
  des Sprints, Abhängigkeiten (Use-Cases, Screen-Contracts, Dossiers,
  ADRs, Runbooks), technische Risiken/Constraints.

- **4. Definition of Done (Sprint)**  
  Tests (Unit, Widget, Integration/Manual), Privacy/DSGVO-Anforderungen,
  Observability (Events, Traces, Health), weitere Gates (CI, Greptile Review,
  ADR-Check, Maintenance; CodeRabbit optional lokal als Preflight).

- **5. Stories (Kurzüberblick)**  
  3–5 Stories mit Id/Name + 1-Satz-Business-Ziel.

- **6. Referenzen**  
  Roadmap-Sprint, Use-Cases, Screen-Contracts, Dossiers, ADRs,
  Traycer-Plan, DoD/Checklisten.

> **Regel:** Sprint-BMAD wiederholt keine Details aus den
> SSOT-Dokumenten, sondern verlinkt sie (Roadmap, Screens, Dossiers,
> Checklisten, ADRs). Es dient als „Landing Page“ für Agents, bevor
> sie planen oder implementieren.

---

## 3. Neuen Sprint starten – Ablauf (Checkliste)

Wenn ein neuer Sprint/Feature geplant wird:

1. **Roadmap-Sprint wählen**  
   - Welcher Roadmap-Abschnitt (z. B. S1, S2, …) ist dran?

2. **Sprint-Template kopieren**  
   - `sprint-00-template.md` → `sprint-XX-<slug>.md` kopieren.  
   - Ersten Header anpassen (`# Sprint XX – <Titel>`).

3. **0 & 1 – Meta + Business füllen**  
   - Business-Ziele + Scope aus Roadmap/App-Kontext ableiten.  
   - DSGVO-Impact grob einstufen (Low/Medium/High).  
   - Falls nötig, im Chat/GPT die Business-Sektion aus BMAD Global +
     Roadmap herausdestillieren lassen.

4. **2 & 3 – Modellierung + Architektur füllen**  
   - Relevante Domänen/Tabellen aus BMAD Global Kapitel 2 auswählen.  
   - Flows/Komponenten aus BMAD Global Kapitel 3 und Roadmap/Screen-
     Contracts ableiten.  
   - Invarianten/Risiken benennen (keine `service_role`, RLS, Fallbacks,
     Zeit-/Datums-Handling etc.).

5. **4 – Sprint-DoD definieren**  
   - Aus BMAD Global Kapitel 4 + Checklisten (UI/API/DB/Privacy) die
     Sprint-spezifischen Tests, Privacy-Reviews, Observability-Punkte
     und Gates ableiten.  
   - Z. B. Tests für neue Logik, Privacy-Review für neue Daten, Events
     für neue Flows.

6. **5 & 6 – Stories + Referenzen**  
   - 3–5 Stories als Kurzzeilen eintragen.  
   - Referenzen auf Roadmap, Screens, Dossiers, ADRs, Checklisten,
     Traycer-Plan (TODO-Platzhalter ok).

Ab diesem Zeitpunkt gilt der Sprint-BMAD als **Briefing-Dokument** für
Traycer, Codex und andere Agents.

---

## 4. BMAD im Alltag mit Traycer & Codex nutzen

### 4.1 Traycer (Planer)

- Beim Planen eines Sprints:
  - Sprint-BMAD (insb. 0–4 + 5 Stories) in den Traycer-Prompt einfügen.
  - Traycer bitten, daraus einen Plan in 4–8 Schritten zu bauen:
    - Jeder Schritt soll klar einer Story zuzuordnen sein.
    - Pro Schritt: Domänen/Komponenten + zu verwendende Referenzen
      (Screens, Dossiers, Checklisten) nennen.
    - DoD-Anforderungen aus Abschnitt 4 im Sprint-BMAD berücksichtigen.

- Beim Planen einer einzelnen Story:
  - Story-Zeile aus Abschnitt 5 + relevanten Ausschnitt aus
    Sprint-BMAD + zugehörigen Screen-Contract als Input für Traycer
    verwenden.

### 4.2 Codex (Dev/Auditor)

- Für technische Planung (ohne Code):
  - Codex zuerst `docs/bmad/global.md` + den aktuellen Sprint-BMAD lesen
    lassen.  
  - Dann EINE Story/Task beschreiben und Codex einen technischen Plan
    erstellen lassen (Komponenten, Daten, Tests, Risiken).

- Für Implementation:
  - Codex wieder mit BMAD Global + Sprint-BMAD briefen (als Kontext).  
  - Klar sagen, welche Story/Teilaufgabe umgesetzt werden soll.  
  - DoD/Gates in den Prompt aufnehmen (Tests, Privacy-Review, Events, CI).

> **Regel:** Codex soll niemals „im Leeren“ planen oder coden, sondern
> immer mit BMAD Global + aktuellem Sprint-BMAD als Kontext starten.

---

## 5. Wenn BMAD Global/Sprints aktualisiert werden muss

BMAD Global und Sprint-Dokumente werden **nicht** bei jedem Klein-PR
angepasst. Typische Trigger:

- Neue Domäne/Tabelle → BMAD Global Kapitel 2 kurz ergänzen.
- Neue oder geänderte ADR → BMAD Global Kapitel 3/4 anpassen.
- DoD/Governance ändern sich → BMAD Global Kapitel 4 aktualisieren.
- Ein Sprint ist abgeschlossen → Sprint-BMAD kann Status/Notizen
  zum Abschluss („Done / Lessons Learned“) bekommen.

> **Faustregel:**  
> Erst App-Kontext, Roadmap, Dossiers, ADRs, Checklisten anpassen –  
> danach BMAD Global/Sprints kurz synchronisieren.

---

## 6. Archon-Integration (Kurzüberblick)

BMAD-Dokumente sind ideale Kandidaten für Archon-Dossiers:

- **LUVI / BMAD / Global**  
  - Verlinkt `docs/bmad/global.md` und die wichtigsten SSOT-Dokumente
    (App-Kontext, Roadmap, Dossiers, ADRs, Checklisten).

- **LUVI / BMAD / Sprints / 01-cycle-today**  
  - Verlinkt `docs/bmad/sprints/sprint-01-cycle-today.md` und
    relevante Screen-Docs/Dossiers für diesen Sprint.

- Für jeden neuen Sprint kann ein eigenes BMAD-Dossier angelegt werden,
  das auf das entsprechende Sprint-BMAD verweist.

> Agents, die über Archon laufen, können sich damit zielgerichtet den
> BMAD-Kontext holen: „Gib mir das BMAD-Dossier für diesen Sprint“.
