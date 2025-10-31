# LUVI Roadmap v3.3 (Codex-ready, MVP-fokussiert)

## Konstanten für alle Sprints
- **DoD:** CI grün (`flutter analyze`, `flutter test`) mit ≥1 Unit + ≥1 Widget je Story; RLS owner-based; kein `service_role` im Client; DSGVO-Review pro datenrelevantem Task (Owner: RLS owner + Compliance Reviewer; Checklist: [docs/compliance/dsgvo_checklist.md](../compliance/dsgvo_checklist.md) deckt PII, Identifiers, Retention, Consent, Third-Party Sharing ab; Sign-off: alle Pflichtpunkte bestätigt, Owner- & Compliance-Initialen dokumentiert, optionale Automations (z. B. Lint/Scanner) verlinkt) vor Merge; CodeRabbit grün; `/api/health = 200` (Timeout 5 s, Retry 3× mit Backoff 1 s/3 s/9 s, Polling alle 5 min). Response-Payload laut Spezifikation:
  ```json
  {
    "status": "ok",
    "checkedAt": "2024-01-01T12:00:00Z",
    "services": {
      "supabase_db": "ok",
      "supabase_auth": "ok",
      "analytics_pipeline": "ok",
      "revenuecat_proxy": "ok",
      "external_apis": "ok"
    }
  }
  ```
  Details → `docs/platform/healthcheck.md`.
- **Zentral:**
  - Flags → `lib/core/config/feature_flags.dart` (Getter aus `--dart-define`).
  - Events → `lib/core/analytics/analytics.dart` mit `track(name, props)`; S0 nutzt Debug-Provider → in S3 auf PostHog umhängen.
  - Governance → `context/debug/memory.md` nach jedem Sprint aktualisieren; fasst Memory-Profiling-Ergebnisse, Incidents, Gegenmaßnahmen mit Owner & Datum sowie offene Follow-ups als Sprint-Audit zusammen.
- **Home→Workout Navigation (fix):** Taps auf „Workout/Mobility/Cardio der Woche“ öffnen `/workout/program/:id` → ProgramScreen → ExerciseScreen.

---

## S0 — FTUE-Backend E2E (Splash → Welcome → Consent → Auth → Onboarding → Dashboard)

**Outcome (DoD / Must-Have)**
- Consent persistiert mit serverseitig gesetztem `user_id`/`ts`; Event `consent_accepted`.
- Onboarding speichert Zyklusdaten (Upsert + Retry); Event `onboarding_completed`.
- Dashboard liest echte User-/Zyklusdaten (kein Fixture).
- Legal: `PRIVACY_URL`/`TERMS_URL` funktionieren; Fallback-Viewer lädt gebündelte Markdown aus `assets/legal/*.md` (Version = Build-Git-Tag, History via Git); siehe `docs/adr/legal_viewer.md` für Spezifikation zu Speicherort, Versionierung, Fallback-Error-Banner + Sentry-Breadcrumb, CI-Smoketest deckt lokale Fallback-Pfade ab.

**Scope (Must-Haves)**
- `lib/features/consent/screens/consent_02_screen.dart`: CTA → `ConsentService.accept(ConsentPayload)`.
- `lib/features/consent/state/consent_service.dart`: Client sendet `ConsentPayload` ohne `user_id`; Server extrahiert `user_id = auth.uid()` und setzt `ts = now()` beim POST auf `/functions/v1/log_consent`, um Spoofing zu verhindern. Fehler/Retry.
- `supabase/functions/log_consent/index.ts`: `user_id = auth.uid()`, `ts = now()`; Audit-Insert.
- `lib/features/screens/onboarding_04|05|06.dart`: am Abschluss `SupabaseService.upsertCycleData(CycleInput)`; Offline-Draft in `lib/features/onboarding/state/cycle_draft.dart` (persistiert via `SharedPreferences` für Konsistenz mit bestehendem `UserStateService`, geringe Latenz, keine zusätzlichen Crypto-Anforderungen für die temporären Daten).
- `lib/features/screens/heute_screen.dart`: reale Daten + (optional) Debug-Badge „Zyklusdaten aktiv“.
- `lib/core/config/app_links.dart`: `--dart-define` erzwingen; Fallback `lib/features/legal/legal_viewer.dart` (Markdown-Render, nutzt gebündelte Dateien aus `assets/legal/`, Offline-Cache siehe `docs/adr/legal_viewer.md`, UI zeigt Versionshinweis + Fehlerbanner falls Remote-Download fehlschlägt).
- Zentraldateien anlegen/verwenden: `feature_flags.dart`, `analytics.dart`.

