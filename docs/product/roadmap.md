# LUVI Roadmap — MVP+ (Finale Version)

**Status:** Ready for Sprint 1
**Basis:** BMAD v2.1, App Kontext v2.0, Tech-Stack MVP+
**Fokus:** Rebrand → Core Engine (Cycle/Workout) → Value (Coach/Brain) → Biz (IAP)

---

## 🛠 KONSTANTEN (Global für ALLE Sprints)

*Diese Regeln sind unveränderlich und müssen bei jedem PR beachtet werden.*

### 1. Definition of Done (DoD) & Quality Gates

- **CI:** `flutter analyze` und `flutter test` müssen grün sein.
- **Test-Coverage:** Mindestens **1 Unit-Test** (Logik) + **1 Widget-Test** (UI) pro Story.
- **Privacy:** DSGVO-Review (`docs/privacy/reviews/*.md`) pro datenrelevantem Task erforderlich.
- **Review:**
  - **Greptile Review:** Grün (GitHub Required Check).
  - **CodeRabbit:** Nur noch optional lokal vor PR (kein CI-Gate mehr).
  - **Health:** Vercel Preview `/api/health` muss Status **200** liefern.
- **ADRs:** Architectural Decision Records müssen bei Änderungen gepflegt werden.

### 2. Datenschutz & Architektur (Hard Constraints)

- **Backend:** Supabase EU (Frankfurt). **RLS owner-based** ist Pflicht.
- **Security:** Kein `service_role` im Client Code!
- **Edge Gateway:** Aller externer Traffic (AI, Analytics, Push, Auth) MUSS durch den **Vercel Edge Proxy (`fra1`)** laufen (ADR-0004). PII-Redaction findet dort statt.
- **Offline Security:** Sensitiver lokaler State (z.B. laufendes Workout) muss via **SQLCipher** verschlüsselt werden.
- **Push:** Payloads dürfen **KEINE Gesundheitsdaten** enthalten (Content-First Strategie gemäß ADR-0005).

### 3. Governance & Workflow

- **Planung:** **BMAD** (Business, Model, Arch, DoD) ist Pflicht vor Code-Start bei Medium/High Impact.
- **SSOT:** **Archon (MCP)** ist die Single Source of Truth für Dossiers.
- **Agenten:**
  - **Gemini:** Architektur & Planung.
  - **Codex:** Backend, DB, Privacy.
  - **Claude Code:** UI, Frontend, Dataviz.
- **Prove:** Self-Check + DSGVO-Check nach dem Coden.

### 4. Code & Struktur

- **Feature Flags:** `lib/core/config/feature_flags.dart` (`--dart-define`). Alle neuen Features müssen hinter einem Flag entwickelt werden.
- **Repo-Struktur:** Features sind isoliert (`features/name/{data,domain,state,widgets}`). `core/*` ist für geteilte Logik. `tests/goldens` spiegeln Features.
- **Events:** `lib/core/analytics/analytics.dart` nutzt PostHog EU (via Edge Proxy).

### 5. Performance Ziele (Default)

- **Navigation:** Screen-Wechsel First Frame < **400 ms** (P95).
- **Scrolling:** Listen-Frame-Drops < **1 %**.
- **Start:** App-Start bis Interactive < **1.2 s** (P95).

---

## ✅ S0 — Foundation & Setup (Erledigt/Wartung)

- **Tech:** Archon (MCP), Langfuse, Supabase MCP konfiguriert.
- **Repo:** Struktur steht, CI-Pipeline grün.
- **Status:** Screens für Splash/Auth/Onboarding funktional vorhanden (aber altes Design → siehe S1).
- **Flags:** `allow_ftue_backend`, `enable_consent_v1`.

---

## 🎨 S1 — Rebranding & The Mathematical Heart

**Ziel:** Das Design-System (Tokens) finalisieren, existierende Screens (Auth/Onboarding) optisch anpassen und die Zyklus-Logik implementieren.

### 1.1 UI Rebranding (Refactoring)

- **Agent:** Claude Code
- **Kontext:** Überarbeitung der bestehenden Screens auf Basis von `lib/core/design_tokens/`.
- **Screens (Liste):** Splash, Welcome, Auth (Login/Register/PW-Reset), Consent, Onboarding (9 Steps), Success.
- **Task:**
  - Design Tokens finalisieren (Farben, Typo, Spacing).
  - Refactoring: Alle oben genannten Screens auf neue Tokens umstellen.
  - **Guard:** `ui_guard_audit_test.dart` aktivieren (verbietet Hardcoded Colors).
- **Hinweis:** Nutze die existierende Backend-Anbindung (Supabase Auth/DB), ändere nur das UI Layer.

