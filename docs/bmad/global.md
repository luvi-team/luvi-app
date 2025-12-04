# LUVI – BMAD Global Master Brain

> Dieses Dokument ist die zentrale Klammer über alle bestehenden Dokus.
> Es fasst Business, Modellierung, Architektur und Definition of Done
> kurz zusammen und verweist auf die SSOT-Dokumente im Repo
> (App-Kontext, Roadmap, Dossiers, Tech-Stack, DoD, Checklisten, ADRs).
> Es erfindet nichts Neues, sondern ordnet und verlinkt.

## 0. BMAD bei LUVI – Begriffe

- **Business (B)**  
  Warum es LUVI gibt, für wen wir bauen, welche Probleme wir lösen,
  welche Verhaltensänderungen wir anstoßen wollen und anhand welcher
  KPIs wir Erfolg messen (inkl. DSGVO-/Impact-Sicht auf Business-Ebene).

- **Modellierung (M)**  
  Wie wir die Domäne strukturieren: zentrale Domänenobjekte (z. B.
  User, Cycle, Phase, Content, Consent, Events), zugehörige Tabellen
  / Views / Heuristiken und die wichtigsten Begriffe & Invarianten
  (inkl. RLS-/Consent-Prinzipien).

- **Architektur (A)**  
  Wie die Systeme zusammenspielen: Flutter-App, Supabase, Vercel Edge,
  AI-/Observability-Layer, Flows (FTUE, Zyklus, Stream, Consent,
  Healthcheck) und die globalen Architektur-Entscheidungen aus den ADRs.

- **Definition of Done (D)**  
  Wann etwas „wirklich fertig“ ist: globale & rollen-spezifische
  Akzeptanzkriterien (CI, Tests, Privacy/DSGVO-Review, Health-Gates,
  Greptile Review (Required Check), optionale lokale CodeRabbit-Reviews als Preflight (kein GitHub-Check, Details: `docs/engineering/ai-reviewer.md`),
  ADR-Pflege, Runbooks), wie sie in DoD-, Checklisten- und
  Governance-Dokumenten definiert sind.

## 6. Dokumenten-Hierarchie & Versionierung

- Für jedes Themengebiet (z. B. App-Kontext, Roadmap, Phase-Definitionen, Ranking-Heuristik, Safety & Scope) existiert genau ein aktives SSOT-Dokument.  
- Maßgeblich ist stets die höchste freigegebene Versionsnummer (z. B. v3.2 > v3.1); ältere Versionen sind nur Historie.  
- Priorität bei Konflikten:  
  1. BMAD Global (dieses Dokument)  
  2. Thema-spezifische SSOT-Dossiers (z. B. Phase, Consent, Ranking)  
  3. Roadmap / Sprint-Dokumente  
  4. Notizen oder sonstige Artefakte  
- Agents und Entwickler*innen müssen immer gegen das aktuellste SSOT arbeiten und Konflikte anhand dieser Reihenfolge auflösen.

## Wie KI dieses Dokument nutzen soll

- BMAD Global dient als übergeordnete Leitlinie und Index für alle SSOTs.  
- KI/Agents nutzen dieses Dokument, um Business-, Modellierungs-, Architektur- und DoD-Kontext zu verstehen sowie zu wissen, welche Dossiers existieren.  
- Bei konkreten Fragen (z. B. Ranking, Phase, Consent) müssen die jeweiligen SSOT-Dokumente herangezogen werden; BMAD Global gibt nur den Rahmen vor.  
- Im Zweifel gilt die oben beschriebene Dokumenten-Hierarchie – Konflikte sind entlang dieser Priorität zu lösen.

---

## 1. Business (Global)

1. Business (Global)

1.1 Vision

LUVI ist ein Lifestyle-first Health- und Longevity-Companion für Frauen.
Die App soll helfen, in der Informationsflut rund um Training, Ernährung,
Zyklus, Biohacking, Regeneration und Beauty den Überblick zu behalten –
mit faktenbasiertem, kuratiertem Content und Programmen, die zu Zyklus,
Alltag und aktuellem Zustand passen.

