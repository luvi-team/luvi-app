# LUVI Release-Checkliste (Staging → Prod) — SSOT Gate Fix (Consent/Onboarding)

## Ziel
Sicheres, fail-safe Release des SSOT-Gate-Fixes:
- **Server-SSOT:** `public.profiles` ist Wahrheit für Gate-Felder
  - `accepted_consent_version`, `accepted_consent_at`
  - `has_seen_welcome`
  - `has_completed_onboarding`, `onboarding_completed_at`
- **Client-Cache:** `SharedPreferences/UserStateService` ist **nur Cache** und **account-scoped** (kein Cross-Account Leak).

---

## A) Release Ablauf (exakt, Schritt für Schritt)

### 0) Preconditions (5–10 min)
1. **Branch/Commit fixieren** (Tag/Release-Branch), nur SSOT-Gate Fix + DB-Migrations.
2. **CI grün** (mindestens): `scripts/flutter_codex.sh analyze` + relevante Tests.
3. **Project Refs prüfen**: staging und prod müssen **unterschiedliche** `SUPABASE_PROJECT_REF`s haben.

### 1) Secrets Rotation (dev/staging/prod) (15–30 min)
> **Wichtig:** Bei Offenlegung von Zugangsdaten (z.B. in Chats, Logs oder Commits) ist eine Rotation der betroffenen Zugangsdaten Pflicht.

Für **jede** Umgebung (dev, staging, prod) rotieren:
1. **Postgres DB Password** (Supabase → Settings → Database).
2. **Service Role Key** (falls irgendwo für server-side Tests/Jobs genutzt; niemals im Client).
3. **Edge Function Secrets** (falls gesetzt):
   - `CONSENT_METRIC_SALT`, `CONSENT_HASH_PEPPER`
   - `CONSENT_ALERT_WEBHOOK_URL`, `CONSENT_ALERT_SAMPLE_RATE`
   - `CONSENT_RATE_LIMIT_*`
4. **Client Keys**:
   - `SUPABASE_ANON_KEY` ist publishable, aber bei Leak trotzdem rotieren (Operational Hygiene).
5. **Update lokale Env-Files** (nur lokal, git-ignored):
   - `.env.staging.local`
   - `.env.production.local`
   - (optional) `.env.local` für dev

**Pass/Fail:** Kein Secret wird in Git committed; App/Functions nutzen die neuen Werte ohne Ausfall.

### 2) DB Migration Push + Smoke (staging) (10–20 min)

> **Security Note:** Never source untrusted env files directly. Use key-value parsing instead.

1. Dry-run:
   - Load env: `set -a; source .env.staging.local; set +a`
   - Run: `scripts/db_dry_run.sh`
2. Apply + Smoke:
   - `scripts/db_push_and_smoke.sh .env.staging.local`

**Pass/Fail:** Migrations “up to date” oder applied ohne Errors; `rls_smoke.sql` + `rls_smoke_negative.sql` grün.

### 3) App Manual Tests (staging) — A/B Accounts + Cross-Device (25–45 min)
> Ziel: Account-Scope Cache, SSOT Reads/Writes, und Fail-Safety verifizieren.

**Setup:** 2 echte Test-Accounts (A, B) + 2 Devices (Device1, Device2).

#### Flow 1 — Account A (Device1)
1. Frischer App-Start (ggf. App neu installieren).
2. Login Account A.
3. Welcome W1–W5 bis `/consent/02` (Routing stabil).
4. Consent akzeptieren (C2/C3 je nach Flow): danach muss Onboarding starten.
5. Onboarding komplett → Erfolgsscreen → Home.

**Erwartung:** Consent/Onboarding Gate werden serverseitig gesetzt; keine Endlosschleife bei Save.

#### Flow 2 — Cross-Device (Account A auf Device2)
1. Login Account A auf Device2.
2. Erwartung: **kein** erneutes Consent/Onboarding, direkt Home (oder minimal Splash).

**Erwartung:** Server-SSOT wirkt cross-device; kein “nur lokal” Gate.

#### Flow 3 — Cross-Account Leak Check (Account B auf Device1)
1. Sign out Account A.
2. Login Account B auf Device1.
3. Erwartung: B sieht **nicht** den Gate-State von A (kein “Welcome schon gesehen”, kein “Consent Version gesetzt”, kein “Onboarding complete”).

**Erwartung:** Cache ist user-scoped/cleared; Gates folgen server profile von B.

#### Flow 4 — Fail-Safety (Network / Remote Fetch fail)
1. Device1: Flugmodus an (oder Netzwerk blocken).
2. App starten (eingeloggt oder frisch nach Login).
3. Erwartung: **kein** Home-BYPASS bei unknown remote state; Splash zeigt Unknown UI / Retry.

**Erwartung:** “Unknown” ist fail-safe.

### 4) Prod DB Migration Push + Smoke (10–20 min)
1. Dry-run:
   - `set -a; source .env.production.local; set +a`
   - `scripts/db_dry_run.sh`
2. Apply + Smoke:
   - `scripts/db_push_and_smoke.sh .env.production.local`

### 5) Prod Deployment (Mobile App) (Varies)
1. Release build signieren und deployen (App Store / Play).
2. **Post-release sanity**: 1–2 reale Logins und Gate-Checks (siehe Manual Tests light).

---