### 1.2 Cycle Logic Engine (Backend/Logic)

- **Agent:** Codex
- **Kontext:** Deterministische Phasen-Berechnung (Keine KI-Halluzination!).
- **Task:**
  - SSOT erstellen: `docs/contracts/compute_cycle_info.md`.
  - Implementierung `compute_cycle_info.dart`:
    - Input: `lmp_date`, `cycle_length`.
    - **Logik:** Wenn User keine Periodenlänge angibt → Default 5 Tage (phase_definitions.md SSOT).
    - Output: `Phase` (Menstruation, Follikel, Ovulation, Luteal).
  - **Safety:** Keine Eisprung-Vorhersage.
  - **Tests:** Tabellen-Tests für Randfälle (Jahreswechsel, Schaltjahr).

### 1.3 Onboarding Data Flow

- **Agent:** Codex
- **Task:**
  - Validierung DB-Writes: `cycle_data` (LMP) und `user_preferences` (Ernährung).
  - **Ernährungs-Enum:** Mapping sicherstellen (Omnivor/Vegetarisch/Vegan) – wichtig für Nutrition Guards in S3.

---

## 🏠 S2 — The Daily Companion (Home & Navigation)

**Ziel:** Der User landet auf einem Home-Screen, der die in S1 berechnete Phase korrekt anzeigt.

### 2.1 Navigation & Shell

- **Agent:** Claude Code
- **Task:**
  - Bottom Navigation Bar (Home, Zyklus, Coach, Brain, Profil).
  - Routing via `go_router` mit ShellRoute.
  - **Profil Screen:** Basis-UI für Settings/Account/Logout (Funktionalität folgt in S6).

### 2.2 Home Screen & Smart Hero Card

