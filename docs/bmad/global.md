# LUVI — BMAD Global Master Brain

**Version:** 2.1 | **Stand:** Januar 2026

> Dieses Dokument ist die zentrale Klammer über alle bestehenden Dokus.
> Es fasst Business, Modellierung, Architektur und Definition of Done
> kurz zusammen und verweist auf die SSOT-Dokumente im Repo
> (App-Kontext, Roadmap, Dossiers, Tech-Stack, DoD, Checklisten, ADRs).
> Es erfindet nichts Neues, sondern ordnet und verlinkt.

## 0. BMAD bei LUVI — Begriffe

- **Business (B)**
  Warum es LUVI gibt, für wen wir bauen, welche Probleme wir lösen,
  welche Verhaltensänderungen wir anstoßen wollen und anhand welcher
  KPIs wir Erfolg messen (inkl. DSGVO-/Impact-Sicht auf Business-Ebene).

- **Modellierung (M)**
  Wie wir die Domäne strukturieren: zentrale Domänenobjekte (z. B.
  User, Cycle, Phase, Content, Consent, Events, Workout, Progression, Journal),
  zugehörige Tabellen / Views / Heuristiken und die wichtigsten Begriffe & Invarianten
  (inkl. RLS-/Consent-Prinzipien).

- **Architektur (A)**
  Wie die Systeme zusammenspielen: Flutter-App, Supabase, Vercel Edge,
  AI-/Observability-Layer, Flows (FTUE, Zyklus, Training, Coach, Brain, Consent,
  Healthcheck) und die globalen Architektur-Entscheidungen aus den ADRs.

- **Definition of Done (D)**
  Wann etwas „wirklich fertig" ist: globale & rollen-spezifische
  Akzeptanzkriterien (CI, Tests, Privacy/DSGVO-Review, Health-Gates,
  Greptile Review (Required Check), optionale lokale CodeRabbit-Reviews
  als Preflight (kein GitHub-Check, Details: `docs/engineering/ai-reviewer.md`),
  ADR-Pflege, Runbooks), wie sie in DoD-, Checklisten- und
  Governance-Dokumenten definiert sind.

## 0.1 Dokumenten-Hierarchie & Versionierung

- Für jedes Themengebiet (z. B. App-Kontext, Roadmap,
  Phase-Definitionen, Ranking-Heuristik, Safety & Scope) existiert genau
  ein aktives SSOT-Dokument.

- Maßgeblich ist stets die höchste freigegebene Versionsnummer (z. B.
  v3.2 > v3.1); ältere Versionen sind nur Historie.

- Priorität bei Konflikten:
  1. BMAD Global (dieses Dokument)
  2. Thema-spezifische SSOT-Dossiers (z. B. Phase, Consent, Ranking)
  3. Roadmap / Sprint-Dokumente
  4. Notizen oder sonstige Artefakte

- Agents und Entwickler*innen müssen immer gegen das aktuellste SSOT
  arbeiten und Konflikte anhand dieser Reihenfolge auflösen.

- Ausnahme: Für AI-Review/CI-Policy ist
  `docs/engineering/ai-reviewer.md` innerhalb dieses Scopes maßgeblich.

## Wie KI dieses Dokument nutzen soll

- BMAD Global dient als übergeordnete Leitlinie und Index für alle SSOTs.

- KI/Agents nutzen dieses Dokument, um Business-, Modellierungs-,
  Architektur- und DoD-Kontext zu verstehen sowie zu wissen, welche
  Dossiers existieren.

- Bei konkreten Fragen (z. B. Ranking, Phase, Consent, Training Flow) müssen die
  jeweiligen SSOT-Dokumente herangezogen werden; BMAD Global gibt nur den
  Rahmen vor.

- Im Zweifel gilt die oben beschriebene Dokumenten-Hierarchie —
  Konflikte sind entlang dieser Priorität zu lösen.

---

## 1. Business (Global)

### 1.1 Vision

LUVI ist ein **Lifestyle-first Health- und Longevity-Companion für Frauen**.

Die App soll helfen, in der Informationsflut rund um Training,
Ernährung, Zyklus, Biohacking, Regeneration und Beauty den Überblick zu behalten —
mit faktenbasiertem, kuratiertem Content und Programmen, die zu Zyklus,
Alltag und aktuellem Zustand passen.

Anstatt nur Workouts oder Tipps „zum Nachmachen" zu liefern, soll LUVI
Nutzerinnen dabei unterstützen, ihren Körper besser zu verstehen und
langfristig physisch wie mental stabiler, leistungsfähiger und
zufriedener zu werden.

**Kernprinzipien:**

| Prinzip | Bedeutung |
|---------|-----------|
| **Privacy First** | EU-Only, DSGVO-first, keine Gesundheitsdaten in Push-Nachrichten |
| **Lifestyle-first** | Kein Medizinprodukt, keine Diagnosen, keine Heilversprechen |
| **Ultra-Personalisierung** | Zyklus, Ziele, Equipment, Ernährung, Verhalten → individuelle Empfehlungen |
| **Friction Reduction** | 1 Klick zum Training statt 3 Screens |
| **Evidenzbasiert** | Wissenschaftliche Quellen (Stacy Sims) statt Influencer-Hype |

(Quellen: docs/product/app-context.md)

### 1.2 Zielgruppe

**Primärsegment (Beachhead):**

- Frauen ca. **20–50**
- health-conscious: interessiert an Training, Ernährung, Schlaf, Stressmanagement, Longevity
- wenig Zeit und überfordert von Content-Flut im Internet
- mit beruflichem und privatem Alltag (Job, ggf. Familie), die ihre Gesundheit aktiver gestalten wollen
- grundsätzlich bereit, in sich selbst zu investieren (Zeit, ggf. Geld für Programme)