## B) 10 wichtigste Pass/Fail Kriterien (Alltagssprache)
1. **Kein Secret in Git**: `.env.local`/Passwörter/Keys sind nicht committenbar und nicht in History.
2. **Consent wird nur nach echtem “Akzeptieren” gespeichert**: Kein Server-Gate ohne `log_consent` Erfolg.
3. **Account A beeinflusst Account B nicht**: Nach Logout/Login darf kein Gate-State “mitwandern”.
4. **Cross-device funktioniert**: Account A auf Device2 wird korrekt als “done” erkannt (serverseitig).
5. **Onboarding speichert atomar**: Wenn irgendetwas beim Save failt, wird “completed” nicht gesetzt.
6. **Unknown bleibt sicher**: Bei kaputtem Netzwerk gibt es keinen direkten Sprung nach Home.
7. **RLS/Grants dicht**: `anon` hat keine Table-Privileges auf sensitive tables.
8. **accepted_consent_at ist serverseitig**: keine Client-Zeit als Wahrheit.
9. **Smoke-SQL ist grün**: beide Scripts laufen ohne Handarbeit durch.
10. **Rollback möglich**: DB Trigger/Migrations lassen sich sauber zurücknehmen.

---

## C) Minimale SQL Queries zur Verifikation (prod-safe)
> Run als DB-Admin (z. B. `postgres`) via `psql` gegen die jeweilige Umgebung. Aggregiert, ohne PII-Export.

### 1) accepted_consent_at Trigger vorhanden
```sql
select
  tgname,
  pg_get_triggerdef(t.oid) as def
from pg_trigger t
join pg_class c on c.oid = t.tgrelid
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relname = 'profiles'
  and tgname = 'set_profiles_accepted_consent_at';
```

### 2) Gate-Felder: Plausibilitäts-Counts (keine PII)
```sql
select
  count(*) as profiles_total,
  count(*) filter (where accepted_consent_version is null) as consent_version_null,
  count(*) filter (where accepted_consent_version is not null and accepted_consent_at is null) as consent_at_missing_despite_version,
  count(*) filter (where has_completed_onboarding and onboarding_completed_at is null) as onboarding_at_missing_despite_completed,
  count(*) filter (where has_completed_onboarding and birth_date is null) as invalid_completed_missing_birthdate
from public.profiles;
```

### 3) RLS/Grants: anon darf nichts sehen/truncaten
```sql
select
  has_table_privilege('anon', 'public.profiles', 'select') as anon_profiles_select,
  has_table_privilege('anon', 'public.profiles', 'truncate') as anon_profiles_truncate,
  has_table_privilege('anon', 'public.consents', 'select') as anon_consents_select,
  has_table_privilege('anon', 'public.consents', 'truncate') as anon_consents_truncate,
  has_table_privilege('anon', 'public.cycle_data', 'select') as anon_cycle_select,
  has_table_privilege('anon', 'public.cycle_data', 'truncate') as anon_cycle_truncate,
  has_table_privilege('anon', 'public.email_preferences', 'select') as anon_emailprefs_select,
  has_table_privilege('anon', 'public.email_preferences', 'truncate') as anon_emailprefs_truncate;
```

### 4) Optional: default privileges drift check (Ops)
```sql
select
  defaclrole::regrole as role,
  defaclnamespace::regnamespace as schema,
  defaclobjtype,
  defaclacl
from pg_default_acl
where defaclnamespace = (select oid from pg_namespace where nspname='public')
  and defaclobjtype = 'r';
```

---

## D) Rollback Plan (DB + App)

### DB Rollback (10–20 min)
1. Trigger entfernen (nur falls nötig):
```sql
drop trigger if exists set_profiles_accepted_consent_at on public.profiles;
drop function if exists public.set_profiles_accepted_consent_at();
```
2. Revert Grants/Constraints nur gezielt (siehe):
   - `docs/privacy/reviews/20251222_db_drift_hardening.md`

### App Rollback (Varies)
1. Mobile Rollback auf vorherigen Store Release (App Store/Play).
2. Bei aktivem Rollback: Monitoring hochdrehen (Consent/Onboarding Support Tickets, Crash rate).

---

## E) 3 größte Restrisiken + MVP Monitoring (Logging/Alerts)

1) **Default-ACL Drift** (neue Tabellen bekommen wieder zu breite Grants)
   - Beobachtung: `pg_default_acl` Query (oben) bei jedem DB-Change checken.
   - Mitigation: Default-Privileges periodic audit + CI/Runbook Step.

2) **Fail-safe UX Impact** (remote nicht erreichbar → Unknown UI)
   - Beobachtung: App-Logs/Crashlytics zählen “unknown state” Events (ohne PII), Support Tickets.
   - Mitigation: klare Retry UX + “Connectivity hint” im Banner; server availability alerting.

3) **Consent Event Pipeline** (`log_consent` Edge Function / rate limiting / errors)
   - Beobachtung: Supabase Function Logs + optional `CONSENT_ALERT_WEBHOOK_URL`.
   - Mitigation: Alert-Sampling (`CONSENT_ALERT_SAMPLE_RATE`), Rate-Limit Parameter prüfen, On-call Playbook.

---

## Owner / Dauer / Risiko
| Schritt | Owner | Dauer | Risiko |
|---|---:|---:|---|
| Secrets Rotation (dev/staging/prod) | Release/Infra | 15–30 min | Hoch (wenn vergessen) |
| DB Dry-run + Push + Smokes (staging) | Backend/DB | 10–20 min | Mittel |
| Manual Tests A/B + Cross-Device (staging) | QA | 25–45 min | Hoch (fängt SSOT/Cache-Leaks) |
| DB Dry-run + Push + Smokes (prod) | Backend/DB | 10–20 min | Hoch |
| Mobile Deployment | Release | Variiert | Hoch |
| Post-release sanity + Monitoring | QA/Release | 15–30 min | Mittel |

