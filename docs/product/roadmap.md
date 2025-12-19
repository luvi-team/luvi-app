# LUVI Roadmap



KONSTANTEN (für ALLE Sprints – unverändert aus deinen Standards)



• DoD: gemäß `context/agents/_acceptance_v1.1.md` (Core + Role extensions; UI/DataViz: ≥ 1 Unit + ≥ 1 Widget je Story). Greptile Review grün (GitHub Required Check); optional lokales CodeRabbit-Review vor dem PR (lokaler Preflight, kein GitHub-Check); `/api/health = 200`.  



• Datenschutz & Architektur: Supabase EU (RLS owner-based), kein `service_role` im Client; Vercel Edge `fra1` als Gateway (transient, PII-redacted Logging), EU-only.  



• Governance & Workflow: Traycer + BMAD (vor Code), Prove (Self-Check + DSGVO) nach Code; Branch Protection inkl. Vercel Preview Health 200.  



• Feature Flags: `lib/core/config/feature_flags.dart` (`--dart-define`); alle Features per Flag gatebar.  



• Events: `lib/core/analytics/analytics.dart` → S0 Debug, ab S3 auf PostHog EU umschalten.  



• Repo-Struktur: `features/*` (data/domain/state/widgets), `core/*`, `services/supabase_service.dart`, `tests/goldens` spiegeln Features.  



• Perf-Ziele (Default): Screen-Wechsel First Frame < 400 ms (P95); Listen-Frame-Drops < 1 %; Player-Start < 1.2 s (P95) nach Consent.





--------------------------------------------------------------------



S0 — FTUE E2E (Splash → Welcome → Consent → Auth → Onboarding → Home) + Pivot-Vorbereitung



**Goal**



• Erster Start mit echten Daten; Consent & Onboarding persistiert; Home zeigt reale Zyklusphase.  

• Pivot-Vorbereitung: Consent-Text erweitert um „Externe Inhalte (YouTube)“; Onboarding sammelt Content-Präferenzen (Kategorien, Sprache); **Basis-Lokalisierung DE/EN steht.**



**UX/Produkt**



• Consent-Screen: zusätzlicher Abschnitt „Externe Inhalte (YouTube)“ (Info), Link zur Datenschutzerklärung (Viewer vorhanden).  

• Onboarding:  

  - Zyklus-Eckdaten wie gehabt  

  - Präferenzen (Kategorien: Workout, Ernährung & Biohacking, Regeneration & Achtsamkeit, Beauty/Lifestyle; Sprache DE/EN)  

• Home: Platzhalter-Reihe „Für deine Phase heute“ (statisch 3–5 Karten) bis S2 live ist.



**Tech**



• Edge Function `/functions/log_consent` (Audit Insert); Client: `ConsentService.accept(payload)`.  

• Supabase `upsertCycleData()`; Offline-Draft bei schlechter Verbindung.  

• Links `PRIVACY_URL` / `TERMS_URL` funktional bzw. lokaler Markdown-Viewer.  

• **Lokalisierung-Infra DE/EN:** AppLocalizations, Locale-Handling (Systemsprache + manueller Switch), Basis-Mechanik für sprachabhängige Texte.



**Events**



• `consent_accepted`, `onboarding_completed`, `home_phase_rendered`



**Flags**



• `allow_ftue_backend`, `enable_consent_v1`





--------------------------------------------------------------------
 

S0.5 — Foundation (Archon · Langfuse · Supabase MCP)   >erledigt!



**Goal**



• Projekt-Wissen in **Archon (MCP)** ablegen (Phase-Definitionen, Consent-Copy, Ranking-Heuristik, `AGENTS.md`).  

• **Langfuse** an `/api/ai/*` hängen (Trace-IDs, Token/Kosten, Latenz, ToolCalls; Workspace/Projekt).  

• **Supabase MCP**: Staging-Projekt; read-only Rolle; Whitelist für `describe`/`plan`; keine Prod-Writes.



**Tech**



• Archon: Dossiers `context/` spiegeln; MCP-Verbindung zu Codex testen.  

• Langfuse: Edge Middleware → Trace + userId + featureFlag.  

• MCP: OAuth/Scopes; Staging-DB; Migrations über PR/CI.



**DoD**



• Archon-Dossiers verlinkt (Phase, Consent, Ranking) im Repo.  

• Langfuse-Trace sichtbar für 1 Beispiel-Call (URL im PR).  

• MCP Dry-Run erfolgreich (`describe_schema`, `plan_migration`) in Staging.





--------------------------------------------------------------------



S1 — Zyklus-Logik & Home-Bindung (deterministisch)



**Goal**



• Korrekte Phasenberechnung (Menstruation/Follikel/Ovulation/Luteal) + Home-Badge/Week-Strip; Compute P95 ≤ 50 ms.



**UX/Produkt**



• Home: Phase-Badge + kurzer „Heute“-Satz (z. B. „Luteal (Tag 5) – Fokus auf Regeneration“).



