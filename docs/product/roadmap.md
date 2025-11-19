# LUVI Roadmap 

KONSTANTEN (für ALLE Sprints – unverändert aus deinen Standards)
• DoD: CI grün (flutter analyze, flutter test) mit ≥1 Unit + ≥1 Widget je Story; DSGVO-Review pro datenrelevantem Task; ADRs gepflegt; CodeRabbit grün; /api/health = 200.
• Datenschutz & Architektur: Supabase EU (RLS owner-based), kein service_role im Client; Vercel Edge fra1 als Gateway (transient, PII-redacted Logging), EU-Only.
• Governance & Workflow: Traycer + BMAD (vor Code), Prove (Self-Check + DSGVO) nach Code; Branch-Protection inkl. Vercel Preview Health 200.
• Feature-Flags: lib/core/config/feature_flags.dart (—dart-define); alle Features per Flag gatebar.
• Events: lib/core/analytics/analytics.dart → S0 Debug, ab S3 auf PostHog EU umschalten.
• Repo-Struktur: features/* (data/domain/state/widgets), core/*, services/supabase_service.dart, tests/goldens spiegeln Features.
• Perf-Ziele (Default): Screen-Wechsel First-Frame < 400 ms (P95); Listen-Frame-Drops < 1 %; Player-Start < 1.2 s (P95) nach Consent.

--------------------------------------------------------------------

S0 — FTUE E2E (Splash → Welcome → Consent → Auth → Onboarding → Home) + Pivot-Vorbereitung
Goal
• Erster Start mit echten Daten; Consent & Onboarding persistiert; Home zeigt reale Zyklusphase.
• Pivot-Vorbereitung: Consent-Text erweitert um „Externe Inhalte (YouTube)“; Onboarding sammelt Content-Präferenzen (Kategorien, Sprache).

UX/Produkt
• Consent-Screen: zusätzlicher Abschnitt „Externe Inhalte (YouTube)“ (Info), Link zur Datenschutzerklärung (Viewer vorhanden).
• Onboarding: Zyklus-Eckdaten wie gehabt + Präferenzen (Kategorien: Workout, Ernährung & Biohacking, Regeneration & Achtsamkeit, Beauty/Lifestyle; Sprache DE/EN).
• Home: Platzhalter-Reihe „Für deine Phase heute“ (statisch 3–5 Karten) bis S2 live ist.

Tech
• Edge Fn /functions/log_consent (Audit Insert); Client: ConsentService.accept(payload).
• Supabase upsertCycleData(); Offline-Draft bei schlechter Verbindung.
• Links PRIVACY_URL/TERMS_URL funktional bzw. lokaler Markdown-Viewer.

Events
• consent_accepted, onboarding_completed, home_phase_rendered

Flags
• allow_ftue_backend, enable_consent_v1

--------------------------------------------------------------------

S1 — Zyklus-Logik & Home-Bindung (deterministisch)
Goal
• Korrekte Phasenberechnung (Menstruation/Follikel/Ovulation/Luteal) + Home-Badge/Week-Strip; compute P95 ≤ 50 ms.

UX/Produkt
• Home: Phase-Badge + kurzer „Heute“-Satz (z. B. „Luteal (Tag 5) – Fokus auf Regeneration“).

Tech
• SSOT: docs/contracts/compute_cycle_info.md (Inputs/Outputs, Offsets/Clamps/Edge-Cases).
• compute_cycle_info.dart → Home bindet DB → compute → render.

Events/Tests
• cycle_input_completed, home_phase_rendered
• Tabellen-Tests (Edge-Cases), Widget-Goldens; P95 50 ms.

Flag/Backout
• allow_onboarding_core=false → statisches Badge

--------------------------------------------------------------------

S2 — STREAM v1 (Pivot-Kern): Feed + Player (YouTube IFrame) + CMP (Consent-Overlay) + Speichern/Teilen + „Weiter ansehen“
Goal
• Neuer Tab „Stream“ (ersetzt LUVI Sync). Endlos-Feed, phasen-priorisiert, mit offiziellem YouTube-Player.
• Consent-Overlay vor IFrame-Load (Long beim ersten Play, danach Short; DE/EN); Logging + Fallback „Auf YouTube öffnen“.
• Nutzeraktionen: ▶︎ Abspielen, ☆ Speichern (Watchlist/Playlist-Basis), ↗︎ Teilen; „Weiter ansehen“ (Resume).

UX/Produkt
• Karten: Thumbnail, Phase-Badge („Luteal-freundlich“), Dauer, Kategorie, Mini-Takeaway (≤ 90 Zeichen), CTAs (▶︎/☆/↗︎).
• Player: Erst Consent-Overlay → Accept lädt IFrame (youtube-nocookie), Decline zeigt „Auf YouTube öffnen“; darunter Tags/Phase-Scores, ähnliche Videos, Speichern/Teilen.
• „Weiter ansehen“: horizontale Reihe (Videos mit ≥ 20 s Watch, nicht fertig).

DB/Schema (Supabase; public read; owner RLS für Events/Consent)
• channel(id, name, yt_channel_id, lang, quality_score)
• video(id, yt_video_id, channel_id, title, description, duration_sec, lang, category, created_at)
• video_phase(video_id, menstrual FLOAT, follicular FLOAT, ovulatory FLOAT, luteal FLOAT)
• video_tags(video_id, tag)
• user_event(user_id, video_id, event_type ENUM('open','play','resume','like','save','share'), ts, props JSONB)
• consent_logs(user_id, video_id, decision ENUM('accept','decline'), ts, ua_hash, ip_hash, client_version, locale)  ← Retention 12 Monate

GDPR/Privacy (consent_logs)
• Legal basis (final): Art. 6(1)(f) DSGVO (berechtigte Interessen: Auditierbarkeit, Betrugs-/Missbrauchsprävention). Für `consent_logs` wird aktuell nicht auf Art. 6(1)(c) gestützt. Referenz: `docs/privacy/privacy.md` (Abschnitt „Consent‑Logs und Audit“).
• Data minimisation: store only `user_id`, `video_id`, `decision`, `ts`, `locale`, app `client_version`, and hashed identifiers (`ua_hash`, `ip_hash`). Do not store raw IPs or UAs.
• Hashing controls (final): `ip_hash`/`ua_hash` via HMAC‑SHA256 with server‑managed pepper. Rotation cadence: quartalsweise (alle 90 Tage). Emergency rotation: sofortige Pepper‑Erneuerung, Invalidierung der Alt‑Pepper, Backfill/Rehash „on write“ + opportunistisch bei Lesezugriffen; Details/Runbook: `docs/privacy/hmac_hashing_controls.md`.
• Identifiability risk: linkage risk across `user_id`/`ts`/`locale` with hashed identifiers assessed as „low“ with HMAC + RLS + rate limiting. Short risk memo: `docs/privacy/consent_logs_risk_memo.md`.
• Necessity justification (`ip_hash`): required for audit defensibility (proof‑of‑decision uniqueness and abuse detection), rate limiting, and consent revocation traceability without storing raw IP.
• Retention (final): TTL = 12 Monate. Automatische Löschung via Scheduled Job (pg_cron/Edge Fn) mit täglichem Cleanup; Policy/SQL: `docs/privacy/consent_logs_ttl_policy.md`. Retention im Verzeichnis „Privacy“ dokumentiert (Schedule) und in App‑Einstellungen referenziert.
• Consent revocation flow: UI (Settings → Datenschutz → Consent‑Management) bietet Widerruf so einfach wie Erteilung (Art. 7(3)). Events: `video_consent_shown`, `video_consent_accept`, `video_consent_reject`. DB‑Logik: nur INSERTs (kein DELETE), neuester Eintrag repräsentiert aktuellen Status; bestehende Logs bleiben unverändert (Audit‑Trail). Details: `docs/privacy/consent_revocation_flow.md` und `docs/runbooks/verify-consent-flow.md`.
• RLS policies: owner‑based read of own records; nur ein `audit_role` (service‑seitig) darf cross‑user lesen für Compliance‑Audits; kein Client‑Zugriff auf fremde Datensätze.

Ranking v1
• score = 0.40*phase_match + 0.20*recency_decay + 0.15*editorial + 0.10*popularity + 0.10*affinity − 0.05*diversity_penalty
• phase_match: video_phase vs. user.current_phase (0..1)
• recency_decay: e^(−age_days/14)
• editorial: kuratorische Qualität (0..1)
• popularity: log-normalisierte Views/Like-Rate (Metadaten)
• affinity: aus user_event (save/like/watchtime)
• diversity_penalty: dämpft Wiederholungen (gleiche Kategorie/Creator in kurzer Zeit)

CMP/Consent (App)
• Overlay VOR IFrame-Load; Long (Erstkontakt), Short (Wiederholung). Beide DE/EN. Text benennt „Datenübertragung an Google/YouTube“ und „Cookies/Local Storage“. Widerruf jederzeit; Retention 12 Monate.
• Decline → Deep-Link „Auf YouTube öffnen“; Accept → IFrame laden.

Events (mindestens)
• stream_impression, card_open,
• video_consent_shown, video_consent_accept, video_consent_reject, video_open_youtube_external,
• video_play_start, video_milestone_25_percent, video_milestone_50_percent, video_milestone_95_percent,
• video_like, video_save, video_share, video_resume

Seed/Import
• 30–50 kuratierte „Evergreen"-Videos + 20 Kanäle (DACH-lastig): initialer CSV-Import; Daily-5 (siehe S4) bias auf < 10–12 min.

QA/DoD
• „No-Ad-Interference“ (Player nicht modifizieren, Ads erlaubt), IFrame-UI unberührt.
• Widget-Tests: stream_feed_renders, consent_overlay_flow, player_screen_lifecycle
• Unit: ranking_test, consent_logs_repo_test
• Performance: Scroll-Jank < 1 %; Player-Start P95 < 1.2 s nach Consent.

Flags
• enable_stream_v1, enable_player_iframe

--------------------------------------------------------------------

S2.5 — Robustheit & Copy: Dead-Link Monitoring + Alternativen + CMP-A/B
Goal
• Wöchentlicher Status-Check (gelöscht/privat/embeddable) + UI-Fallbacks; CMP-Copy A/B (klar vs. ausführlich).

Tech
• content_video_health(video_id, status ENUM('active','deleted','private','error'), is_embeddable BOOL, privacy_status TEXT, last_checked TIMESTAMPTZ, check_frequency_days INT).
• Weekly Batch (manuell in S3; optional Cron ab S4): max. 500 Videos/Tag.
• UI-Fallbacks: „❌ Nicht verfügbar – ähnliche Videos“ (2–3 Alternativen gleiche Kategorie/Phase).
• CMP A/B: Overlay-Variante loggen (cmp_variant) und Acceptance-Rate messen.

Events
• video_status_checked, video_status_changed, cmp_variant_impression, cmp_accept

--------------------------------------------------------------------

S3 — Observability & Performance-Gates
Goal
• Sentry (Crash) + PostHog (Analytics) aktiv; Standard-Dashboards; Render-Budgets enforced.

Dashboards
• Stream-Funnel (impression → open → play → 25/50/95),
• Consent-Funnel (shown → accept → play),
• Save/Share,
• Feed→Coach Teaser Clicks,
• Performance (screen render, player start).

DoD
• Crash-free (Beta) ≥ 99 %; P95 Ziele erreicht; 2–3 Dashboards verlinkt.

--------------------------------------------------------------------

S4 — Stream-Polish: Home-Hero „Heute in deiner Phase“, Daily-5, Save/Playlist, sanfte Pushes
Goal
• Home wirkt „täglich“: Hero (Top 3–6) + Daily-5 Kurzimpulse; Watchlist/Playlist; 1×/Tag leiser Push.

Regeln
• Daily-5: 5 „snackable“ Karten (< 10–12 min), min. 1 Achtsamkeit in Luteal/Menstruation, max. 2 pro Kategorie/Tag.

Events
• daily_five_impression, daily_five_card_view, daily_five_card_tap, save_playlist_created, push_daily5_sent, push_opened

--------------------------------------------------------------------

S4.5 — Streak-Regeln (final)
• Tag erfüllt bei: (a) ≥25 % eines Daily-5-Videos ODER (b) ≥50 % eines beliebigen Videos.
• 1 „Freeze“ pro Woche (automatisch), max. 1 Freeze am Stück.
• Reset: wenn 2 Tage in Folge NICHT erfüllt wurden.
• Klarer Tooltip „So zählt dein Tag“.

Events
• streak_day_completed, streak_frozen, streak_reset, continue_watching_impression/click

--------------------------------------------------------------------

S5 — IAP/Paywall (RevenueCat) + Coach-Preview
Goal
• Premium via IAP; Trial **7 Tage** (MVP-Standard). Coach-Tab sichtbar (Preview), Start nur Premium.

UX
• Coach: Programme sichtbar (Woche-1 Vorschau: 2× GK (Ganzkörper/full-body), 1× Mobility, 1× Cardio); Start → Paywall bei no-entitlement.
• Upsells im Feed (Coach-Teaser nach relevanten Plays).
• Paywall Copy: 3 Varianten (Credibility/Community/Compliance), DE/EN.
• Reminder: Day 4 (Wertbeweis), Day 6/7 (Trial-Ende). Restore Purchases in Settings.

Events
• paywall_viewed, trial_started, purchase_success, entitlement_active, coach_teaser_view/click

Flags
• enable_premium, enable_coach_preview

--------------------------------------------------------------------

S6 — KI-Suche & KI-Playlists v1 (Premium)
Goal
• „Frag LUVI …“: semantische Suche über eigene Metadaten (Titel, Kurzbeschreibung, Tags, Phase-Scores); Ergebnisse + Playlist speichern.

Tech
• pgvector (Supabase) für Embeddings; Edge Fn `/search` (EU), stateless; Rate-Limits (z. B. 5/min, 100/Tag). Optional Caching (Upstash).

Events
• search_initiated, search_results_shown, search_result_clicked, playlist_created

DoD
• P95 Suche < 700 ms; Relevanz Smoke-Test (10 Queries).

--------------------------------------------------------------------

S7 — Store-Readiness & Submission (iOS zuerst)
Goal
• Review bestanden; App Privacy korrekt; Mehrwert klar (eigener Feed/Ranking, Playlists, KI, Coach); 4.2 abgesichert.

Deliverables
• Review Notes: Originalfunktionalität (Phase-Scoring/Ranking, Save/Playlists, KI, Coach, Consent-Layer), IAP 3.1.1, YouTube-Compliance, GDPR, Demo-Account.
• Listing: Bullets/Subtitle; Claim zu Creators defensiv („kuratiert aus DACH & global“, keine fixe Zahl).
• Release-Gates: Crash-free ≥ 99 %, Perf grün, Funnels grün, Health 200.

--------------------------------------------------------------------

Post-MVP (nach Release)
• S8 – Pulse/Wearables (read only: HR/Steps/HRV; Apple Health/Google Fit), Sync < 5 s.
• S9 – Sponsored Collections/Creator-Deals (klar gekennzeichnet) + Affiliate (außerhalb Players).
• S10 – Nutrition/Regeneration Module (eigene Cards/Guides).
• S11 – Statistics (3–4 Charts, nightly job).
• S12 – Newsletter (Brevo DOI) mit Webhooks/Audit.
• S13 – Community & erweiterte Wearables.

--------------------------------------------------------------------

Screens & Routen (MVP)
• vorhanden: Splash, Welcome, Consent, Auth, Onboarding, Home (alle angepasst).
• neu: /stream (Feed), /player/:id (Player + CMP), /saved (Gespeichert/Playlists), /coach (Preview), /paywall, /search (Premium).
• Routing via GoRouter; Widgets pro Feature-Paket (features/*).

--------------------------------------------------------------------

Teststrategie & Gates
• Pro Feature ≥ 1 Unit + ≥ 1 Widget (Gold-Standard).
• CI: analyze/test; Privacy-Gate bei DB-Touches; Vercel Preview /api/health = 200 (Soft-Gate vor Merge).
• Sentry/PostHog Smoke in Beta; Crash-free ≥ 99 % vor Store.
• Golden Tests für UI-Stabilität (Badges, Karten, Overlays).

--------------------------------------------------------------------

KPIs (MVP)
• North Star: Watch-Time/DAU (phase-angepasst) ODER D7-Retention im Stream.
• Inputs: CTR Home-Hero, Daily-5 Completion, Save-/Share-Rate, Feed→Coach-Click, Trial→Paid %, Play→95 % Completion.

--------------------------------------------------------------------

72-H PLAN (angepasst)
Tag 1: Consent-Flow ergänzen (Externe Inhalte Hinweis), feature_flags.dart & analytics.dart final; Health 200; Home „Heute“-Placeholder.
Tag 2: Supabase Tabellen: channel, video, video_phase, video_tags, user_event, consent_logs; Seed Import (30–50 Videos); Stream-List & Karten.
Tag 3: IFrame + CMP-Overlays (Long/Short, DE/EN inkl. „Cookies/Local Storage\"); Player-Screen; Events play/25/50/95; „Weiter ansehen\" Basis.