- **Agent:** Claude Code
- **Task:**
  - **Daily Mindset (UI):** Karte oben (Text vorerst Platzhalter/Lokal).
  - **Phase Badge:** Anzeige („Tag 5 · Luteal").
  - **Smart Hero Card:** State Machine implementieren (`Default` → `Scheduled` → `Overdue` → `Resume`).
  - **Energy Menu:** Popup (Power 85% / Balance 65% / Low 45%).
  - **Quick Check:** UI für "Alles okay?" bei Abweichung (Phase High vs. Energy Low).
  - **Flag:** `enable_home_v2`.

### 2.3 Zyklus Screen

- **Agent:** Claude Code
- **Task:**
  - Kalender-Widget mit gefärbten Phasen (Input aus S1 Logic).
  - Anzeige: "Tag X · [Phase]".
  - Logik: "Periode hat heute begonnen" (Update `cycle_data` via Codex-Service).

---

## 🏋️ S3 — The Engine: Active Workout (High Tech)

**Ziel:** Das Training funktioniert robust und offline-sicher (SQLCipher).

### 3.1 Secure Local Storage (Infrastructure)

- **Agent:** Codex
- **Task:**
  - Einrichtung `sqflite_sqlcipher`.
  - Key-Management via `flutter_secure_storage`.
  - Schema für lokalen State (`local_workout_session`).

### 3.2 Workout Player UI

- **Agent:** Claude Code
- **Screens:** Fullscreen Player (keine Bottom Nav).
- **Task:**
  - Video-Player (aus Supabase Storage via Edge).
  - Timer & Input-Felder (Gewicht/Reps) für Stats.
  - **Crash Protection:** Bei jedem Input → Write in SQLCipher.
  - **Resume Logic:** App Start Check → Redirect zum Player, falls Session aktiv.

### 3.3 Post-Workout & Nutrition Guards

- **Agent:** Claude Code / Codex
- **Screens:** Feedback Screen (Emojis), Post-Workout Card.
- **Task:**
  - **Nutrition Logic (Guards):**
    - IF `diet == omnivor` OR `vegetarian` THEN "Quark/Hüttenkäse".
    - IF `diet == vegan` THEN "Veganer Shake, Edamame, Nüsse".
  - Sync: Local SQLCipher → Supabase `workout_session` bei Netzverfügbarkeit.

---

## 📈 S4 — LUVI Coach (Progress)

**Ziel:** Feedback-Loops schließen. User sieht Fortschritt.

### 4.1 Statistics Dashboard

- **Agent:** Claude Code
- **Screen:** Coach Tab.
- **Task:**
  - **WeeklyPlan:** Ansicht der geplanten Workouts (Wochenübersicht).
  - **Charts:** Aggregation der `exercise_log` Daten aus S3.
    - Kniebeuge-Gewicht über Zeit.
    - Trainingsfrequenz.
  - **Performance:** `fl_chart` optimieren (keine Frame Drops beim Scrollen).

### 4.2 "LUVI lernt" Trigger

- **Agent:** Codex
- **Task:**
  - Trigger-Logik: Wenn `count(workout_sessions) == 12` → Zeige einmaliges Overlay/Card "LUVI hat gelernt...".

---

## 🧠 S5 — LUVI Brain (Content Hub)

**Ziel:** Ersatz für den "Stream". Eine durchsuchbare Wissensdatenbank.

### 5.1 Content Database & Search

- **Agent:** Codex
- **Task:**
  - Schema: `content_item`, `content_tags`, `saved_content`.
  - **Logik:** "Letztes Keyword gewinnt" Heuristik (z.B. "Training Schwangerschaft" → Prio auf Schwangerschaft).
  - **pgvector** Setup für spätere semantische Suche.

### 5.2 Brain UI

- **Agent:** Claude Code
- **Screen:** Brain Tab + Detail View.
- **Task:**
  - Feed-View mit Filter-Chips (Säulen: Schlaf, Ernährung...).
  - Detail-Screen für Artikel/Slides (Markdown Renderer).
  - Bookmark-Funktion.
  - **Flag:** `enable_brain_v1`.

---

## 💰 S6 — Monetization & AI Activation

**Ziel:** Business-Logic und "Magic" Features scharfschalten.

### 6.1 IAP / RevenueCat

- **Agent:** Codex
- **Screens:** Paywall (Trial Offer), Profile (Manage Subscription).
- **Task:**
  - RevenueCat via Edge Proxy anbinden.
  - Entitlements in Supabase syncen.
  - **Locking:** Brain-Artikel und Coach-Charts nur für Premium (Trial).

### 6.2 AI Polish (Vercel AI SDK)

- **Agent:** Codex
- **Screens:** Smart Cycle Journaling Dialog.
- **Task:**
  - **Model-Integration:** Vercel AI SDK Router (OpenAI/Anthropic EU) an `/api/ai/*` binden.
  - **Daily Mindset:** Backend-Job / Edge Function `/api/ai/generate_mindset` aktivieren (1x täglich).
  - **Smart Journaling:** Stift-Button auf Home öffnet Dialog.
    - Logik: Hole Phase → Generiere Frage ("Was darfst du loslassen?").
  - **Observability:** Langfuse Tracing für alle AI-Calls prüfen.

---

## 🏁 S7 — Launch Prep

**Ziel:** Store Readiness.

- **Health:** `/api/health` Monitoring scharfschalten.
- **Privacy Audit:** Prüfen, ob Push-Notifications wirklich KEINE Gesundheitsdaten enthalten (ADR-0005).
- **Assets:** Screenshots erstellen.
- **Performance:** Finaler Check gegen die 400ms/1.2s Ziele aus den Konstanten.

---

## Post-MVP (nach Release)

- Android-Release
- Erweiterte Programme (Menopause, Postpartum etc.)
- Creator-/Expert*innen-Programme mit Revenue-Share
- Newsletter (Brevo DOI) und Lifecycle-Kampagnen
- HealthKit/Wearables (Oura/Apple Health) – nach separatem Research & Legal-Check
- Corporate-Wellness / B2B (optional, langfristig)

---

## Screens & Routen (MVP)

| Screen | Route | Sprint |
|--------|-------|--------|
| SplashScreen | `/` | S0/S1 |
| WelcomeScreen | `/welcome` | S1 |
| AuthScreen (Login/Register/PW-Reset) | `/auth/*` | S1 |
| ConsentScreen | `/consent` | S1 |
| OnboardingFlow (9 Steps) | `/onboarding/*` | S1 |
| SuccessScreen | `/success` | S1 |
| HomeScreen | `/heute` | S2 |
| ZyklusScreen | `/zyklus` | S2 |
| CoachScreen | `/coach` | S4 |
| BrainScreen | `/brain` | S5 |
| ProfileScreen | `/profil` | S2/S6 |
| WorkoutPlayerScreen | `/workout/:id` | S3 |
| PaywallScreen | `/paywall` | S6 |

---

## Teststrategie & Gates

- Pro Feature ≥ 1 Unit + ≥ 1 Widget (Gold Standard).
- CI: analyze/test; Privacy-Gate bei DB-Touches; Vercel Preview /api/health = 200 (Soft Gate vor Merge).
- Sentry/PostHog Smoke in Beta; Crashfree ≥ 99 % vor Store.
- Golden Tests für UI-Stabilität (Badges, Karten, Overlays).
- Für AI-Features Link auf Langfuse-Trace im PR.
