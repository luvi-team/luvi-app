# LUVI Roadmap v3.3 (Codex-ready, MVP-fokussiert)

## Konstanten für alle Sprints
- **DoD:** CI grün (`flutter analyze`, `flutter test`) mit ≥1 Unit + ≥1 Widget je Story; RLS owner-based; kein `service_role` im Client; DSGVO-Review pro datenrelevantem Task; CodeRabbit grün; `/api/health = 200`.
- **Zentral:**
  - Flags → `lib/core/config/feature_flags.dart` (Getter aus `--dart-define`).
  - Events → `lib/core/analytics/analytics.dart` mit `track(name, props)`; S0 nutzt Debug-Provider → in S3 auf PostHog umhängen.
  - Governance → `context/debug/memory.md` nach jedem Sprint aktualisieren.
- **Home→Workout Navigation (fix):** Taps auf „Workout/Mobility/Cardio der Woche“ öffnen `/workout/program/:id` → ProgramScreen → ExerciseScreen.

---

## S0 — FTUE-Backend E2E (Splash → Welcome → Consent → Auth → Onboarding → Dashboard)

**Outcome (DoD / Must-Have)**
- Consent persistiert mit serverseitig gesetztem `user_id`/`ts`; Event `consent_accepted`.
- Onboarding speichert Zyklusdaten (Upsert + Retry); Event `onboarding_completed`.
- Dashboard liest echte User-/Zyklusdaten (kein Fixture).
- Legal: `PRIVACY_URL`/`TERMS_URL` funktionieren oder Fallback-Viewer rendert lokale `.md`.

**Scope (Must-Haves)**
- `lib/features/consent/screens/consent_02_screen.dart`: CTA → `ConsentService.accept(ConsentPayload)`.
- `lib/features/consent/state/consent_service.dart`: POST `/functions/v1/log_consent` ohne `user_id`; Fehler/Retry.
- `supabase/functions/log_consent/index.ts`: `user_id = auth.uid()`, `ts = now()`; Audit-Insert.
- `lib/features/screens/onboarding_04|05|06.dart`: am Abschluss `SupabaseService.upsertCycleData(CycleInput)`; Offline-Draft in `lib/features/onboarding/state/cycle_draft.dart`.
- `lib/features/screens/heute_screen.dart`: reale Daten + (optional) Debug-Badge „Zyklusdaten aktiv“.
- `lib/core/config/app_links.dart`: `--dart-define` erzwingen; Fallback `lib/features/legal/legal_viewer.dart` (Markdown render).
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
`allow_ftue_backend=false`, `enable_consent_v1=false`.

---

## S1 — Cycle-Logik & Home-Bindung (M4-Teil 1)

**Outcome (DoD / Must-Have)**
- Phasenberechnung deterministisch; Home/Week-Strip zeigt korrekte Phase aus Persistenz.
- Events `cycle_input_completed`, `home_phase_rendered` aktiv.
- Leistung: `computeCycleInfo` P95 ≤ 50 ms.

**Scope (Must-Haves)**
- Contract: `docs/contracts/compute_cycle_info.md` (Inputs/Outputs/Edge-Cases + Grenzwerte Harmonisierung).
- Implementation:
  - Variante A (empfohlen): `compute_cycle_info.dart` nutzt intern bestehende `CycleInfo`.
  - Variante B: Logik aus `CycleInfo` „heben“ und nur dort pflegen.
- Home-Bindung: `lib/features/screens/heute_screen.dart` lädt Zyklus aus DB → `computeCycleInfo` → Badge/Week-Strip.
- Events emitten.

**Nice-to-Have**
- Visual tests (golden) für Badges/Colors.

**Tests**
- Unit: Tabellen-Tests inkl. Offsets/Clamps.
- Widget: `home_phase_badge_test.dart`.

**Backout Flag**  
`allow_onboarding_core=false` → statisches Badge.

---

## S2 — Workout v1 (Program → Exercise → Video) + leichter Offline-Cache (M4-Teil 2)