**Nice-to-Have (nicht gating)**
- Debug-Badge „Zyklusdaten aktiv“.
- Kleine Toasts für Persist-Erfolg/Fallback.

**Tests**
- Unit: `consent_service_test.dart` (Payload/Fehler), `cycle_upsert_test.dart`.
- Widget: `onboarding_persists_flow_test.dart`.

**Events (mindestens)**  
`consent_accepted`, `onboarding_completed`.

**Backout Flags**  
`enable_ftue_backend=false`, `enable_consent_v1=false`.

---

## S1 — Cycle-Logik & Home-Bindung (M4-Teil 1)

**Outcome (DoD / Must-Have)**
- Phasenberechnung deterministisch; Home/Week-Strip zeigt korrekte Phase aus Persistenz.
- Events `cycle_input_completed`, `home_phase_rendered` aktiv (`home_phase_rendered` feuert einmal beim initialen Home-Lade und erneut ausschließlich bei einem tatsächlichen Phasenwechsel).
- Leistung: `computeCycleInfo` P95 ≤ 50 ms.

**Scope (Must-Haves)**
- Contract: `docs/contracts/compute_cycle_info.md` (Inputs/Outputs/Edge-Cases + Grenzwerte Harmonisierung).
- Implementation:
  - Variante A (empfohlen): `compute_cycle_info.dart` nutzt intern bestehende `CycleInfo`.
  - Variante B: Logik aus `CycleInfo` „heben“ und nur dort pflegen.
- Home-Bindung: `lib/features/screens/heute_screen.dart` lädt Zyklus aus DB → `computeCycleInfo` → Badge/Week-Strip.
- Analytics: `home_phase_rendered` dedupliziert pro `phase_id` innerhalb von 30 s, debounce 500–1000 ms bzw. throttle auf ≤1 Event / s; Retry auf Fehler (kein Spam).

**Nice-to-Have**
- Visual tests (golden) für Badges/Colors.

**Tests**
- Unit: Tabellen-Tests inkl. Offsets/Clamps.
- Widget: `home_phase_badge_test.dart`.

**Backout Flag**  
`enable_onboarding_core=false` → statisches Badge.

---

## S2 — Workout v1 (Program → Exercise → Video) + leichter Offline-Cache (M4-Teil 2)

**Outcome (DoD / Must-Have)**
- Home-Tiles navigieren zu echten Programmen; Exercises zeigen Videos (Stream); lokale Resume-Position (verschlüsselt, mit optionalem Cloud-Sync laut [ADR-0006](../../context/ADR/0006-offline-resume-sync.md)); Metadaten offlinefähig.

**Scope (Must-Haves)**
- Supabase-Schema (+RLS public-read):
  - `workout_programs(id, title, category, level, duration_min, is_premium)`
  - `workout_days(id, program_id, day_index, title)`
  - `workout_exercises(id, day_id, seq, title, sets, reps, time_sec, video_path, thumb_path)`
  - RLS: `SELECT USING (true)`; Mutationen nur Backoffice/Service.
- Navigation (fix):
  - `lib/features/home/widgets/weekly_tiles.dart`: Tap → `/workout/program/:id`.
  - (Router-Refactor nicht hier.)