Anstatt nur Workouts oder Tipps „zum Nachmachen“ zu liefern, soll LUVI
Nutzerinnen dabei unterstützen, ihren Körper besser zu verstehen und
langfristig physisch wie mental stabiler, leistungsfähiger und
zufriedener zu werden.

(Quellen: docs/product/app-context.md, context/refs/app_context_v3.2.md)

1.2 Zielgruppe
	•	Frauen ab 18 Jahren, primärer Fokus ca. 25–45+, mit beruflichem und
privatem Alltag (Job, ggf. Familie), die ihre Gesundheit aktiver
gestalten wollen.
	•	Sie sind grundsätzlich bereit, in sich selbst zu investieren
(Zeit, ggf. Geld für Programme), haben aber wenig Zeit und Geduld
für trial-and-error im Internet.
	•	Typische Merkmale:
	•	fühlen sich von Social-Media-„Health“-Content eher erschlagen als
unterstützt,
	•	möchten fitter und gesünder werden, ohne in Extreme abzurutschen,
	•	wollen verstehen, wie ihr Zyklus ihren Alltag, ihre Energie und
ihr Training beeinflusst.
	•	Geografischer Fokus initial: DACH-Raum (deutschsprachige
Nutzerinnen), mit EU-Only-Infrastruktur und klaren
Datenschutzversprechen als Vertrauensanker.

(Quellen: app-context, Roadmap, Dossiers)

1.3 Hauptprobleme, die LUVI löst
	1.	Kein auf den Zyklus abgestimmtes Training im Alltag
Die meisten Trainingspläne ignorieren Zyklusphasen und Hormonschwankungen.
LUVI bietet Programme, die Energielevel, Regeneration und Zyklusphase
berücksichtigen, ohne in medizinische Diagnostik zu rutschen.
	2.	Zuviel widersprüchlicher Health-Content, zu wenig Evidenz
Social Media und das Web sind voll mit Tipps, Challenges und „Biohacks“,
deren Qualität schwer zu beurteilen ist. LUVI setzt auf kuratierten,
evidenznahen Content von Expert:innen und macht transparent, was
Empfehlung vs. gesicherte Evidenz ist.
	3.	Kein Ort, an dem ich gleichzeitig handeln und verstehen kann
Entweder „Apps zum Abarbeiten“ (Workouts) oder tiefe Inhalte in YouTube/
Podcasts, die schwer in den Alltag übersetzbar sind. LUVI verbindet
praktische Programme (Training, Regeneration, Ernährung/Biohacking)
mit begleitendem Lern-Content, damit Nutzerinnen verstehen, warum
etwas für sie sinnvoll ist.

Zusätzlich zur Problemseite bietet LUVI eine klare Value-Story:
- Im Free-Bereich: ein kuratierter Stream mit phasenbewusst
  priorisierten Videos, Daily-5-Impulsen, Save/Share/Weitersehen und
  einem „Heute“-Hero, der in wenigen Sekunden zeigt, was gerade gut
  passt.
- Im Premium-Bereich: strukturierte Coach-Programme, die sich an
  Zyklusphasen und Alltag orientieren, sowie KI-Suche und KI-Playlists,
  die zu kuratiertem Content passen. Ziel ist, dass Nutzerinnen in
  rund 30 Sekunden Klarheit darüber gewinnen, was heute sinnvoll ist
  – ohne lange zu suchen.
- Klare, transparente Privacy-Entscheidungen (EU-only Gateway, CMP für
  externe Videos, nachvollziehbare Consent-Logs, stateless AI) gehören
  bewusst zum Produktversprechen und sind nicht nur „Compliance“.

(Quellen: app-context, use-cases, Dossiers)

1.4 Rolle von Zyklus & Hormonen

LUVI ist Lifestyle-first mit zyklusbewusster Intelligenz – kein klassischer
Zyklus-Tracker und ausdrücklich kein Medizinprodukt.
	•	Zyklusdaten und hormonelle Muster werden als querliegende Logik genutzt,