**Outcome (DoD / Must-Have)**
- Home-Tiles navigieren zu echten Programmen; Exercises zeigen Videos (Stream); lokale Resume-Position; Metadaten offlinefähig.

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
  - ProgramScreen: lädt Program + Days; Resume-Button (`progress_store`).
  - ExerciseScreen: Start/Pause/Weiter; lokaler Fortschritt `lib/features/workout/state/progress_store.dart`.
- Video Delivery (EU, signierte URLs):
  - `api/videos/sign.ts` (Vercel): nutzt Service-Key als Secret; gibt `{signedUrl}` (TTL ~1 h).
  - Client nutzt `video_player`; Autopause beim Navigieren; Resume timestamp.
- Offline-Cache (leicht): Metadaten + Thumbs lokal (kein Offline-Video in v1).

**Nice-to-Have**
- Pre-warm signed URL beim Program-Open; HLS-Tunings.

**Tests**
- Unit: `progress_store_test.dart`, `video_sign_client_test.dart`.
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
- `main.dart`: Sentry init (Release/Env/Dist). CI-Crash-Smoke.
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
- UI/Flows: Weekly Prompt-Card (wenn leer), Liste/Detail, Edit/Delete; `week_start = ISO-Montag`.
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
- Client Paywall-Screen (States `eligible`, `trial_active`, `subscribed`).
- Gating: `workout_programs.is_premium = true` (und optional LUVI-Extras).
- Fallback bei Billing-Ausfall; Restore-Purchases.
- Events: `paywall_viewed`, `trial_started`, `purchase_success`, `entitlement_active`.
- Flag: `enable_premium`.

**Tests**
- Unit: Entitlement-Resolver; Widget: `paywall_flow_test.dart`.

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
- S7 – Health Baseline „Pulse“ (read-only: HR/Steps/HRV, kleine Permissions, Sync < 5 s).
- S8 – Nutrition (MVP) → Rezepte/Einkaufsliste.
- S9 – Regeneration & Mind (MVP) → Empfehlungen, „Quiet Hours“.
- S10 – Calendar (MVP) → Monats/Agenda, Cycle-Overlay, DST-Tests.
- S11 – Statistics → 3–4 Charts + nightly job (≥ 98 %).
- S12 – Newsletter (Brevo DOI) → Webhooks + Audit.
- S13 – AI Premium → Gateway/Prompts/Rate-Limits (5/min, 100/Tag), PII-Redaction.
- S14 – Community & Wearables.

---

## Events & Flags (einheitlich)

**Events (Minimal-Funnel ab S0)**  
`consent_accepted`, `onboarding_completed`, `cycle_input_completed`, `home_phase_rendered`,  
`home_tile_clicked`, `workout_opened`, `exercise_started`, `exercise_video_played`, `workout_completed`,  
`journal_entry_saved`, `journal_viewed`,  
`paywall_viewed`, `trial_started`, `purchase_success`, `entitlement_active`.

**Flags**  
`allow_ftue_backend`, `enable_consent_v1`, `allow_onboarding_core`,  
`enable_workout_v1`, `enable_exercise_video_v1`,  
`enable_luvi_sync_v1`, `enable_premium`.

---

## 72-h Plan (unverändert, jetzt mit Anti-Spoofing & Legal-Fallback)

- **Tag 1:** Consent E2E (`CTA → Service → Edge Fn` setzt `user_id`/`ts`), `PRIVACY_URL`/`TERMS_URL` + Markdown-Viewer, `feature_flags.dart` & `analytics.dart`.
- **Tag 2:** Onboarding Upsert + Offline-Draft + Widget-Test; Event `onboarding_completed`.
- **Tag 3:** `compute_cycle_info` (Adapter auf `CycleInfo`), Unit-Tests, Home-Badge-Bindung; Events `cycle_input_completed`, `home_phase_rendered`; `/api/health`; Codex/CodeRabbit.