- Screens:
  - ProgramScreen: lädt Program + Days; Resume-Button (`progress_store`) zeigt zuletzt bekannten Stand + „90 Tage ohne Aktivität → reset“ Hinweis.
  - ExerciseScreen: Start/Pause/Weiter; Persist schreibt inkrementelle Fortschritte über `lib/features/workout/state/progress_store.dart` (Pause/Exit → Sync-Trigger).
- Progress Storage & Sync (siehe [ADR-0006](../../context/ADR/0006-offline-resume-sync.md)):
  - Speichert Resume-Position lokal verschlüsselt (z. B. `sqflite_sqlcipher`/`sqlcipher_flutter_libs`) mit Key aus Secure Storage; anonyme Nutzer bleiben lokal-only.
  - Signed-in Clients laden beim Pause/Exit ein `resume_snapshot` (timestamped) hoch; Server resolved „latest timestamp wins“ und liefert Cross-Device-Resume.
  - Retention: TTL 90 Tage Inaktivität → auto-expire (sofern Nutzer nicht explizit pinned); Cleanup-Job räumt Server-Seite, Client löscht beim Fetch.
- Video Delivery (EU, signierte URLs):
  - `api/videos/sign.ts` (Vercel): nutzt Service-Key als Secret; gibt `{signedUrl}` (TTL ~1 h).
  - Client nutzt `video_player`; Autopause beim Navigieren; Resume timestamp.
- Offline-Cache (leicht):
  - Backend: `sqflite` (Android/iOS) bzw. `sqlite3` FFI (Desktop) für strukturierte Workout-Metadaten, `flutter_cache_manager` File-Store für Thumbs (je Plattform `path_provider`-AppDir), Web fällt auf IndexedDB zurück.
  - Invalidation: TTL 24 h pro Item + serverseitige `content_version` erzwingt Invalidate, Admin-Endpoint `/functions/v1/cache_reset` triggert forced refresh.
  - Storage-Limits: Max 5 MB Metadata + 50 MB Thumbs pro User; LRU-Eviction, bei Überschreitung kompletter Clear + Rehydrate.
  - Sync & Fehler: Background-Sync alle 12 h (Foreground Trigger bei App-Start), Netzwerkfehler → exponentielles Retry (30 s → 5 min → 30 min, max 5 Versuche) und UI-Badge „Offline-Daten veraltet“ bis Erfolg; Persistente Fehler führen zu telemetriertem `offline_cache_error`.

**Nice-to-Have**
- Pre-warm signed URL beim Program-Open; HLS-Tunings.

**Tests**
- Unit: `progress_store_test.dart` (Persistenz + TTL), `video_sign_client_test.dart`.
- Integration: Sign-In Sync & Conflict-Resolution (`resume_snapshot` latest wins).
- Widget: `program_open_render_test.dart` (≤300 ms), `exercise_flow_test.dart`.

**Events (mindestens)**  
`home_tile_clicked`, `workout_opened`, `exercise_started`, `exercise_video_played`, `workout_completed`.

**Backout Flags**  
`enable_workout_v1`, `enable_exercise_video_v1`.

**S2.5 (optional, 2–3 Tage)**  
`lib/core/router/app_router.dart` einführen (reiner Umzug), um Routing zu vereinheitlichen vor S3/Paywall.

---

## S3 — Observability & Perf-Gate (Pflicht vor LUVI/Paywall/Store)

**Outcome (DoD / Must-Have)**
- Sentry aktiv, PostHog aktiv, Perf-Gate schützt Home/Program Render.
- Crash-free (Dev/Beta) ≥ 99 %; Kern-Funnels sichtbar.