um Training, Ernährung/Biohacking, Regeneration und Mind-Programme besser
zu timen und Inhalte sinnvoll zu priorisieren.
	•	Die App gibt lebensstilorientierte, evidenznahe Empfehlungen, bietet
Programme von Expert:innen und kuratierten Content, aber:
	•	stellt keine Diagnosen,
	•	trifft keine Therapieentscheidungen,
	•	gibt keine Heilversprechen.

Alle Aussagen und Features müssen mit den Privacy- und Compliance-Dokumenten
(DSGVO-Impact, Phase-Definitionen, Consent-Texte, SaMD-Abgrenzung) kompatibel
sein.

Im Interface zeigt sich die Zykluslogik u. a. durch Phase-Badges und
kurze Tages-Texte auf dem Home-Screen („Heute in deiner Phase“) sowie
durch phasenabhängige Priorisierung im Stream-Feed. So bleibt die App
Lifestyle-first, aber zyklusbewusst in der Priorisierung.

(Quellen: docs/phase_definitions.md, docs/consent_texts.md, LUVI_Dossiers)

1.5 Globale KPIs (erste Hypothesen)

Die folgenden Kennzahlen sind keine harten Versprechen, sondern
Orientierungspunkte, um zu prüfen, ob LUVI als „Daily Companion“ und
Lern-/Handlungsplattform funktioniert:
	•	Engagement als Daily Companion
	•	Anteil aktiver Nutzerinnen, die den „Heute“-Screen an mehreren Tagen
pro Woche öffnen (z. B. 3–5 Tage/Woche).
	•	Aktive Nutzung (Sessions)
	•	Durchschnittliche Anzahl abgeschlossener Sessions (Workouts,
Regenerations- oder Mind-Sessions, Lern-/Content-Sessions) pro aktive
Nutzerin pro Woche.
	•	Programm-Nutzung
	•	Anteil der Nutzerinnen, die ein Coach-Programm starten und vollständig
abschließen (Program Completion Rate), insbesondere bei Premium-Angeboten.
	•	Content-Wert
	•	Anzahl „Gespeichert“- oder „Merken“-Aktionen pro aktive Nutzerin und
Woche (Signal für wahrgenommenen Wert des kuratierten Contents).
	•	Langfristige Bindung
	•	Retention-Rate nach X Tagen (z. B. 30 Tage), um zu sehen, ob LUVI im
Alltag verankert bleibt.

Aus diesen Leit-KPIs können später konkrete North-Star-Metriken und
untergeordnete Kennzahlen (z. B. Watch-Time pro DAU, CTR für Daily-5
oder Save-/Share-Raten) in den Analytics- und Produktdokumenten
abgeleitet werden, ohne dass BMAD selbst detaillierte Zahlenpläne
pflegt.

Konkrete Zielwerte werden in Produkt-/Analytics-Dokumenten und Dashboards
festgelegt und iterativ angepasst. BMAD Global dient hier als konzeptioneller
Rahmen, nicht als starres Zahlenziel.

(Quellen: app-context, roadmap, analytics/taxonomy.md)

## 2. Modellierung (Domain & Daten)

### 2.1 Domänenübersicht

- **User (Supabase Auth)** – Besitzerin aller personenbezogenen Daten und
  Interaktionen, über `user_id` in allen relevanten Tabellen referenziert.
- **Consent** – Speichert Einwilligungen der Nutzerin zu bestimmten
  Scopes/Versionen (z. B. CMP, E-Mail-Preferences).
- **ConsentLog (CMP / Video-Consent)** – Audit-Log einzelner Consent-
  Entscheidungen für externe Videos (z. B. YouTube-Player).
- **CycleData** – Basisdaten für die Zyklusberechnung (letzte Periode,
  Zykluslänge, Periodendauer, Alter, user_id).
- **Phase** – Fachliches Modell der Zyklusphasen inklusive Dauer,
  Kriterien und UI-Hinweisen (wird berechnet, nicht gespeichert).