**Motivationen:**
- mehr Energie im Alltag
- Stress & Schlaf in den Griff bekommen
- Körper verändern/halten (Fett, Muskel, Form)
- Zyklus & Hormone besser verstehen
- gesund altern („Future Self" schützen)

**Sekundärsegmente (trotzdem willkommen):**
- **Jüngere Frauen (16–30):** Gym-/„That Girl"-Lifestyle, Body & Skin, Long-Term Health als Thema
- **Ältere Frauen (50+):** Fokus Menopause/Postmenopause, schonende Bewegung, Gehirn- & Knochengesundheit
- **Perspektivisch: Männer** — zunächst v. a. Training, Biohacking, Schlaf, Longevity; Zyklus-/Menstruationsfeatures werden dann ausgeblendet

**Wichtig:** Die App ist technisch von Anfang an offen für alle (Gender-Auswahl im Onboarding).
Der Content-Fokus ist Women-first; Men-/weitere Tracks sind Roadmap-Erweiterung.

(Quellen: app-context, Roadmap, Dossiers)

### 1.3 Zielmärkte & Sprachen

**Sprachen (v1):**
- Deutsch
- Englisch

**Verfügbarkeit:**
- App ist global in den Stores verfügbar.
- UI-/UX-Sprache richtet sich nach Systemsprache bzw. Userwahl.

**Content-Sprache:**
- Mix aus deutsch- und englischsprachigen Inhalten.
- Filteroptionen: z. B. „Nur deutschsprachiger Content" oder „Deutsch + Englisch".

**Go-to-Market-Fokus (v1–v2):**
- primär DACH (Deutschland, Österreich, Schweiz)
- sekundär global englischsprachige Nutzerinnen (Europa, UK, US etc.)

**Später (v3+):**
- zusätzliche Sprachen (z. B. Arabisch)
- regionspezifische Content-Kuration

### 1.4 Hauptprobleme, die LUVI löst

**1. Kein auf den Zyklus abgestimmtes Training im Alltag**

Die meisten Trainingspläne ignorieren Zyklusphasen und Hormonschwankungen.
LUVI bietet Programme, die Energielevel, Regeneration und Zyklusphase
berücksichtigen, ohne in medizinische Diagnostik zu rutschen.

**2. Zuviel widersprüchlicher Health-Content, zu wenig Evidenz**

Social Media und das Web sind voll mit Tipps, Challenges und „Biohacks",
deren Qualität schwer zu beurteilen ist. LUVI setzt auf kuratierten,
evidenznahen Content von Expert:innen und macht transparent, was
Empfehlung vs. gesicherte Evidenz ist.

**3. Kein Ort, an dem ich gleichzeitig handeln und verstehen kann**

Entweder „Apps zum Abarbeiten" (Workouts) oder tiefe Inhalte in YouTube/
Podcasts, die schwer in den Alltag übersetzbar sind. LUVI verbindet
praktische Programme (Training, Regeneration, Ernährung/Biohacking)
mit begleitendem Lern-Content, damit Nutzerinnen verstehen, warum
etwas für sie sinnvoll ist.

**Value-Story:**

- **Free-Bereich:** Daily Mindset Card mit teilbarem Mantra, Smart Hero Card
  mit personalisierter Trainingsempfehlung, LUVI Brain als Content-Bibliothek,
  Zyklus-Tracking, Basis-Training.

- **Premium-Bereich:** LUVI Coach mit Wochenübersicht, Statistiken und
  Progression-Diagrammen, strukturierte Coach-Programme (4–8 Wochen),
  zusätzliche Premium-Workouts zum Kauf, KI-Features (Post-MVP).

- **Privacy:** Klare, transparente Privacy-Entscheidungen (EU-only Gateway, CMP für
  externe Videos, nachvollziehbare Consent-Logs, stateless AI, **keine
  Gesundheitsdaten in Push-Nachrichten**) gehören bewusst zum Produktversprechen
  und sind nicht nur „Compliance".

(Quellen: app-context, use-cases, Dossiers)

### 1.5 Content-Säulen (Pillars)

LUVI denkt Content in **6 zentralen Säulen**, für das MVP in zwei Tiefenstufen:

**Tier 1 (Fokus-Säulen v1):**
- Training & Movement
- Schlaf & Recovery + Mind / Stress (als gekoppelte Säule)
- Ernährung & Biohacking (Basics)

**Tier 2 (Light-Säulen v1, Ausbau ab v2):**
- Beauty, Skin & Bodycare
- Longevity & Future Self

**Zyklus & Hormone (quer über alle Säulen):**
- Trainingsempfehlungen je Phase (Follicular: mehr Intensität; Luteal: mehr Recovery)
- Ernährungshints (Cravings, Blutzucker, Salz, Protein)
- Sleep/Mind-Content bei PMS-Symptomen oder Luteal-Schlafproblemen

**Säulen-Details:**

| Säule | Tier | Inhalt |
|-------|------|--------|
| **Training & Movement** | 1 | Workouts 5–45 Min (Bodyweight, Dumbbells, Yoga, Mobility, Cardio, Walking), abgestuft nach Level & Intensität. **Eigenproduziert durch Gründer (Personal Trainer, 10+ Jahre Erfahrung)** |
| **Ernährung & Biohacking** | 1 | Makros, Mikronährstoffe, Meal-Prep, Snacks, Biohacking (Licht, Mahlzeiten-Timing, Koffein), frauenspezifisch: PMS, Cravings, Menopause-Ernährung |
| **Schlaf & Recovery + Mind** | 1 | Sleep-Hygiene, HRV/Resting HR Basics, Mobility fürs Nervensystem, Atemübungen (1–20 Min), Micro-Meditationen, Stress-/Burnout-Prävention |
| **Beauty & Skin** | 2 | Skin-Care-Basics, Bodycare (Faszien, Haltung, Lymphsystem), realistischer Cellulite-Kontext |
| **Longevity** | 2 | Blutzucker, Entzündungsmarker, Muskelmasse, Knochen, Wearables/Labs einordnen |

### 1.6 Rolle von Zyklus & Hormonen

LUVI ist **Lifestyle-first mit zyklusbewusster Intelligenz** — kein klassischer
Zyklus-Tracker und ausdrücklich **kein Medizinprodukt**.

- Zyklusdaten und hormonelle Muster werden als querliegende Logik genutzt,
  um Training, Ernährung/Biohacking, Regeneration und Mind-Programme besser
  zu timen und Inhalte sinnvoll zu priorisieren.

- Die App gibt lebensstilorientierte, evidenznahe Empfehlungen, bietet
  Programme von Expert:innen und kuratierten Content, aber:
  - stellt keine Diagnosen
  - trifft keine Therapieentscheidungen
  - gibt keine Heilversprechen
  - **macht KEINE Eisprung-Vorhersage**

Alle Aussagen und Features müssen mit den Privacy- und Compliance-Dokumenten
(DSGVO-Impact, Phase-Definitionen, Consent-Texte, SaMD-Abgrenzung) kompatibel sein.

**Im Interface zeigt sich die Zykluslogik durch:**
- Phase-Badges und Daily Mindset Card auf dem Home-Screen
- Phasenabhängige Priorisierung der Trainingsempfehlungen
- Phasenpassende Journal-Reflexionsfragen
- Zyklus Screen mit Kalender und Phasen-Übersicht

(Quellen: docs/phase_definitions.md, docs/consent_texts.md, docs/ranking_heuristic.md)

### 1.7 Globale KPIs (erste Hypothesen)

Die folgenden Kennzahlen sind keine harten Versprechen, sondern
Orientierungspunkte, um zu prüfen, ob LUVI als „Daily Companion" und
Lern-/Handlungsplattform funktioniert:

**North-Star-Kandidaten:**
- **Daily Health Engagement (DHE):** Anteil der Nutzer*innen, die pro Tag mindestens 1 Content-Stück aus 2+ Säulen konsumieren.
- **Program Adherence:** Anteil der Nutzer*innen, die ein Programm mindestens 3 Wochen aktiv verfolgen.

**Engagement-Metriken:**
- Anteil aktiver Nutzerinnen, die den Home-Screen an mehreren Tagen pro Woche öffnen (z. B. 3–5 Tage/Woche)
- CTR Daily Mindset Card
- Share-Rate (Mantra + Brain Content)
- **Streaks:** "X Tage in Folge mit LUVI"

**Aktive Nutzung:**
- Training Completion Rate
- Gewichts-Eingabe-Rate im Workout Screen
- LUVI Coach Page Views (Statistiken, Diagramme)
- Journal Completion Rate

**Monetarisierung:**
- Trial → Paid Conversion
- Abo-Churn (monatlich)
- Workout-Einzelkäufe in LUVI Coach

**Retention:**
- Retention-Rate nach 30 Tagen
- Anzahl „Gespeichert"-Aktionen pro aktive Nutzerin
- "LUVI lernt" Moment Engagement (nach 12 Trainings)

(Quellen: app-context, roadmap, analytics/taxonomy.md)

### 1.8 Wording & Marke

**Begriffe:**
- „zyklusbasiert", „zyklussynchron", „phasenbewusst" — keine geschützten Markennamen

**Tonalität:**
- sachlich-freundlich, empowernd, anti-Bullshit (klar gegen Pseudoscience, aber nicht dogmatisch)
- Privacy & EU-Only als deutlicher Vertrauensvorteil

**Store-Listing:**
- Women-first Health & Longevity Hub
- keine unbelegten Mengen-Claims („die größte", „die einzige" etc. vermeiden)

**Nutzenversprechen:**
> „Öffne LUVI und sieh in 30 Sekunden,
> was heute gut für deinen Körper, deine Energie und dein zukünftiges Ich ist —
> mit Workouts, Health-Tipps & Longevity-Wissen in einer App."

---

## 2. Modellierung (Domain & Daten)

### 2.1 Domänenübersicht

**User & Auth:**
- **User (Supabase Auth)** — Besitzerin aller personenbezogenen Daten und
  Interaktionen, über `user_id` in allen relevanten Tabellen referenziert.

**Consent & Privacy:**
- **Consent** — Speichert Einwilligungen der Nutzerin zu bestimmten
  Scopes/Versionen (z. B. CMP, E-Mail-Preferences).
- **ConsentLog (CMP / Video-Consent)** — Audit-Log einzelner Consent-
  Entscheidungen für externe Videos.
  - **Felder:** `user_id, video_id, decision, timestamp, ua_hash, ip_hash, client_version, locale`
  - **Retention:** 12 Monate
  - Export/Löschung durch Nutzer*in in Einstellungen (DSGVO-konform)

**Zyklus:**
- **CycleData** — Basisdaten für die Zyklusberechnung (letzte Periode,
  Zykluslänge, Periodendauer (Default: 5 Tage, siehe phase_definitions.md SSOT), Alter, user_id).
- **Phase** — Fachliches Modell der Zyklusphasen inklusive Dauer,
  Kriterien und UI-Hinweisen (wird berechnet, nicht gespeichert).
- **Cycle/Phase Computation („TodayState")** — Logik zur Berechnung der
  aktuellen Phase/Tag für Home/Badges (z. B. `compute_cycle_info`).

**Training & Workout:**
- **Workout** — Einzelnes Training mit Video, Dauer, Intensität, Phase-Score.
- **WorkoutSession** — Aktive/abgeschlossene Trainingseinheit einer Nutzerin.
- **WorkoutExercise** — Einzelne Übung innerhalb eines Workouts.
- **ExerciseLog** — Protokoll der eingegebenen Gewichte/Wiederholungen (für Diagramme).
- **TrainingFeedback** — Post-Training-Bewertung (😓 zu hart / 👍 genau richtig / 😊 zu leicht).
- **AbortReason** — Abbruchgrund bei vorzeitigem Beenden + Alternative (z.B. "5 Min Stretching").

**LUVI Coach & Progression:**
- **WeeklyPlan** — Geplante Workouts für die Woche.
- **ProgressionData** — Aggregierte Daten für Diagramme (Gewicht pro Übung über Zeit).
  - Beispiel-Diagramme: Kniebeuge-Gewichtsentwicklung (8 Wochen), Deadlift-Progression, Trainingsintensität
- **PurchasedWorkout** — Zusätzlich gekaufte Premium-Workouts (z.B. "HIIT Extreme" 4,99€).

**Journal & Mindset:**
- **DailyMindset** — KI-generiertes Mantra pro Nutzerin.
  - Frequenz: **1x täglich neu generiert** (nicht on-demand)
  - Inhalt: Phasenpassender Fokus-Satz
  - Zweck: Täglicher Retention-Hook + organische Reichweite durch Share
- **JournalEntry** — Reflexionseintrag mit phasenpassender Frage und Antwort.
  - Beispiel-Fragen:
    - Follikelphase: „Was möchtest du diese Woche starten?"
    - Menstruation: „Was darfst du heute loslassen?"
- **JournalPattern** — Erkannte Muster aus Journal-Einträgen über Zyklen hinweg.

**Energy & Check-In:**
- **EnergySelection** — Gewählte Energie-Option pro Tag.
  - 💪 Power: 85% → High Intensity
  - 😌 Balance: 65% → Medium Intensity
  - 😴 Low Energy: 45% → Gentle Flow
- **QuickCheck** — Nur bei negativer Abweichung (Phase erwartet "High", User wählt "Low" → "Alles okay?")

**Content & Brain:**
- **Content/Video** — Kuratierte Videos/Artikel als zentrale Content-Einheit.
- **Channel** — Quelle/Creator-Kanal eines Videos.
- **VideoPhase** — Zuordnung/Score, wie gut ein Video zu einzelnen Zyklusphasen passt.
- **VideoTag** — Schlagworte/Tags pro Video.
- **ContentVideoHealth** — Status/Health eines Videos (z. B. embeddable, gelöscht, privat).
- **SavedContent** — Von Nutzerin gespeicherte Inhalte (Lesezeichen).
- **ContentProduction** — KI-gestützt + manuelle Research, Notion für Slides, Quellenangaben obligatorisch.

**Nutrition Guards:**
- **NutritionRecommendation** — Post-Workout Empfehlung basierend auf Training-Typ + Ernährungspräferenz.

| Training-Typ | Ernährungspräferenz | Empfehlung |
|--------------|---------------------|------------|
| Kraft/Cardio/HIIT | Omnivor | Quark, Hüttenkäse, Shake |
| Kraft/Cardio/HIIT | Vegetarisch | Quark, Hüttenkäse, Shake |
| Kraft/Cardio/HIIT | Vegan | Veganer Shake, Edamame, Nüsse |
| Sleep/Relax/Meditation | Alle | Tee, Wasser, Goldene Milch |

**Events & Analytics:**
- **UserEvent** — Tracking von Video-/Training-Interaktionen in der App.
- **AnalyticsEvent (Taxonomy)** — Abstraktes Schema für App-weite Events (ohne PII).
- **RankingScore** — Berechneter Score zur Priorisierung von Videos/Workouts.

**Programme:**
- **Program/CoachProgram** — Premium-Trainingspläne (z. B. 4–8-Wochen-Programme wie "Cycle-Smart Strength", phasenbewusst).

**Wearables (Post-MVP):**
- **WearableData** — Importierte Daten (Schlaf, HRV, Schritte) von externen Geräten.

**"LUVI lernt" Moment:**
- Trigger: Nach 12 geloggten Trainings
- Anzeige: **Einmalig** (danach nie wieder)
- Inhalt: Muster-Zusammenfassung (Trainingszeit-Präferenz, Phasen-Energie, Lieblings-Dauer, Nutrition-Präferenzen)

*(Quellen: docs/phase_definitions.md, docs/consent_texts.md,
docs/ranking_heuristic.md, docs/analytics/taxonomy.md, docs/product/roadmap.md,
docs/audits/SUPABASE_SCHEMA_public.ts)*

### 2.2 Domäne → Tabellen/Views → Status

> **Last verified:** 2026-01-25 (update this timestamp when making schema changes)

| Domäne | Supabase-Tabellen/Views | Status | Migration/Ticket | Quellen |
|--------|-------------------------|--------|------------------|---------|
| User | `auth.users`, `user_id`-Felder in anderen Tabellen | Ist | Supabase managed | Schema-Audit, Roadmap |
| Consent | `public.consents` | Ist | `20250903235538` | Schema-Audit, Roadmap, docs/consent_texts.md |
| ConsentLog | `public.consent_logs` | Geplant | TBD (Roadmap S2) | Roadmap (S2), docs/consent_texts.md |
| CycleData | `public.cycle_data` | Ist | `20250903235539` | Schema-Audit, Roadmap (S0/S1) |
| Phase | -- (berechnet, keine eigene Tabelle) | Logik-only | N/A | docs/phase_definitions.md |
| Cycle/Phase Computation | -- (Funktionen/Services) | Logik-only | N/A | Roadmap (S1) |
| DailyPlan | `public.daily_plan` | Ist | Pre-existing | Schema-Audit |
| **Workout** | `public.workout` | **Geplant** | TBD (Roadmap S3) | Roadmap (MVP) |
| **WorkoutSession** | `public.workout_session` | **Geplant** | TBD (Roadmap S3) | Roadmap (MVP) |
| **ExerciseLog** | `public.exercise_log` | **Geplant** | TBD (Roadmap S3) | Roadmap (MVP) |
| **TrainingFeedback** | `public.training_feedback` | **Geplant** | TBD (Roadmap S3) | Roadmap (MVP) |
| **WeeklyPlan** | `public.weekly_plan` | **Geplant** | TBD (Roadmap S4) | Roadmap (MVP) |
| **ProgressionData** | -- (berechnete View) | **Logik-only** | N/A | Roadmap (MVP) |
| **JournalEntry** | `public.journal_entry` | **Geplant** | TBD (Roadmap S6) | Roadmap (MVP) |
| **DailyMindset** | `public.daily_mindset` | **Geplant** | TBD (Roadmap S6) | Roadmap (MVP) |
| **EnergySelection** | `public.energy_selection` | **Geplant** | TBD (Roadmap S2) | Roadmap (MVP) |
| Content/Video | `public.video` | Geplant | TBD (Roadmap S2) | Roadmap (S2 DB/Schema) |
| Channel | `public.channel` | Geplant | TBD (Roadmap S2) | Roadmap (S2 DB/Schema) |
| VideoPhase | `public.video_phase` | Geplant | TBD (Roadmap S2) | Roadmap (S2 DB/Schema) |
| VideoTag | `public.video_tags` | Geplant | TBD (Roadmap S2) | Roadmap (S2 DB/Schema) |
| ContentVideoHealth | `public.content_video_health` | Geplant | TBD (Roadmap S2.5) | Roadmap (S2.5 Tech) |
| SavedContent | `public.saved_content` | **Geplant** | TBD (Roadmap S5) | Roadmap (MVP) |
| UserEvent | `public.user_event` | Geplant | TBD (Roadmap S2) | Roadmap (S2 DB/Schema) |
| AnalyticsEvent | Event-Stream (PostHog-Schema) | Logik-only | N/A | analytics/taxonomy |
| RankingScore | -- (berechnete View/Funktion) | Logik-only | N/A | ranking_heuristic |
| Program/CoachProgram | -- (Domäne definiert) | Geplant | TBD (Roadmap S5) | Roadmap (S5) |
| **PurchasedWorkout** | `public.purchased_workout` | **Geplant** | TBD (Roadmap S6) | Roadmap (MVP) |
| Consent Copy (CMP) | -- (Copy/Config) | Copy/Config | N/A | consent_texts |
| **WearableData** | `public.wearable_data` | **Post-MVP** | TBD (Post-MVP) | Roadmap |

> **Convention:** Migration/Ticket column uses migration timestamp for existing tables (e.g., `20250903235538`),
> "TBD (Roadmap SX)" for planned tables referencing the sprint, or "N/A" for computed views/logic-only.
> Update "Last verified" timestamp above when making schema changes.

### 2.3 Wichtige Beziehungen & Invarianten

**User-zentrische Beziehungen:**
- User → CycleData (1:1) — Eine Nutzerin hat genau einen Zyklusdatensatz
- User → WorkoutSession (1:n) — Eine Nutzerin kann viele Trainingseinheiten haben
- User → JournalEntry (1:n) — Eine Nutzerin kann viele Journal-Einträge haben
- User → DailyMindset (1:1 pro Tag) — Eine Nutzerin hat pro Tag ein Mindset
- User → EnergySelection (1:1 pro Tag) — Eine Nutzerin wählt pro Tag eine Energie

**Training-Invarianten:**
- WorkoutSession.is_active kann nur für eine Session pro User true sein
- ExerciseLog gehört immer zu einer WorkoutSession
- TrainingFeedback wird erst nach Session-Ende erstellt

**State Machine (Smart Hero Card):**

| State | Trigger | Visuelle Änderung |
|-------|---------|-------------------|
| Default | App-Start, kein Scheduled | Normale Hero Card |
| Scheduled | User wählt „Später" | Dezente Karte „Geplant für X" |
| Overdue | CurrentTime > ScheduledTime | Akzent-Farbe, „Dein Training wartet" |
| Resume | is_session_active == true | Blockierendes Overlay „Fortsetzen?" |
| Reset | 04:00 Uhr | Alle States → Default |

### 2.4 RLS-/Policy-Grundsätze (Übersicht)

- Alle personenbezogenen Tabellen: RLS ON, owner-based (`user_id = auth.uid()`)
- `service_role` ausschließlich serverseitig (Edge Functions)
- Kein Client-Zugriff auf fremde Daten
- Consent-Logs: Append-only für User, Read für Audit
- ExerciseLog/TrainingFeedback: Owner-only CRUD

---

## 3. Architektur (System & Flows)

### 3.1 System-Bausteine

- **Flutter-App (iOS-first, Riverpod + GoRouter)**
  Haupt-Client mit Feature-Mirror-Struktur (`lib/features/**`), zentralem
  Core (`lib/core/**`) und einem separaten Services-Package (`services/luvi_services`).
  Die App rendert die fünf MVP-Hauptbereiche (Home, Zyklus, LUVI Coach,
  LUVI Brain, Profil) und konsumiert alle Backends ausschließlich
  über klar definierte Services.

- **Supabase (Postgres EU/Frankfurt)**
  Primäre Daten- und Auth-Schicht mit RLS owner-based auf allen
  personenbezogenen Tabellen (z. B. cycle_data, daily_plan, consents,
  workout_session, exercise_log, journal_entry).
  Enthält Auth, Storage, pgvector für spätere KI-Suche und Consent-/Event-
  Logging. `service_role` wird nur serverseitig (Edge Functions) genutzt.

- **Vercel Edge Gateway (fra1)**
  Einziger API-Einstiegspunkt für die App unter `/api/*`. Kümmert sich um
  JWT-Validierung, CORS, Rate-Limiting, PII-Redaction und stellt den
  Health-Endpunkt `/api/health` bereit, der als Merge-Gate in CI/CD
  fungiert (Preview-Health muss 200 sein).

- **AI- & Observability-Layer**
  AI-Funktionen laufen über das Vercel AI SDK (Router über EU-fähige
  Provider wie OpenAI/Bedrock/Vertex), mit Redis (Upstash) als Cache für
  Antworten. Langfuse ist Pflicht-Layer für Tracing, Kosten- und
  Latenzmonitoring aller AI-Aufrufe.

- **Analytics, Push & Crash-Reporting**
  PostHog (EU) erfasst Events und Funnels/Retention; Sentry überwacht
  Crashes und Performance; OneSignal (mit passenden DPA/SCCs) dient
  für Push-Notifications (**ohne Gesundheitsdaten im Payload**); Newsletter/Comms laufen über Brevo mit
  Double-Opt-in und Consent-Verknüpfung.

- **CI/CD & QA-Infrastruktur**
  GitHub Actions orchestrieren `flutter analyze`/`flutter test`, Privacy-
  Gate, Preview-Health-Checks und weitere Pipelines. Greptile Review ist
  als Required Check vorgeschaltet; CodeRabbit wird nur noch lokal als
  optionaler Preflight genutzt (kein GitHub-Check; Policy siehe
  `docs/engineering/ai-reviewer.md`).
  Archon als zentraler MCP/SSOT für Agentenwissen.

- **Supabase MCP (dev-only, read-only)**
  Ermöglicht Agenten (z. B. Codex) kontrollierten, lesenden Zugriff auf
  Schema/Definitionen, ohne Risiko für produktive Daten. Unterstützt das
  RAG-first-Prinzip aus den ADRs.

- **Offline Resume / Lokale Verschlüsselung**
  Für bestimmte Features (z. B. Crash Protection bei laufendem Workout) wird eine lokale
  verschlüsselte Datenbank (SQLCipher) genutzt, deren Schlüssel in
  Secure Storage liegen. `is_session_active` Flag für Resume-Handling.

*(Quellen: context/refs/tech_stack_current.yaml, repo-structure.md,
flutter-structure.md, platform/healthcheck.md, offline_resume_key_management.md)*

### 3.2 Bottom-Navigation (MVP)

```
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│  HOME   │  │ ZYKLUS  │  │  COACH  │  │  BRAIN  │  │ PROFIL  │
│    🏠   │  │    🩸   │  │    🏋️   │  │    🧠   │  │    👤   │
└─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘
```

**Post-MVP:** + LUVI Stream (📺)

### 3.3 Kern-Flows (High-Level)

- **FTUE/Onboarding + Consent**
  Beim ersten Start durchlaufen Nutzerinnen den Onboarding-Flow mit
  Consent-Dialogen (inkl. externem Content) und Präferenzabfrage.

  **Erfasste Daten:**
  1. Name (personalisierte Ansprache)
  2. Geburtsdatum (Altersgruppe)
  3. Ziele (Training, Ernährung, Schlaf, etc.)
  4. Equipment (Bodyweight, Dumbbells, etc.)
  5. Ernährungspräferenz (Omnivor, Vegetarisch, Vegan)
  6. Zyklusdaten (letzte Periode, Zykluslänge)

  Die App schreibt Consent- und Onboarding-Daten nach Supabase (RLS-geschützt)
  und erzeugt entsprechende Analytics-Events.

- **Home Screen (Daily Mindset + Smart Hero Card)**
  Home zeigt oben die **Daily Mindset Card** (KI-generiertes Mantra, **1x täglich neu generiert**, phasenpassend, Share-Buttons: Instagram Story, WhatsApp Status, Facebook Story, X, Journal-Button). Darunter die **Smart Hero Card** mit personalisierter Trainingsempfehlung.
  "Warum für dich?" (aufklappbar: Ziel, Equipment, Zeit, Phase, Wissenschaft).
  CTAs: [▶ STARTEN] [⏰ Später] [⚙️ Anpassen].
  **Energy Menu** bei "Anpassen" ermöglicht 3 Optionen (Power 85%/Balance 65%/Low Energy 45%).
  **Quick Check** nur bei negativer Abweichung (z.B. Follikelphase erwartet "High", User wählt "Low" → "Alles okay?").
  State Machine verwaltet Default/Scheduled/Overdue/Resume States.
  **Midnight Reset:** 04:00 Uhr (Spättrainierer-freundlich).

- **Zyklus Screen**
  Nutzerinnen sehen ihren Zyklus im Kalender mit Phasen-Markierungen (farbcodiert).
  Aktuelle Phase prominent angezeigt ("Tag 22 · Lutealphase").
  Symptom-Tracking ist optional.
  **KEIN Eisprung-Tracking** (kein Medizinprodukt!). Vorhersage nur für nächste Periode.
  Daten fließen in Home Screen (Hero Card, Daily Mindset).

- **LUVI Coach Screen**
  Training-Zentrale mit Wochenübersicht (geplante Workouts), aktuellem
  Tages-Workout (= Hero Card Inhalt), Statistiken und Progression-Diagrammen
  (z.B. Kniebeuge-Gewichtsentwicklung über 8 Wochen, Deadlift-Progression,
  Trainingsintensität). Zusätzliche Premium-Workouts können gekauft werden.
  Post-MVP: Wearable-Daten (Schlaf, HRV, Schritte).

- **Workout Screen (nicht in Bottom Nav)**
  Aktives Training mit Video (eigenproduziert), Timer, **Gewichts-/Leistungs-Eingabe** (für
  Diagramme in LUVI Coach). Steuerung: Play, Pause, Überspringen.
  Crash Protection via `is_session_active` Flag.
  Nach Training: Feedback ("Wie war's?" → 😓/👍/😊), Post-Workout Card mit Nutrition Guards.
  Bei Abbruch: Grund-Auswahl + Alternative anbieten (z.B. "5 Min Stretching").
  Nach 12 Trainings: "LUVI lernt" Moment (einmalig).

- **LUVI Brain Screen**
  Content-Bibliothek mit Insta-like Scroll-Feed. Filter nach Kategorien,
  **intelligente Keyword-Suche mit Priorisierung** (letztes Keyword = höchste
  Priorität, z.B. "Training Schwangerschaft" → 1. Schwangerschaft, 2. beide, 3. Training).
  Lesezeichen-Funktion, **Share-Funktion** (Instagram, WhatsApp, Facebook, X).
  Alle Artikel mit Quellenangaben (Stacy Sims, Studien).
  Content-Produktion: KI-gestützt + manuelle Research, Notion für Slides.

- **Smart Cycle Journaling**
  Aus Daily Mindset Card (✍️ Button) erreichbar. KI generiert phasenpassende
  Reflexionsfrage:
  - Follikelphase: „Was möchtest du diese Woche starten?"
  - Menstruation: „Was darfst du heute loslassen?"

  Muster-Erkennung über Zyklen hinweg ("Du fühlst dich in Phase X oft erschöpft",
  "In den letzten 3 Zyklen hattest du am Tag 22 ähnliche Gedanken").
  Content-Trigger basierend auf Journal-Einträgen (User schreibt über Schlafprobleme →
  am nächsten Tag: "Schlaf in der Lutealphase").

- **Push-Strategie: Content First**
  Push-Notifications als **Content-Hook** (Blog-Artikel Teaser), **KEINE
  Gesundheitsdaten im Payload** (Privacy First!).

  Beispiel: „💡 5 Lebensmittel für mehr Energie in deiner Phase" → Tippe um mehr zu erfahren →

  **Content Overlay** nach Push-Klick zeigt Artikel mit Bridge zum Training:
  "Passend dazu: Dein heutiges Training wartet." [Zum Training] [Später]

  Später-Reminder für geplante Trainings.

- **Coach Trial → Paid (geplant)**
  Im Coach-Tab sehen Nutzerinnen Teaser und Previews von phasenbewussten
  4–8-Wochen-Programmen (z.B. "Cycle-Smart Strength"). Ein Paywall-/RevenueCat-Flow wird über Supabase-Entitlements
  und Auth gesteuert. Zusätzlich: Workout-Einzelkäufe in LUVI Coach.

- **Healthcheck & Operations**
  Der Endpunkt `/api/health` am Vercel Edge liefert Statusinformationen
  über kritische Abhängigkeiten (Supabase, Redis, AI-Provider, etc.).
  CI/CD ruft den Health-Check in Preview/Prod auf; Runbooks definieren
  Hysterese, Statusübergänge und Incident-Response.

*(Quellen: tech-stack, flutter-structure, roadmap, healthcheck,
security/offline_resume_key_management)*

### 3.4 Tech-Stack-Summary

- **Frontend:** Flutter 3.38.x (CI pinned; SDK >=3.38.0 <4.0.0) / Dart >=3.10.0 <4.0.0, Riverpod 3, GoRouter, Feature-
  Mirror-Struktur für lib/features/**, Tests spiegeln Features.

- **Backend/DB:** Supabase Postgres (EU/Frankfurt) mit RLS owner-based,
  Auth, Storage und pgvector; geplante Edge Functions für spezifische
  Server-Logik.

- **Edge/API:** Vercel Edge (Region `fra1`) als einziges Gateway mit JWT,
  CORS, Rate-Limit, PII-Redaction und `/api/health` als Soft-Gate.

- **AI:** Vercel AI SDK als Router über EU-kompatible Modelle, Redis
  (z. B. Upstash) als Cache, Langfuse als verpflichtende Observability-
  Schicht für AI-Aufrufe.

- **Observability & Analytics:** PostHog (EU) für Events/Funnels,
  Sentry für Crash/Performance, Vercel Monitoring, OneSignal für Push
  (mit DPA/SCC-konformem Einsatz, **ohne Gesundheitsdaten im Payload**), Brevo für Newsletter/Comms mit DOI.

- **CI/CD & QA:** GitHub Actions für Analyze/Test/Privacy-Gate/Preview-
  Health, Greptile Review als Required Check (GitHub App), optionale
  lokale CodeRabbit-Reviews vor dem PR,
  Archon MCP als Wissens-SSOT; Runbooks und Checklisten sichern manuelle
  Prove-Schritte.

- **Security & Compliance:** EU-only Regionen, strikte RLS/Least-
  Privilege, Consent-Logging (12 Monate Retention), PII-Redaction an der Edge, Offline-
  Verschlüsselung mit Secure Storage Keys, keine `service_role` im
  Client; AI-Integrationen sind stateless und durch Privacy-Gates
  abgesichert; **keine Gesundheitsdaten in Push-Payloads**.

### 3.5 Architektur-Guards (ADRs)

- **ADR-0001 — RAG-First Wissenshierarchie**
  Wissen aus RAG/Docs (App-Kontext, Dossiers, Schema, ADRs) hat Vorrang
  vor spekulativen LLM-Antworten. Neue Features sollen sich zuerst an
  bestehenden Architektur- und Domänen-Dokumenten orientieren.

- **ADR-0002 — Least-Privilege & RLS (Supabase)**
  Alle Tabellen mit personenbezogenen Daten laufen mit RLS ON und
  owner-based Policies. `service_role`-Zugriff ist ausschließlich
  serverseitig (Edge Functions) erlaubt. Client-Code darf niemals
  `service_role` nutzen.

- **ADR-0003 — Dev-Taktik „Make-It-Work-First" (MIWF)**
  Features werden zuerst als Happy Path mit passenden Tests umgesetzt.
  Zusätzliche Guards/Härtungen folgen auf Basis echter Signale (Sentry/
  PostHog, Privacy-Reviews), um Iteration und Fokus nicht zu blockieren.

- **ADR-0004 — Vercel Edge Gateway (EU/fra1)**
  Das Vercel Edge Gateway in `fra1` ist der einzige HTTP-Einstieg für
  die App, inklusive `/api/health` als operativem Proof-of-Life. JWT/
  CORS, Rate-Limits und PII-Redaction sind Pflicht; alle externen
  Integrationen laufen durch dieses Gateway.

- **ADR-0005 — Push-Privacy (NEU)**
  Push-Notifications dürfen KEINE Gesundheitsdaten (Zyklusphase, Symptome,
  etc.) im Payload enthalten. Content-First-Strategie: Neutraler Content-Hook
  statt Training-CTA mit Phaseninfo.

- **ADR-0006 — Offline Resume Sync**
  Definiert das Verhalten bei Workout-Abbrüchen und App-Crashes.
  Lokale verschlüsselte Speicherung (SQLCipher) mit `is_session_active` Flag.

- **ADR-0007 — Onboarding Success Spacing Alignment**
  Standardisiert Spacing auf 24px (8px Grid) statt Figma's 28px.
  Betrifft Onboarding-Success-Screen und Trophy-Positionierung.

- **ADR-0008 — Splash Gate Orchestration**
  Definiert die State-Machine für Splash → Welcome → Auth → Consent → Onboarding → Home.
  Kritisch für FTUE-Flow und Returning-User-Handling.

Diese Guards bilden das architektonische Geländer für neue Features:
Sie stellen sicher, dass Implementierungen doc-getrieben, least-
privilege, Edge-zentriert, iterativ (MIWF) und privacy-bewusst
erfolgen.

---

## 4. Definition of Done (DoD & Quality Gates)

### 4.1 Globales DoD

Für LUVI gilt ein globales Definition-of-Done, das in
`docs/definition-of-done.md`, `context/agents/_acceptance_v1.1.md`
sowie im Gold-Standard-Workflow beschrieben ist:

- **Code-Qualität & Tests**
  - `flutter analyze` und `flutter test` laufen grün (inkl. Unit- und
    Widget-Tests, passend zur Story).
  - Relevante Services-/Backend-Tests (Dart/Node) sind vorhanden und sinnvoll.
  - Kein „Make-It-Work" ohne anschließendes Prove (Tests, Fixes).

- **Governance & Doku**
  - Betroffene ADRs werden geprüft und bei Bedarf aktualisiert.
  - BMAD und ggf. Sprint-BMAD-Doku sind konsistent zur Implementierung.
  - Wichtige Entscheidungen werden in passenden Dossiers/Docs verlinkt.

- **Reviews & Gates**
  - Greptile Review ist grün (GitHub Required Check).
  - Optionale lokale CodeRabbit-Reviews vor dem PR sind abgearbeitet
    (nur lokaler Preflight, kein CI-Gate), falls verwendet.
  - CI-Pipeline (GitHub Actions) ist grün (analyze/test/privacy-gate).
  - Preview-/Prod-Health-Checks (/api/health) entsprechen den
    Healthcheck-Spezifikationen.

- **Agenten & Ablauf**
  - **Gemini** agiert als Architekt, der komplexe Features plant und in
    Aufgaben für die Spezialisten-Agenten zerlegt.
  - **Claude Code** setzt primär UI/Dataviz-Stories um (DoD: ui-frontend/dataviz).
  - **Codex** setzt primär Backend/DB/Privacy-Stories um (DoD: api-backend/db-admin/qa-dsgvo).
  - Für UI/Dataviz-PRs ist ein Codex-Review Pflicht (zusätzlich zu CI + Greptile).
  - Alle Agenten folgen BMAD → PRP und nutzen dieses Dokument als BMAD Global.

*(Quellen: docs/definition-of-done.md, context/agents/_acceptance_v1.1.md,
docs/engineering/field-guides/gold-standard-workflow.md)*

### 4.2 Rollen-spezifische DoD-Erweiterungen

Zusätzlich zum globalen DoD gelten rollen-spezifische Kriterien, die in
`_acceptance_v1.1.md` und den Checklisten unter `docs/engineering/checklists/`
beschrieben sind:

- **UI/Frontend (ui-frontend)**
  - Mindestens 1 Unit-Test + 1 Widget-Test pro relevanter UI-Story.
  - Navigation/State/A11y entsprechen den Guidelines (GoRouter, Keys, Localisation).
  - UI-Checkliste (`checklists/ui.md`) ist für die Story durchgegangen
    (Theming, A11y, Performance, Fehlerzustände).

- **API/Backend (api-backend)**
  - Edge-/API-Endpunkte respektieren ADR-0004 (Vercel Edge Gateway):
    JWT, CORS, Rate-Limits, Redaction.
  - Contract-/Integrationstests für kritische Pfade vorhanden.
  - API-Checkliste (`checklists/api.md`) wurde angewendet.

- **DB/Admin (db-admin)**
  - Migrationen und RLS-Policies sind konsistent zu ADR-0002
    (Least-Privilege & RLS ON).
  - Keine `service_role` im Client; RLS-Probes/Tests durchgeführt.
  - DB-Checkliste (`checklists/db.md`) ist abgearbeitet.

- **Privacy/DSGVO (qa-dsgvo)**
  - Für datenrelevante Änderungen existiert ein Privacy-Review unter
    `docs/privacy/reviews/*.md`.
  - DSGVO-Checklist (`docs/compliance/dsgvo_checklist.md`) ist
    durchgegangen und dokumentiert.
  - Consent-/Retention-/Logging-Aspekte sind mit Consent Map/TTL-Policies abgestimmt.
  - **Push-Payloads enthalten keine Gesundheitsdaten (ADR-0005).**

- **DataViz (dataviz)**
  - Charts/Dashboards folgen A11y- und Analytics-Guidelines.
  - Events passen zur Analytics-Taxonomy (`docs/analytics/taxonomy.md`).
  - DataViz-Checkliste (`checklists/dataviz.md`) ist geprüft.
  - **Progression-Diagramme in LUVI Coach sind performant und korrekt aggregiert.**

*(Quellen: context/agents/_acceptance_v1.1.md,
docs/engineering/checklists/ui.md, api.md, db.md, privacy.md, dataviz.md)*

### 4.3 Required Checks & Gates (CI, Health, AI, Privacy)

Einige Checks sind als „harte Gates" definiert und müssen für jede
relevante Änderung erfüllt sein:

- **CI & Code-Review**
  - GitHub Actions: Analyze/Test, Privacy-Gate, Preview-Deploy.
  - Greptile Review: Pflicht-Review vor Merge (Required Check).
  - CodeRabbit: optionales lokales Preflight-Review vor dem PR
    (CLI/IDE), kein GitHub Required Check mehr und kein
    Branch-Protection-Gate (Details: `docs/engineering/ai-reviewer.md`).

- **Health & Observability**
  - `/api/health` muss in Preview/Prod den Statusanforderungen aus
    `docs/platform/healthcheck.md` genügen.
  - Sentry/Crash-Rate und Performance-Budgets werden überwacht; bei
    kritischen Regressions kein „einfach weiter so".

- **Privacy & DSGVO**
  - Privacy-Gate in CI bei relevanten Änderungen.
  - Privacy-Reviews und DSGVO-Checklist sind umgesetzt, bevor Features live gehen.
  - Consent-Flows (z. B. CMP für externe Videos) müssen produktiv
    funktional und juristisch abgesegnet sein.
  - **Push-Payloads werden auf Gesundheitsdaten geprüft (ADR-0005).**

- **AI-spezifische Gates**
  - AI-Integrationen laufen über das Vercel AI SDK + Langfuse; jede
    neue AI-Funktion benötigt mindestens einen Langfuse-Trace als Referenz.
  - Supabase MCP/Archon werden genutzt, um Schema/Docs vor einem
    AI-basierten Eingriff zu prüfen (RAG-first, kein „blindes" Schema-Raten).

*(Quellen: Gold-Standard-Workflow, healthcheck.md, analytics/taxonomy.md,
Langfuse-/MCP-Dokus)*

### 4.4 Operative Runbooks & Prove

Neben den automatischen Gates existieren Runbooks und Checklisten, die
das „Prove" im BMAD/PRP-Prozess unterstützen:

- **Incident Response & Datenschutzvorfälle**
  Runbook `docs/runbooks/incident-response.md` beschreibt Rollen,
  Ablauf und Nachweise im Falle von DSGVO-relevanten Incidents.

- **Health & Edge-Tests**
  `docs/runbooks/vercel-health-check.md` beschreibt, wie `/api/health`
  in Preview/Prod getestet und interpretiert wird.
  Weitere Runbooks für Edge-Function-Tests, RLS-Debugging,
  Analytics-Backfill und Consent-Flow-Verification unterstützen
  die Prove-Phase.

- **Memory & Wartung**
  `docs/engineering/maintenance-log.md` und weitere Maintenance-
  Dokus halten fest, wann CI-/Action-Pins, Security-Aspekte und
  Infrastruktur überprüft wurden.

BMAD Global verweist hier bewusst auf die Runbooks, statt sie zu
duplizieren: jede Prove-Phase in einem Sprint/Feature kann sich auf die
jeweils relevanten Runbooks und Checklisten stützen.

*(Quellen: docs/runbooks/*.md, docs/engineering/maintenance-log.md,
docs/privacy/reviews/*.md)*

---

## 5. Quellen & Referenzen

**SSOT-Dokumente:**

| Dokument | Pfad | Beschreibung |
|----------|------|--------------|
| App-Kontext | `docs/product/app-context.md` | Produktvision, Features, Screens |
| Phase-Definitionen | `docs/phase_definitions.md` | Zyklusphase-Logik |
| Consent-Texte | `docs/consent_texts.md` | CMP-/Consent-Copy |
| Ranking-Heuristik | `docs/ranking_heuristic.md` | Feed-/Content-Priorisierung |
| Analytics-Taxonomy | `docs/analytics/taxonomy.md` | Event-Schema |
| Tech-Stack | `context/refs/tech_stack_current.yaml` | Tech-Stack SSOT (YAML) |
| Definition of Done | `docs/definition-of-done.md` | Globale DoD |
| Healthcheck | `docs/platform/healthcheck.md` | /api/health Spezifikation |
| AI-Reviewer | `docs/engineering/ai-reviewer.md` | Greptile/CodeRabbit Policy |
| Roadmap | `docs/product/roadmap.md` | Feature-Planung |

**ADRs:**
- ADR-0001: RAG-First Wissenshierarchie
- ADR-0002: Least-Privilege & RLS (Supabase)
- ADR-0003: Dev-Taktik „Make-It-Work-First" (MIWF)
- ADR-0004: Vercel Edge Gateway (EU/fra1)
- ADR-0005: Push-Privacy
- ADR-0006: Offline Resume Sync
- ADR-0007: Onboarding Success Spacing Alignment
- ADR-0008: Splash Gate Orchestration