**Scope (Must-Haves)**
- `main.dart`: Sentry init (Release = `git describe --tags --always` fallback auf Build-Number, Env ∈ {`dev`, `beta`, `prod`}, Dist mappt auf Distribution (`app_store`, `google_play`, `firebase_internal`)); CI injiziert `--dart-define` für `SENTRY_RELEASE`, `SENTRY_ENV`, `SENTRY_DIST` und verifiziert via Crash-Smoke. Beispiel:
  ```dart
  await SentryFlutter.init(
    (opts) {
      opts.release = const String.fromEnvironment('SENTRY_RELEASE');
      opts.environment = const String.fromEnvironment('SENTRY_ENV');
      opts.dist = const String.fromEnvironment('SENTRY_DIST');
    },
  );
  ```
- `lib/core/analytics/analytics.dart`: Provider von Debug auf PostHog umhängen; Dashboards FTUE, Workout Adoption, Crashes.
- Perf-Tests (golden/perf) → CI Gate.

**Backout**  
- DSN/Keys per Flag deaktivierbar.

---

## S4 — LUVI Sync v1 (wöchentliches Journal – ohne KI)

**Outcome (DoD / Must-Have)**
- Wochen-Journal (Mood/Energy/Note) + Historie läuft; DSGVO Export/Löschpfad dokumentiert.

**Scope (Must-Haves)**
- DB & RLS: `journal_entries` (unique `(user_id, week_start)`; owner policies).
- UI/Flows: Weekly Prompt-Card (wenn leer), Liste/Detail, Edit/Delete; `week_start` persistiert als UTC-ISO-Datum, abgeleitet aus lokalem Nutzer-Montag 00:00, zusätzlich speichern wir `user_timezone` (IANA String) für reproduzierbare Queries; Wert bleibt unverändert bei späteren Zeitzonenwechseln, DST-Shifts werden durch die ursprüngliche lokale Datumsableitung abgedeckt; Migration schreibt ggf. fehlende Timezones nach.
- Events: `journal_entry_saved`, `journal_viewed`.

**Nice-to-Have**
- „Empty State“ Animation.

**Tests**
- Unit: ISO-Woche; Widget: Create/Edit/List.

**Backout**  
`enable_luvi_sync_v1=false`.

*Hinweis:* KI-Zusammenfassung kommt später serverseitig (kompatibel zu diesem Schema).

---

## S5 — Paywall vor Store (RevenueCat/IAP + 7-Tage-Trial)

**Outcome (DoD / Must-Have)**
- Trial → Abo funktioniert; Premium-Gates aktivierbar; Telemetrie sauber.

**Scope (Must-Haves)**
- RevenueCat: Products/Offerings/Entitlements; Trial 7 d.
- Client Paywall-Screen: RevenueCat-Statusmaschine
  - States: `loading` (App ruft RevenueCat), `eligible`, `trial_active`, `subscribed`, `expired` (Trial beendet ohne Upgrade), `error`.
  - Transitions: Initial → `loading` → (`eligible` | `trial_active` | `subscribed`) bei Erfolg; `loading` → `error` bei Netzwerk-/RevenueCat-Fehler; `trial_active` → `expired` nach Ablauf; `expired` → `eligible` nach neuem Offer/Renewal; `error` → `loading` bei User-Retry oder Auto-Retry (max 3 Versuche, Backoff 5 s/15 s/30 s).
  - UI/UX: `loading` zeigt Blocking-Spinner + Retry-CTA nach 3 s; `eligible` präsentiert Primary-CTA + Feature-Liste; `trial_active` zeigt Restlaufzeit + Manage-Billing CTA; `subscribed` bestätigt aktives Abo + Link zu verwalteten Features; `expired` sperrt Premium-Features, zeigt Reaktivierungsbanner; `error` zeigt Inline-Error mit Retry + Support-Link, loggt Telemetrie `paywall_load_failed`.