- **Cycle/Phase Computation („TodayState“)** – Logik zur Berechnung der
  aktuellen Phase/Tag für Home/Badges (z. B. `compute_cycle_info`).
- **DailyPlan** – Tagesprotokoll für Energie, Stimmung, Symptome,
  Aktivitäten, Schlaf und Notizen.
- **Content/Video** – Kuratierte Videos als zentrale Content-Einheit im
  Stream.
- **Channel** – Quelle/Creator-Kanal eines Videos.
- **VideoPhase** – Zuordnung/Score, wie gut ein Video zu einzelnen
  Zyklusphasen passt.
- **VideoTag** – Schlagworte/Tags pro Video.
- **ContentVideoHealth** – Status/Health eines Videos (z. B. embeddable,
  gelöscht, privat, Fehlerstatus).
- **UserEvent** – Tracking von Video-Interaktionen in der App
  (z. B. open/play/resume/save/share).
- **AnalyticsEvent (Taxonomy)** – Abstraktes Schema für App-weite Events
  (ohne PII) für Analytics/Funnels.
- **RankingScore** – Berechneter Score zur Priorisierung von Videos
  (phase_match, recency, editorial, popularity, affinity,
  diversity_penalty).
- **Program/CoachProgram** – Premium-Trainingspläne (z. B. 4-Wochen-
  Programme, phasenbewusst).
- **Consent Copy (CMP)** – Struktur und Texte der Consent-Overlays/
  Buttons für externe Videos.

*(Quellen: docs/LUVI_Dossiers_v1.0.md, docs/phase_definitions.md,
docs/consent_texts.md, docs/ranking_heuristic.md, docs/analytics/taxonomy.md,
docs/product/roadmap.md, docs/audits/SUPABASE_SCHEMA_public.ts)*

### 2.2 Domäne → Tabellen/Views → Status

| Domäne                | Supabase-Tabellen/Views                          | Status       | Quellen                           |
|-----------------------|--------------------------------------------------|-------------|-----------------------------------|
| User                  | `auth.users`, `user_id`-Felder in anderen Tabellen | Ist        | Schema-Audit, Roadmap            |
| Consent               | `public.consents`                                | Ist         | Schema-Audit, Roadmap, Dossiers  |
| ConsentLog            | `public.consent_logs`                            | Geplant     | Roadmap (S2), consent_texts      |
| CycleData             | `public.cycle_data`                              | Ist         | Schema-Audit, Roadmap (S0/S1)    |
| Phase                 | – (berechnet, keine eigene Tabelle)              | Logik-only  | phase_definitions, Dossiers      |
| Cycle/Phase Computation („TodayState“) | – (Funktionen/Services, z. B. `compute_cycle_info`) | Logik-only | Roadmap (S1)              |
| DailyPlan             | `public.daily_plan`                              | Ist         | Schema-Audit                     |
| Content/Video         | `public.video`                                   | Geplant     | Roadmap (S2 DB/Schema)           |
| Channel               | `public.channel`                                 | Geplant     | Roadmap (S2 DB/Schema)           |
| VideoPhase            | `public.video_phase`                             | Geplant     | Roadmap (S2 DB/Schema)           |
| VideoTag              | `public.video_tags`                              | Geplant     | Roadmap (S2 DB/Schema)           |
| ContentVideoHealth    | `public.content_video_health`                    | Geplant     | Roadmap (S2.5 Tech)              |
| UserEvent             | `public.user_event`                              | Geplant     | Roadmap (S2 DB/Schema)           |
| AnalyticsEvent        | Event-Stream (PostHog-Schema, kein DB-Table)     | Logik-only  | analytics/taxonomy, Roadmap      |
| RankingScore          | – (berechnete View/Funktion)                     | Logik-only  | ranking_heuristic, Dossiers      |
| Program/CoachProgram  | – (Domäne definiert, Tabelle noch zu designen)   | Geplant     | Roadmap (S5)                     |
| Consent Copy (CMP)    | – (Copy/Config, gekoppelt an Consent/CMP-Flow)   | Copy/Config | consent_texts, Roadmap (CMP)     |