**Tech**



• SSOT: `docs/contracts/compute_cycle_info.md` (Inputs/Outputs, Offsets/Clamps/EdgeCases).  

• `compute_cycle_info.dart` → Home bindet DB → `compute` → render.



**Events/Tests**



• `cycle_input_completed`, `home_phase_rendered`  

• Tabellen-Tests (EdgeCases), Widget-Goldens; P95 50 ms.



**Flag/Backout**



• `allow_onboarding_core=false` → statisches Badge





--------------------------------------------------------------------



S2 — STREAM v1 (Pivot-Kern): Feed + Player (YouTube IFrame) + CMP (Consent-Overlay) + Speichern/Teilen + „Weiter ansehen“



**Goal**



• Neuer Tab „Stream“. Endlos-Feed, phasenpriorisiert, mit offiziellem YouTube-Player.  

• Consent-Overlay vor IFrame-Load (Long/Short; DE/EN); Logging + Fallback „Auf YouTube öffnen“.  

• Nutzeraktionen: ▶︎ Abspielen, ☆ Speichern, ↗︎ Teilen; „Weiter ansehen“.  

• **Pillar-Tagging eingeführt (Training, Ernährung/Biohacking, Sleep/Mind, Beauty, Longevity).**



**UX/Produkt**



• Karten: Thumbnail, Phase-Badge („Luteal-freundlich“), Dauer, Kategorie/Pillar-Badge, Mini-Takeaway (≤ 90 Zeichen), CTAs (▶︎/☆/↗︎).  

• Player:  

  - Erst Consent-Overlay  

  - Accept lädt IFrame (`youtube-nocookie`), Decline zeigt „Auf YouTube öffnen“  

  - darunter Tags/Phase-Scores, Pillar-Badges, ähnliche Videos, Speichern/Teilen.  

• „Weiter ansehen“: Reihe (Videos mit ≥ 20 s Watch, nicht fertig).



**DB/Schema (Supabase; public read; owner RLS für Events/Consent)**



• `channel(...)`  

• `video(..., pillar enum('training','nutrition_biohacking','sleep_mind','beauty','longevity'), language, ...)`  

• `video_phase(video_id, phase, score)`  

• `video_tags(video_id, tag)`  



• `user_event(user_id, video_id, event_type, ts, meta)`  



• `consent_logs(user_id, video_id, decision, ts, ua_hash, ip_hash, client_version, locale)` ← Retention 12 Monate



**Ranking v1**