- Gating: `workout_programs.is_premium = true` (und optional LUVI-Extras).
- Billing-Fallback & Restore:
  - Outage-UX: Bestehende Entitlements bleiben aktiv; neue Käufe deaktiviert, UI zeigt Banner „Billing vorübergehend nicht verfügbar“ und blendet Paywall CTA aus.
  - Dauer & Ende: Wiederholte RevenueCat-Pings alle 5 min (max 24 h) oder App-Restart; Erfolg führt zu sofortigem Status-Refresh.
  - Restore: Automatischer Retry der `restorePurchases` API beim App-Start + wenn Outage endet; UI enthält manuelle „Käufe wiederherstellen“-Action nach 2 fehlgeschlagenen Auto-Retries; Erfolg/Fehlschlag mit Toast + Audit-Log (`billing_restore_event`).
  - Notifications: In-App Banner + optional E-Mail/Webhook informieren über Outage-Ende und Statusänderungen; Audit-Trail in Supabase `billing_events`.
- Events: `paywall_viewed`, `trial_started`, `purchase_success`, `entitlement_active`.
- Flag: `enable_premium`.

**Tests**
- Unit: Entitlement-Resolver; Widget: `paywall_flow_test.dart`; E2E: `paywall_purchase_e2e_test.dart` (Trial→Purchase→Restore, simulierte Billing-Ausfälle).

---

## S6 — Store-Readiness & Submission (iOS zuerst)

**Outcome (DoD / Must-Have)**
- Review bestanden; KPI-Dashboard live.

**Scope (Must-Haves)**
- Recht: AGB/PP final + In-App-Viewer/Deeplinks; App Privacy korrekt.
- Assets: Screenshots, Icon, Beschreibung; Videorechte (Sora2/Veo3.5) dokumentiert.
- Release-Gates: Crash-free ≥ 99 %, Funnels grün, Perf-Gate grün.

---

## Post-MVP (Reihenfolge nach Release)

### S7 – Health Baseline „Pulse“ (read-only: HR/Steps/HRV, kleine Permissions, Sync < 5 s)
- **Outcome:** Health Dashboard zeigt HR/Steps/HRV < 5 s nach Sync, Permission-Denied-Fallback erklärt Nutzer-Action, letzte erfolgreiche Sync-Zeit sichtbar.
- **Scope:** HealthKit/Google Fit Pull mit retry + exponential backoff, DSGVO/Retention (90 Tage Rolling Cache + Delete on Sign-Out), Permission-Dialog + Recovery-Flow wenn HealthKit ausfällt.
- **Tests/Acceptance:** Unit-Tests für Adapter/TTL, Integrationstest für Permission-Grant/Deny + Retry, Smoke-Test für Sync-Recovery falls HealthKit API 50x liefert.
- **Events/Risks:** `health_sync_started`, `health_sync_failed`, Monitoring auf iOS Background Task Timeout; Risiken: iOS 17 Permission-Regression, DSGVO Audit auf HR/PII.
- **Backout Flags:** `enable_health_pulse` (Feature toggle + Dashboard Section).

### S8 – Nutrition (MVP) → Rezepte/Einkaufsliste
- **Outcome:** Nutzer können Wochenplan zusammenstellen, Einkaufsliste exportieren, Allergene klar gekennzeichnet.
- **Scope:** Rezept-Datenbank + Tagging, Einkaufsliste Aggregation ohne Payment, API-Integration zu Content Provider mit Rate-Limit.
- **Tests/Acceptance:** Unit-Tests für Rezeptfilter & Portions-Rechner, Integrationstest für Einkaufsliste Export (PDF/ShareSheet), Accessibility-Check (VoiceOver).
- **Events/Risks:** `nutrition_recipe_saved`, `nutrition_grocery_exported`, Monitoring für API 429; Risiken: Copyright/PII in Rezept-Kommentaren.
- **Backout Flags:** `enable_nutrition_mvp`.