### 2.3 Wichtige Beziehungen & Invarianten

*(wird nach Invarianten-Audit gefüllt – z. B. User → CycleData/DailyPlan →
Events/Consents, Phase-Logik, Ranking-Eigenschaften)*

### 2.4 RLS-/Policy-Grundsätze (Übersicht)

*(wird nach separatem RLS-/Policy-Audit aus ADR-0002, Consent-Map,
TTL-Policies etc. gefüllt)*

## 3. Architektur (System & Flows)

### 3.1 System-Bausteine

- **Flutter-App (iOS-first, Riverpod + GoRouter)**  
  Haupt-Client mit Feature-Mirror-Struktur (`lib/features/**`), zentralem
  Core (`lib/core/**`) und einem separaten Services-Package (`services/luvi_services`).
  Die App rendert die fünf Hauptbereiche (Home/Today, Stream, Coach,
  Kalender/Zyklus, Profil) und konsumiert alle Backends ausschließlich
  über klar definierte Services.

- **Supabase (Postgres EU/Frankfurt)**  
  Primäre Daten- und Auth-Schicht mit RLS owner-based auf allen
  personenbezogenen Tabellen (z. B. cycle_data, daily_plan, consents).
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
  künftig für Push-Notifications; Newsletter/Comms laufen über Brevo mit
  Double-Opt-in und Consent-Verknüpfung.

- **CI/CD & QA-Infrastruktur**  
  GitHub Actions orchestrieren `flutter analyze`/`flutter test`, Privacy-
  Gate, Preview-Health-Checks und weitere Pipelines. Greptile Review ist
  als Required Check vorgeschaltet; CodeRabbit wird nur noch lokal als
  optionaler Preflight genutzt (kein GitHub-Check; Policy siehe `docs/engineering/ai-reviewer.md`). Traycer dient als Plan-/Review-Softgate
  (Trial), Archon als zentraler MCP/SSOT für Agentenwissen.

- **Supabase MCP (dev-only, read-only)**  
  Ermöglicht Agenten (z. B. Codex) kontrollierten, lesenden Zugriff auf
  Schema/Definitionen, ohne Risiko für produktive Daten. Unterstützt das
  RAG-first-Prinzip aus den ADRs.

- **Offline Resume / Lokale Verschlüsselung**  
  Für bestimmte Features (z. B. offline Resume) wird eine lokale
  verschlüsselte Datenbank (SQLCipher) genutzt, deren Schlüssel in
  Secure Storage liegen. Rotation/Rehydrate-Pfade sind im Security-Design
  dokumentiert.

*(Quellen: tech-stack.md, tech_stack_current.yaml, repo-structure.md,
flutter-structure.md, platform/healthcheck.md, offline_resume_key_management.md)*

### 3.2 Kern-Flows (High-Level)

- **FTUE/Onboarding + Consent**  
  Beim ersten Start durchlaufen Nutzerinnen den Onboarding-Flow mit
  Consent-Dialogen (inkl. externem Content) und Präferenzabfrage. Die
  App schreibt Consent- und Onboarding-Daten nach Supabase (RLS-geschützt)
  und erzeugt entsprechende Analytics-Events. Edge/Gateway sorgt für
  Audit-Logging und Privacy-Gates; Sentry/PostHog überwachen Stabilität.

- **Today/Home (Phase-Badge)**  
  Die App lädt Zyklusdaten (`cycle_data`) aus Supabase, berechnet lokal
  die aktuelle Phase und den Tages-Kontext (z. B. `compute_cycle_info`)
  und rendert Phase-Badge und „Heute“-Text. Optional werden Events
  geloggt (z. B. „Today viewed“), ohne dass Client-seitig `service_role`
  genutzt wird.

