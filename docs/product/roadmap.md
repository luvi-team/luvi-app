# Roadmap Ultra-Slim

## Globale Invarianten
- Tests/QA: mind. 1 Unit + 1 Widget (featurebezogen), DevTools-Perf-Check bei UI, Sentry aktiv, DSGVO-Checkliste gepflegt.
- Daten/DSGVO: RLS owner-based, kein service_role im Client, Consent-Log (ts, version, scopes), Audit-Trail via Edge Function.
- DoD (immer): Feature nutzbar, Tests grün, Logs sichtbar, ADR/Docs aktualisiert.
- Code-Qualität: flutter_lints aktiv; DCM non-blocking; CodeRabbit-Reviews bei PRs.
- CI/CD: Flutter-Version im Workflow gepinnt auf 3.35.2 (Dart 3.9.0).

## Meilensteine (Kurz)
- M0 Fundament: Repo/CI, iOS-Sim, Supabase init, Privacy-Ordner. ✅
- M1 Multi-Agent: Agenten-Dossiers, BMAD/PRP-Schablonen, DoD im Repo. ✅
- M2 Modellierung: Flows, ERD (users/consents/cycle/daily_plan/…), RLS-Matrix, Consent-Texte v1. ✅
- M3 Auth & Consent: Supabase Auth, granularer Consent, Volltext AGB/PP, log_consent. ✅
- M4 Core MVP: Cycle-Input → computeCycleInfo → Workout-Card (Phasen, Kategorien, Symptom-Anpassung, Offline-Cache).
- M5 AI Premium: Gateway (Routing, Caching, Limits), AI-Consent, 3 Workout-Prompts.
- M6 Paywall: RevenueCat/IAP, Trial, Entitlements, Feature-Gates.
- M7 Nutrition: Pref-Onboarding, phasenbasierte Rezepte/Varianten, Einkaufsliste teilen, Basis-Tracking.
- M8 Regeneration & Mind: Empfehlungen, Journaling, Mini-Scheduler → Calendar.
- M9 Beta & Analytics: PostHog EU Events, TestFlight/Play, Crash-Budget, Feedback-Loop.
- M10 Calendar: Monats/Agenda, Cycle-Overlay, Events/Termine/Symptom-Logs + CRUD, lokale Reminders.
- M11 Statistics: 3–4 Kerncharts, nightly metrics.
- M12 Newsletter: Brevo Double-Opt-In, Sync via Webhook, Logging.
- M13+ Post-MVP: Community & Wearables.

## Sprints (2-Wochen)
S0 Fundament • S1 Multi-Agent • S2 Modellierung • S3 Auth/Consent • S4 Core MVP • S5 AI • S6 Paywall • S7 Nutrition • S8 Mind • S9 Beta/Analytics • S10 Calendar • S11 Statistics • S12 Newsletter • S13+ Community/Wearables