### S9 – Regeneration & Mind (MVP) → Empfehlungen, „Quiet Hours“
- **Outcome:** Nutzer sehen personalisierte Regenerationspläne + Mindfulness Tipps, Quiet Hours blockieren Pushes zuverlässig.
- **Scope:** Recommendation-Service (on-device rules + remote fallback), Quiet-Hours Scheduler mit OS Alarms, Consent Handling für Mindfulness Content.
- **Tests/Acceptance:** Unit-Tests für Recommendation-Regeln, Integration für Quiet-Hours (start/end edge cases), UX-Review auf Notification Copy.
- **Events/Risks:** `regen_plan_viewed`, `mind_session_started`, Alert für Scheduler Drift; Risiken: Nutzerüberlastung, DSGVO (sensitiv Stress-Level).
- **Backout Flags:** `enable_regen_mind`.

### S10 – Calendar (MVP) → Monats/Agenda, Cycle-Overlay, DST-Tests
- **Outcome:** Monats- und Agenda-View zeigen Cycle-Overlay korrekt, DST-Übergänge bleiben konsistent, Sync < 1 s.
- **Scope:** Calendar Data Layer, ICS Export, DST Regression Suite, Multi-device conflict resolution (timestamp merge).
- **Tests/Acceptance:** Unit-Tests für Date Math (DST ±1 h), Golden Tests für Overlay, Integrationstest ICS Export.
- **Events/Risks:** `calendar_view_opened`, `calendar_event_created`, Monitoring für Sync Errors; Risiken: Locale-Formate, DST regressions.
- **Backout Flags:** `enable_calendar_mvp`.

### S11 – Statistics → 3–4 Charts + nightly job (≥ 98 %)
- **Outcome:** Nutzer sehen vier Kernmetriken (Cycle-Regularität, Schlaf, Steps, Stimmung) mit 98 % nächtlicher Job-Erfolgsquote.
- **Scope:** Nightly Aggregation Job, Chart Rendering mit empty-state fallback, Export/Share as PNG.
- **Tests/Acceptance:** Unit-Tests für Aggregations (edge cases), Integrationstest Nightly Job Retry, Golden Chart Snapshot.
- **Events/Risks:** `stats_chart_viewed`, `stats_exported`, Monitoring Cron failure rate; Risiken: Data Drift, P99 Render > 200 ms.
- **Backout Flags:** `enable_statistics_v1`.

### S12 – Newsletter (Brevo DOI) → Webhooks + Audit
- **Outcome:** Double-Opt-In Journeys laufen Ende-zu-Ende, Audit-Log fängt DOI + Unsubscribe Ereignisse mit Timestamp.
- **Scope:** Brevo API Integration, Webhook Receiver + Retry, Consent Storage (PII minimal).
- **Tests/Acceptance:** Unit-Tests für Opt-In Token Signatur, Integrationstest Webhook Replay, Compliance-Check (docs/compliance/dsgvo_checklist.md).
- **Events/Risks:** `newsletter_opt_in_started`, `newsletter_unsubscribed`, Monitoring für Webhook 5xx; Risiken: Spam-Complaints, Retention-Policy Verstoß.
- **Backout Flags:** `enable_newsletter_brevo`.

### S13 – AI Premium → Gateway/Prompts/Rate-Limits (5/min, 100/Tag), PII-Redaction
- **Outcome:** Premium-Nutzer erhalten AI-Antworten mit PII-Redaction, Rate-Limits strikt enforced, Audit-Log vorhanden.
- **Scope:** AI Gateway mit Prompt Templates, Rate-Limiter (5/min, 100/Tag), Redaction Pipeline + Prompt Sanitizer.
- **Tests/Acceptance:** Unit-Tests für Prompt Tokens + Redaction, Load-Test Rate-Limiter, Security Review (Prompt Injection scenarios).
- **Events/Risks:** `ai_prompt_sent`, `ai_limit_reached`, Monitoring auf LLM Timeout; Risiken: Halluzination, PII-Leak.
- **Backout Flags:** `enable_ai_premium`.