- **Stream/Video + CMP**  
  Der Stream-Tab lädt einen phasenpriorisierten Feed aus Supabase
  (unter Nutzung von Phase-Scores/Ranking). Vor dem Abspielen eines
  externen Videos wird ein CMP-Overlay gezeigt; erst nach expliziter
  Zustimmung lädt die App den YouTube-Player (`nocookie`). Nutzeraktionen
  wie play/save/share/resume werden als Events an PostHog gesendet;
  Consent-Entscheidungen landen in Consent-Logs (Supabase). AI-gestützte
  Sortierung/Empfehlung erfolgt nur über das Edge-/AI-Layer mit Langfuse-
  Tracing.

- **Coach Trial → Paid (geplant)**  
  Im Coach-Tab sehen Nutzerinnen Teaser und Previews von phasenbewussten
  4-Wochen-Programmen. Ein Paywall-/RevenueCat-Flow (noch zu
  implementieren) wird über Supabase-Entitlements und Auth gesteuert.
  Edge/Gateway überprüft Tokens; PostHog erfasst Trial-/Purchase-Events;
  Sentry überwacht kritische Fehler.

- **Calendar/Cycle View**  
  Nutzerinnen pflegen ihre Zyklusdaten in einem Kalender-/Form-Flow;
  diese landen in `cycle_data` (Supabase). Die App berechnet Phasen
  lokal und zeigt Historie sowie zukünftige Phasen an. Home/Stream
  nutzen diesen Kontext, um Inhalte und Programme zu personalisieren.

- **Healthcheck & Operations**  
  Der Endpunkt `/api/health` am Vercel Edge liefert Statusinformationen
  über kritische Abhängigkeiten (Supabase, Redis, AI-Provider, etc.).
  CI/CD ruft den Health-Check in Preview/Prod auf; Runbooks definieren
  Hysterese, Statusübergänge und Incident-Response. Monitoring/Alerts
  laufen über Vercel/PostHog/Sentry.

- **Offline Resume Snapshot**  
  Bestimmte Zustände (z. B. laufende Sessions) können lokal in einer
  verschlüsselten Datenbank gesichert werden. Bei Wiederanmeldung werden
  sie, sofern konsistent, mit Serverzustand abgeglichen. Schlüssel-Handling
  und Telemetrie folgen dem Offline-Resume-Security-Design.

*(Quellen: tech-stack, flutter-structure, roadmap, healthcheck, security/offline_resume_key_management)*

### 3.3 Tech-Stack-Summary

- **Frontend:** Flutter 3.35 / Dart 3.9, Riverpod 3, GoRouter, Feature-
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
  (mit DPA/SCC-konformem Einsatz), Brevo für Newsletter/Comms mit DOI.
- **CI/CD & QA:** GitHub Actions für Analyze/Test/Privacy-Gate/Preview-
  Health, Greptile Review als Required Check (GitHub App), optionale
  lokale CodeRabbit-Reviews vor dem PR, Traycer als Plan-/Review-Softgate,
  Archon MCP als Wissens-SSOT; Runbooks und Checklisten sichern manuelle
  Prove-Schritte.
- **Security & Compliance:** EU-only Regionen, strikte RLS/Least-
  Privilege, Consent-Logging, PII-Redaction an der Edge, Offline-
  Verschlüsselung mit Secure Storage Keys, keine `service_role` im
  Client; AI-Integrationen sind stateless und durch Privacy-Gates
  abgesichert.

### 3.4 Architektur-Guards (ADRs)

- **ADR-0001 – RAG-First Wissenshierarchie**  
  Wissen aus RAG/Docs (App-Kontext, Dossiers, Schema, ADRs) hat Vorrang
  vor spekulativen LLM-Antworten. Neue Features sollen sich zuerst an
  bestehenden Architektur- und Domänen-Dokumenten orientieren.

- **ADR-0002 – Least-Privilege & RLS (Supabase)**  
  Alle Tabellen mit personenbezogenen Daten laufen mit RLS ON und
  owner-based Policies. `service_role`-Zugriff ist ausschließlich
  serverseitig (Edge Functions) erlaubt. Client-Code darf niemals
  `service_role` nutzen.

