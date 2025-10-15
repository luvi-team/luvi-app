# Roadmap Ultra-Slim

## Globale Invarianten
- Tests/QA: mind. 1 Unit + 1 Widget (featurebezogen), DevTools-Perf-Check bei UI, Sentry aktiv, DSGVO-Checkliste gepflegt.
- Daten/DSGVO: RLS owner-based, kein service_role im Client, Consent-Log (ts, version, scopes), Audit-Trail via Edge Function.
- DoD (immer): Feature nutzbar, Tests grün, Logs sichtbar, ADR/Docs aktualisiert.
- Code-Qualität: flutter_lints aktiv; DCM non-blocking; CodeRabbit-Reviews bei PRs.
- CI/CD: Flutter-Version im Workflow gepinnt auf 3.35.4 (Dart 3.9.0).

## Meilensteine (Kurz)
- M0 Fundament: Repo/CI, iOS-Sim, Supabase init, Privacy-Ordner. ✅
- M1 Multi-Agent: Agenten-Dossiers, BMAD/PRP-Schablonen, DoD im Repo. ✅
- M2 Modellierung: Flows, ERD (users/consents/cycle/daily_plan/…), RLS-Matrix, Consent-Texte v1. ✅
- M3 Auth & Consent: Supabase Auth, granularer Consent, Volltext AGB/PP, log_consent. ✅
- M4 Core MVP: Cycle-Input → computeCycleInfo → Workout-Card (Phasen, Kategorien, Symptom-Anpassung, Offline-Cache).
  - DoD: Offline cache hit-rate ≥95 %, Workout-Card renders in ≤200 ms on mid-tier device, PostHog `cycle_input_completed` fired.
  - Backout: Remote flag `allow_onboarding_core` disables computeCycleInfo + Workout-Card without app update.
- M4.5 Health Baseline (neu): Health-Integrationen (Apple Health / Google Fit) – Puls/Schritte/HRV als Basis.
  - DoD: HealthKit/Google Fit Permission Flow getestet; Daily Sync <5 s/User; DataScope minimal (HR/Steps/Sleep Summary); encrypted-at-rest; RLS aktiv.
  - Abhängigkeit: Voraussetzung für M8 (Regeneration & Mind).
- M5 AI Premium: Gateway (Routing, Caching, Limits), AI-Consent, 3 Workout-Prompts.
  - DoD: Gateway rate limit 5 req/min + 100 req/day pro User, 20 s timeout, retries capped auf 1.
  - Safeguards: PII-Redaction + prompt logging per SSOT v1.1 §AI, circuit breaker + safeguarding plan referenziert in ADR-0003/AI-Gateway.
- M6 Paywall: RevenueCat/IAP, Trial, Entitlements, Feature-Gates.
  - DoD: Purchase smoke-tests iOS/Android (Sandbox), entitlement sync in  <1 min, fallback Paywall-Screen bei Billing-Ausfall.
  - Backout: Feature gate `enable_premium` + RevenueCat product freeze plan dokumentiert.
- M7 Nutrition: Pref-Onboarding, phasenbasierte Rezepte/Varianten, Einkaufsliste teilen, Basis-Tracking.
  - DoD: Recipe API latency <500 ms P95, dietary consent recorded, share flow emits analytik-event `nutrition_list_shared`.
  - Data: Nutrition storage encrypted-at-rest, deletion path verified.
- M8 Regeneration & Mind: Empfehlungen, Journaling, Mini-Scheduler → Calendar.
  - DoD: Journal sync <15 s, recommendation model opt-out via consent scope, background reminders respect platform quiet hours.
  - Backout: Toggle `enable_regen_mind` hides entrypoints; journaling data export tested.
- M9 Beta & Analytics: PostHog EU Events, TestFlight/Play, Crash-Budget, Feedback-Loop.
  - DoD: Crash-free sessions ≥99 %, beta cohort flagged in Supabase, feedback form writes to `feedback_entries` with audit trail.
  - Release Gate: Exit criteria for S9→S10 documented (crash budget met, feedback backlog triaged, telemetry dashboards green).
- M10 Calendar: Monats/Agenda, Cycle-Overlay, Events/Termine/Symptom-Logs + CRUD, lokale Reminders.
  - DoD: Timezone normalization incl. DST unit tests, iOS background fetch fallback push scheduling documented, Android Doze mitigation (`AlarmManager` + `WorkManager`) validated.
  - Notifications: Permission UX copy localized, recurrence limited zu iCal RRULE Daily/Weekly, failsafe queue drains <5 min.
- M11 Statistics: 3–4 Kerncharts, nightly metrics.
  - DoD: Nightly job success ≥98 %, chart data window integrity checks, metrics export validated vs. sample dataset.
  - Backout: Metrics feature flag + migration rollback plan (Supabase function `stats_refresh`) captured.
- M12 Newsletter: Brevo Double-Opt-In, Sync via Webhook, Logging.
  - DoD: Opt-in latency <10 s, consent proof stored, webhook retries exponential backoff, audit log visible in Ops dashboard.
  - Compliance: Brevo API key rotation SOP + PI redaction verified.
- M13+ Post-MVP: Community & Wearables.

## Sprints (2-Wochen)
S0 Fundament • S1 Multi-Agent • S2 Modellierung • S3 Auth/Consent • S4 Core MVP • S4.5 Health • S5 AI • S6 Paywall • S7 Nutrition • S8 Mind • S9 Beta/Analytics • S10 Calendar • S11 Statistics • S12 Newsletter • S13+ Community/Wearables

**Sprint Capacity & Gates**
- Kapazität: 18 SP je Sprint (3 FTE * 6 SP) + 15 % Riskbuffer.
- Release-Gates: S4→S5 (Onboarding funnel ≥90 % completion), S9→S10 (Crash budget + telemetry met), S10→S11 (Calendar DST tests green).