### S14 – Community & Wearables
- **Outcome:** Communities liefern moderierte Threads, Wearable Sync (Garmin, Oura) aggregiert Daten in < 10 min.
- **Scope:** Community Moderation Tools (flag/report), Wearable OAuth connectors, Data Normalization Layer.
- **Tests/Acceptance:** Unit-Tests für Moderation Rules, Integrationstests OAuth + Sync, Load-Test 100 parallel threads.
- **Events/Risks:** `community_post_created`, `wearable_sync_failed`, Monitoring für Toxicity Score; Risiken: Moderation Backlog, API Quotas.
- **Backout Flags:** `enable_community_wearables`.

---

## Events & Flags (einheitlich)

**Minimal-Funnel ab S0 (kritisch)**  
- Stage 1 – Consent Completed (`consent_accepted`, kritisch): Ziel ≥ 95 % der Sessions; Alert wenn < 80 % oder Drop > 20 % WoW.
- Stage 2 – Onboarding Completed (`onboarding_completed`, kritisch): Ziel ≥ 85 %; Alert wenn < 70 % oder Drop > 15 % WoW.
- Stage 3 – Cycle Setup Verified (`cycle_input_completed` gefolgt von `home_phase_rendered`, beide kritisch): Ziel ≥ 80 %, Alert wenn `home_phase_rendered` < 65 % oder Gap > 10 pp zwischen Events.
- Stage 4 – Workout Engagement (`home_tile_clicked` → `workout_opened`, kritisch): Ziel ≥ 50 % Klick → Open; Alert wenn Conversion < 35 % oder Drop > 15 % WoW.
- Stage 5 – Workout Completion (`exercise_started` → `exercise_video_played` → `workout_completed`, kritisch): Ziel ≥ 30 % Completion; Alert wenn < 20 % oder Drop > 10 % WoW.
- Stage 6 – Paywall Journey (`paywall_viewed`, `trial_started`, `purchase_success`, `entitlement_active`, kritisch für Paid): Ziel ≥ 60 % View→Trial, ≥ 40 % Trial→Purchase, Alert bei Abfall > 15 % je Schritt.

**Begleit-Events (optional, beobachten)**  
- `journal_entry_saved`, `journal_viewed` (Ziel ≥ 25 % Wöchentlich aktiv; Alert wenn < 15 %).

Vor S3 ist `docs/analytics/funnels.md` zu erstellen (Stages, Metriken, Alert-Rules, Ownership, Query-Beispiele); ab PostHog-GoLive automatisierte Alerting-Integrationen (PagerDuty/Slack) setzen.

**Flags**  
`enable_ftue_backend`, `enable_consent_v1`, `enable_onboarding_core`,  
`enable_workout_v1`, `enable_exercise_video_v1`,  
`enable_luvi_sync_v1`, `enable_premium`,
`enable_health_pulse`, `enable_nutrition_mvp`, `enable_regen_mind`,
`enable_calendar_mvp`, `enable_statistics_v1`, `enable_newsletter_brevo`,
`enable_ai_premium`, `enable_community_wearables`.

Lifecycle: Flags erhalten bei stabiler Ausrollung das Label „deprecated“ in `feature_flags.dart` + Roadmap; verantwortliches Team plant Removal innerhalb von 2 Releases, setzt Abschalt-Datum + Owner im Sprint-Backlog und entfernt Telemetrie/Docs nach erfolgreichem Cleanup.

---

## 72-h Plan (unverändert, jetzt mit Anti-Spoofing & Legal-Fallback)

- **Tag 1:** Consent E2E (`CTA → Service → Edge Fn` setzt `user_id`/`ts`), `PRIVACY_URL`/`TERMS_URL` + Markdown-Viewer (Assets `assets/legal/*.md`, Offline-Fallback gemäß `docs/adr/legal_viewer.md`), `feature_flags.dart` & `analytics.dart`.
- **Tag 2:** Onboarding Upsert + Offline-Draft + Widget-Test; Event `onboarding_completed`.
- **Tag 3:** `compute_cycle_info` (Adapter auf `CycleInfo`), Unit-Tests, Home-Badge-Bindung; Events `cycle_input_completed`, `home_phase_rendered`; `/api/health`; Codex/CodeRabbit.