```text
score = 0.40*phase_match
      + 0.20*recency_decay
      + 0.15*editorial
      + 0.10*popularity
      + 0.10*affinity
      − 0.05*diversity_penalty
(Phase-Match und Ziele/Interessen nutzen Pillar- & Phase-Information.)

CMP/Consent (App)

• Overlay VOR IFrame-Load; Long/Short DE/EN; Widerruf jederzeit; Retention 12 Monate.

• Decline → Deep Link „Auf YouTube öffnen“; Accept → IFrame laden.

Events (mindestens)

• stream_impression, card_open,

• video_consent_accepted, video_consent_declined,

• video_play_started, video_play_25, video_play_50, video_play_95,

• video_like, video_save, video_share, video_resume

Seed/Import

• 30–50 kuratierte „Evergreen“-Videos (Training, Ernährung, Sleep/Mind, erste Beauty-/Longevity-Basics) + ~20 Kanäle (DACH-lastig, aber EN erlaubt); Daily5-Bias auf < 10–12 min.

QA/DoD

• No-Ad-Interference; IFrame-UI unberührt.

• Widget: stream_feed_renders, consent_overlay_flow, player_screen_lifecycle

• Unit: ranking_test, consent_logs_repo_test

• Performance: Scroll-Jank < 1 %; Player-Start P95 < 1.2 s nach Consent.

• Neu (AI/Video): Langfuse-Trace für 1 FeedQuery + 1 PlayFlow im PR verlinkt (Kosten/Latenz notiert).

Flags

• enable_stream_v1, enable_player_iframe

S2.5 — Robustheit & Copy: Dead-Link-Monitoring + Alternativen + CMP A/B

Goal

• Wöchentlicher Status-Check (gelöscht/privat/embeddable) + UI-Fallbacks; CMP-Copy A/B (klar vs. ausführlich).

S3 — Observability & Performance-Gates

Goal

• Sentry (Crash) + PostHog (Analytics) aktiv; Standard-Dashboards; Render-Budgets enforced.

• Langfuse-Dashboards + Alerting für /api/ai/*.

Dashboards

• Stream-Funnel (impression → open → play → 25/50/95), Consent-Funnel, Save/Share, Feed→Coach-Teaser-Clicks, Performance.

• Langfuse-Board „Search/Playlist“ (Kosten + Latenz + Fehlerquote).

DoD

• Crashfree (Beta) ≥ 99 %; P95-Ziele erreicht; 2–3 Dashboards verlinkt.

• Langfuse-Board verlinkt + 1 Alert (Kosten-Spike oder Latenz-Spike).

S4 — Stream-Polish: Home-Hero „Heute in deiner Phase“, Daily5, Save/Playlist, sanfte Pushes

Goal

• Home wird zum echten Daily-Companion: Hero „Heute in deiner Phase“, Daily5, „Weiter ansehen“, Save/Playlist, erste sanfte Pushes (Reminder auf Programme / neue Inhalte).

S4.5 — Streak-Regeln (final)

Goal

• Streak-Logik finalisieren und im UI sichtbar machen.

UX/Produkt

• Einfache Anzeige auf Home („Du warst X Tage in Folge mit LUVI aktiv“).

• Streak zählt, wenn Nutzerin pro Tag mindestens eine „aktive“ Aktion macht (z. B. Video > 20 s schauen oder Programmschritt abschließen).

Tech

• Streak-Berechnung server- oder clientseitig (mit Supabase-Events / user_event-Tabelle).

• EdgeCases: Zeitzonen, „Late-Night“-Nutzung, Pausen.

S5 — IAP/Paywall (RevenueCat) + erstes Coach-Programm + Coach-Preview

Goal

• Monetarisierung aktivieren (IAP-Abo) + mindestens ein echtes Eigenprogramm launchen; Coach-Tab zeigt Preview weiterer Programme.

UX/Produkt

• Paywall-Screen (nach Trial oder Zugriff auf Premium-Programm):

Vorteile von Premium (Programme, Deep Dives, KI-Suche)

Preis (Monat/Jahr) + 7-Tage-Trial

• Coach-Tab:

mindestens 1 voll nutzbares Programm (z. B. „Cycle-Smart Strength – 4 Wochen“)

weitere Programme als Vorschau-Karten („Coming soon") mit Beschreibung.

Tech

• RevenueCat-Integration (iOS zuerst):

Produkte (Monthly/Yearly), Trial 7 Tage

Entitlement-Check im Client (isPremium)

Restore Purchases / Aboverwaltung

• Programm-Modell in Supabase (vereinfachte Struktur):

program(id, title, goal, duration_weeks, sessions_per_week, is_premium, is_active)

program_day(program_id, week, day, main_video_id, secondary_video_ids[], notes)

• UI-Bindung:

Coach-Screen liest Programme, rendert Grid/Listen

Start/Resume-Logik für aktives Programm

einfache Progress-Anzeige (z. B. „Woche X/Y, Tag A/B“)

Events

• paywall_viewed, trial_started, subscription_activated, subscription_cancelled,

• program_started, program_day_completed, program_completed.

Flags

• enable_iap_v1, enable_coach_v1

S6 — KI-Suche & KI-Playlists v1 (Premium)

Goal

• „Frag LUVI …“: semantische Suche über eigene Metadaten; Ergebnisse + Playlist speichern.

Tech

• pgvector (Supabase) für Embeddings (Video-Titel, Beschreibung, Tags, Pillar, ggf. Phase-Scores).

• Edge Function /search (EU), stateless; RateLimits; optional Caching (Upstash).

• Integration mit Langfuse (Traces pro Query).

Events

• search_initiated, search_results_shown, search_result_clicked, playlist_created

DoD

• P95 Suche < 700 ms; Relevanz SmokeTest (10 Queries).

• Langfuse-Traces pro Query-Typ (z. B. 3 Musterprompts) + Kosten/Latenz-Notiz im PR.

S7 — Store-Readiness & Submission (iOS zuerst)

Goal

• App ist Store-ready (iOS); minimale Marketing-Assets stehen; Beta getestet.

Post-MVP (nach Release)

• Android-Release

• Erweiterte Programme (Menopause, Postpartum etc.)

• Tieferer Ausbau von Beauty & Longevity (mehr Playlists, Serien)

• Creator-/Expert*innen-Programme mit Revenue-Share (wenn Traffic & Brand stabil)

• Newsletter (Brevo DOI) und einfache Lifecycle-Kampagnen

• HealthKit/Wearables (Oura/Apple Health/etc.) – nur nach separatem Research & Legal-Check

• Corporate-Wellness / B2B (optional, sehr langfristig)

Screens & Routen (MVP)

• SplashScreen, WelcomeScreen, ConsentScreen, AuthScreen, OnboardingFlow, HomeScreen, StreamScreen, PlayerScreen, CoachScreen, ProfileScreen

Teststrategie & Gates

• Pro Feature ≥ 1 Unit + ≥ 1 Widget (Gold Standard).

• CI: analyze/test; Privacy-Gate bei DB-Touches; Vercel Preview /api/health = 200 (Soft Gate vor Merge).

• Sentry/PostHog Smoke in Beta; Crashfree ≥ 99 % vor Store.

• Golden Tests für UI-Stabilität (Badges, Karten, Overlays).

• Für AI-Features Link auf Langfuse-Trace im PR.