- **ADR-0003 – Dev-Taktik „Make-It-Work-First“ (MIWF)**  
  Features werden zuerst als Happy Path mit passenden Tests umgesetzt.
  Zusätzliche Guards/Härtungen folgen auf Basis echter Signale (Sentry/
  PostHog, Privacy-Reviews), um Iteration und Fokus nicht zu blockieren.

- **ADR-0004 – Vercel Edge Gateway (EU/fra1)**  
  Das Vercel Edge Gateway in `fra1` ist der einzige HTTP-Einstieg für
  die App, inklusive `/api/health` als operativem Proof-of-Life. JWT/
  CORS, Rate-Limits und PII-Redaction sind Pflicht; alle externen
  Integrationen laufen durch dieses Gateway.

- **ADR-0005 – Traycer-Integration (Trial)**  
  Traycer dient als Plan-/Review-Softgate, um BMAD/PRP-Disziplin bei der
  Story-Planung zu unterstützen. Greptile Review, CI und Health-Gates
  bleiben die einzigen „harten“ Mergeregulatoren.

Diese Guards bilden das architektonische Geländer für neue Features:
Sie stellen sicher, dass Implementierungen doc-getrieben, least-
privilege, Edge-zentriert, iterativ (MIWF) und planbasiert (Traycer)
erfolgen.

## 4. Definition of Done (DoD & Quality Gates)

### 4.1 Globales DoD

Für LUVI gilt ein globales Definition-of-Done, das in
`docs/definition-of-done.md`, `context/agents/_acceptance_v1.1.md`
sowie im Gold-Standard-Workflow beschrieben ist:

- **Code-Qualität & Tests**
  - `flutter analyze` und `flutter test` laufen grün (inkl. Unit- und
    Widget-Tests, passend zur Story).
  - Relevante Services-/Backend-Tests (Dart/Node) sind vorhanden und
    sinnvoll.
  - Kein „Make-It-Work“ ohne anschließendes Prove (Tests, Fixes).

- **Governance & Doku**
  - Betroffene ADRs werden geprüft und bei Bedarf aktualisiert.
  - BMAD/Traycer-Plan und ggf. Sprint-BMAD-Doku sind konsistent zur
    Implementierung.
  - Wichtige Entscheidungen werden in passenden Dossiers/Docs verlinkt.

- **Reviews & Gates**
  - Greptile Review ist grün (GitHub Required Check).
  - Optionale lokale CodeRabbit-Reviews vor dem PR sind abgearbeitet (nur lokaler Preflight, kein CI-Gate),
    falls verwendet.
  - CI-Pipeline (GitHub Actions) ist grün (analyze/test/privacy-gate).
  - Preview-/Prod-Health-Checks (/api/health) entsprechen den
    Healthcheck-Spezifikationen.
- **Agenten & Ablauf**
  - UI/Dataviz-Stories werden primär von Claude Code (DoD: ui-frontend/dataviz) umgesetzt, Backend/DB/Privacy-Stories von Codex (DoD: api-backend/db-admin/qa-dsgvo).
  - Für UI/Dataviz-PRs ist ein Codex-Review Pflicht (zusätzlich zu CI + Greptile), bevor gemergt wird.
  - Beide Agenten folgen BMAD → PRP und nutzen dieses Dokument als BMAD Global.

*(Quellen: docs/definition-of-done.md, context/agents/_acceptance_v1.1.md,
docs/engineering/gold-standard-workflow.md)*

### 4.2 Rollen-spezifische DoD-Erweiterungen

Zusätzlich zum globalen DoD gelten rollen-spezifische Kriterien, die in
`_acceptance_v1.1.md` und den Checklisten unter `docs/engineering/checklists/`
beschrieben sind:

- **UI/Frontend (ui-frontend)**  
  - Mindestens 1 Unit-Test + 1 Widget-Test pro relevanter UI-Story.
  - Navigation/State/A11y entsprechen den Guidelines (GoRouter, Keys,
    Localisation).
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
  - Consent-/Retention-/Logging-Aspekte sind mit Consent Map/TTL-Policies
    abgestimmt.

- **DataViz (dataviz)**  
  - Charts/ Dashboards folgen A11y- und Analytics-Guidelines.
  - Events passen zur Analytics-Taxonomy (`docs/analytics/taxonomy.md`).
  - DataViz-Checkliste (`checklists/dataviz.md`) ist geprüft.

*(Quellen: context/agents/_acceptance_v1.1.md,
docs/engineering/checklists/ui.md, api.md, db.md, privacy.md, dataviz.md)*

### 4.3 Required Checks & Gates (CI, Health, AI, Privacy)

Einige Checks sind als „harte Gates“ definiert und müssen für jede
relevante Änderung erfüllt sein:

- **CI & Code-Review**
  - GitHub Actions: Analyze/Test, Privacy-Gate, Preview-Deploy.
  - Greptile Review: Pflicht-Review vor Merge (Required Check).
  - CodeRabbit: optionales lokales Preflight-Review vor dem PR
    (CLI/IDE), kein GitHub Required Check mehr und kein Branch-Protection-Gate (Details: `docs/engineering/ai-reviewer.md`).

- **Health & Observability**
  - `/api/health` muss in Preview/Prod den Statusanforderungen aus
    `docs/platform/healthcheck.md` genügen.
  - Sentry/Crash-Rate und Performance-Budgets werden überwacht; bei
    kritischen Regressions kein „einfach weiter so“.

- **Privacy & DSGVO**
  - Privacy-Gate in CI bei relevanten Änderungen.
  - Privacy-Reviews und DSGVO-Checklist sind umgesetzt, bevor Features
    live gehen.
  - Consent-Flows (z. B. CMP für externe Videos) müssen produktiv
    funktional und juristisch abgesegnet sein.

- **AI-spezifische Gates**
  - AI-Integrationen laufen über das Vercel AI SDK + Langfuse; jede
    neue AI-Funktion benötigt mindestens einen Langfuse-Trace als
    Referenz.
  - Supabase MCP/Archon werden genutzt, um Schema/Docs vor einem
    AI-basierten Eingriff zu prüfen (RAG-first, kein „blindes“ Schema-
    Raten).

*(Quellen: Gold-Standard-Workflow, healthcheck.md, analytics/taxonomy.md,
Langfuse-/MCP-Dokus)*

### 4.4 Operative Runbooks & Prove

Neben den automatischen Gates existieren Runbooks und Checklisten, die
das „Prove“ im BMAD/PRP-Prozess unterstützen:

- **Incident Response & Datenschutzvorfälle**  
  - Runbook `docs/runbooks/incident-response.md` beschreibt Rollen,
    Ablauf und Nachweise im Falle von DSGVO-relevanten Incidents.

- **Health & Edge-Tests**  
  - `docs/runbooks/vercel-health-check.md` beschreibt, wie `/api/health`
    in Preview/Prod getestet und interpretiert wird.
  - Weitere Runbooks für Edge-Function-Tests, RLS-Debugging,
    Analytics-Backfill und Consent-Flow-Verification unterstützen
    die Prove-Phase.

- **Memory & Wartung**  
  - `docs/engineering/maintenance-log.md` und weitere Maintenance-
    Dokus halten fest, wann CI-/Action-Pins, Security-Aspekte und
    Infrastruktur überprüft wurden.

BMAD Global verweist hier bewusst auf die Runbooks, statt sie zu
duplizieren: jede Prove-Phase in einem Sprint/Feature kann sich auf die
jeweils relevanten Runbooks und Checklisten stützen.

*(Quellen: docs/runbooks/*.md, docs/engineering/maintenance-log.md,
docs/privacy/reviews/*.md)*

## 5. Quellen & Referenzen

*(Liste der wichtigsten SSOT-Dokumente – folgt, wenn 1–4 stehen)*
