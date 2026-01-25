# Privacy Review — 2025-12-22 bis 2025-12-27: Consent & Profiles Hardening

## Summary
- **Scope:** 8 Migrations (20251222131000 – 20251227192000)
- **Purpose:** Security Hardening, Data Canonicalization, Audit Integrity
- **Data Impact:** Keine neuen PII-Felder, keine neuen Tabellen

## Change Details

| Migration | Objekt | Beschreibung | Privacy Impact |
|-----------|--------|--------------|----------------|
| 20251222131000 | `profiles` Trigger | Server-side `accepted_consent_at` Timestamp | Audit-Integrität (kein Client-Tampering) |
| 20251222173000 | `consents.scopes` | Array→Object Canonicalization + Backfill | Datenformat-Normalisierung |
| 20251222174000 | `log_consent_if_allowed` | Empty-Check Fix, Scope Validation | Defense-in-Depth |
| 20251223180000 | `cycle_data.age` | NOT NULL Constraint | Datenintegrität |
| 20251226191139 | `log_consent_if_allowed` | `auth.uid()` Check, `service_role` Revoke | Least-Privilege |
| 20251227141500 | `log_consent_if_allowed` | Owner-Guard verstärkt, Scope Normalization | Defense-in-Depth |
| 20251227180000 | `profiles` Trigger | Fires on ALL updates (Backfill-Fähigkeit) | Legacy-Daten-Korrektur |
| 20251227192000 | `log_consent_if_allowed` | Deskriptive Fehlermeldungen für ungültige Keys | Developer Experience |

## Detailed Changes

### Phase 1: Consent Timestamp & Scopes (22.12)

**20251222131000 - profiles_set_accepted_consent_at_server_time**
- Trigger setzt `accepted_consent_at = now()` server-seitig
- Client-Werte werden ignoriert (Audit-Integrität)
- Verhindert Clock-Skew/Tampering

**20251222173000 - consents_scopes_object_bool**
- Backfill: Legacy Array-Format `["terms"]` → Object `{"terms": true}`
- Neue Helper: `consents_scopes_keys_valid()`, `consents_scopes_values_boolean()`
- CHECK Constraint: Nur bekannte Scope-IDs, nur Boolean-Werte
- 6 erlaubte Scopes: `terms`, `health_processing`, `analytics`, `marketing`, `ai_journal`, `model_training`
  - **Hinweis (Intentional):** Die erlaubten Scope-IDs sind in den DB-Migrations/Guards absichtlich explizit (hardcoded), damit Scope-Änderungen **immer** per PR/Migration sichtbar reviewed werden (Governance). SSOT-Drift wird zusätzlich über `config/consent_scopes.json` + CI-Tests (`consent_scopes_ssot.test.ts`) erkannt.

**20251222174000 - fix_log_consent_if_allowed_empty_check**
- Fix: `jsonb_object_length()` nicht verfügbar → `= '{}'::jsonb`
- Scope-Key Validierung mit Fehlerliste

### Phase 2: Datenintegrität (23.12)

**20251223180000 - cycle_data_age_not_null**
- `cycle_data.age` erhält NOT NULL Constraint
- Prerequisite: CHECK (age >= 16 AND age <= 120) bereits vorhanden
- Idempotent: Prüft auf NULL-Werte vor Constraint-Erstellung

### Phase 3: Least-Privilege (26.12)

**20251226191139 - log_consent_auth_uid_check**
- `auth.uid()` muss verfügbar sein (errcode 42501)
- `p_user_id` muss `auth.uid()` entsprechen
- `REVOKE EXECUTE ... FROM service_role`
- `security invoker` (nicht `definer`)

### Phase 4: Defense-in-Depth (27.12)

**20251227141500 - log_consent_patch_harden_owner_guard_and_scopes**
- Defensive Scope-Normalisierung wiederhergestellt
- Owner-Guard verstärkt

**20251227180000 - profiles_accepted_consent_at_trigger_all_updates**
- Trigger feuert bei ALLEN Updates (nicht nur `accepted_consent_version`)
- Ermöglicht Backfill für Legacy-Zeilen mit `accepted_consent_at IS NULL`

**20251227192000 - log_consent_scope_key_validation_errors**
- Validiert Scope-Keys VOR Normalisierung
- Wirft deskriptive Fehler: `p_scopes contains unknown scope IDs: foo, bar`
- Validiert ALLE Keys bei Object-Format (auch `value=false`)

## Data Impact

**Keine neuen personenbezogenen Daten:**
- Keine neuen Tabellen
- Keine neuen Spalten
- Keine neuen PII-Felder
- Reine Sicherheits-Hardening und Datenformat-Normalisierung

## RLS / Access Control

- RLS-Policies unverändert
- `service_role` kann `log_consent_if_allowed` nicht mehr aufrufen
- Alle Consent-Operationen erfordern authentifizierten End-User-Kontext

## Legal Basis & Purpose Limitation (DSGVO)

- **Keine DPIA-Änderung erforderlich**
- Kein neuer Verarbeitungszweck
- Keine Änderung der Rechtsgrundlage (Art. 6 DSGVO)
- Verbesserung der technischen Schutzmaßnahmen (Art. 32 DSGVO)
- Audit-Integrität für Nachweis der Einwilligung (Art. 7 Abs. 1 DSGVO)

## Evidence / Verification

| Check | Result | Artifact | Commit | Verified (UTC) |
|------|--------|----------|--------|----------------|
| CI-Pipeline: `flutter test` | ✅ | https://github.com/luvi-team/luvi-app/actions/runs/21315526645 | `45f409c3249e5af0bfa3aa6b1deaa5924782e0c4` | `2026-01-24T13:03:05Z` |
| Migration dry-run: `supabase db push --dry-run` | ✅ | https://github.com/luvi-team/luvi-app/actions/runs/21315526651 | `45f409c3249e5af0bfa3aa6b1deaa5924782e0c4` | `2026-01-24T13:03:05Z` |
| RLS Smoke Tests: `supabase/tests/rls_smoke.sql` | ✅ | `docs/privacy/evidence/20260124T132313Z_rls_smoke.md` | `45f409c3249e5af0bfa3aa6b1deaa5924782e0c4` | `2026-01-24T13:23:13Z` |
| Negative Tests: `supabase/tests/rls_smoke_negative.sql` | ✅ | `docs/privacy/evidence/20260124T132313Z_rls_smoke.md` | `45f409c3249e5af0bfa3aa6b1deaa5924782e0c4` | `2026-01-24T13:23:13Z` |

## Rollback Plan

**WARNUNG:** Rollback ist grundsätzlich **nicht empfohlen** (Audit-/Least-Privilege-Hardening wird zurückgenommen). Wenn nötig: nur nach Incident-Ticket + expliziter Freigabe (Eng Lead + DPO/Privacy), staging-first, mit Evidenzen.

### Pre-Rollback Validation (Checkliste)
1) **Ist-Zustand prüfen (Schema/Guards aktiv?):**
```sql
-- Trigger auf profiles vorhanden?
select tgname
from pg_trigger
where tgrelid = 'public.profiles'::regclass
  and tgname = 'set_profiles_accepted_consent_at';

-- Scopes-Constraint vorhanden?
select conname
from pg_constraint
where conrelid = 'public.consents'::regclass
  and conname = 'consents_scopes_is_object_bool';

-- cycle_data.age: sind NULLs vorhanden (würden NOT NULL verhindern/wieder erlauben)?
select count(*) as cycle_data_age_nulls
from public.cycle_data
where age is null;
```

2) **Daten-/Backup-Referenzen (konkret):**
- `public.set_profiles_accepted_consent_at()`:
  - aktuelle Version: `supabase/migrations/20251227180000_profiles_accepted_consent_at_trigger_all_updates.sql`
  - frühere Version (UPDATE OF accepted_consent_version): `supabase/migrations/20251222131000_profiles_set_accepted_consent_at_server_time.sql`
- `public.log_consent_if_allowed(...)`:
  - aktuelle Version: `supabase/migrations/20251227192000_log_consent_scope_key_validation_errors.sql`
  - frühere Versionen (in Reihenfolge):  
    `supabase/migrations/20251227141500_log_consent_patch_harden_owner_guard_and_scopes.sql` →  
    `supabase/migrations/20251226191139_log_consent_auth_uid_check.sql` →  
    `supabase/migrations/20251222173000_consents_scopes_object_bool.sql` →  
    (baseline) `supabase/migrations/20251104120000_log_consent_atomic.sql`

### Rollback Steps (in umgekehrter Reihenfolge; staging-first)

#### 1) Revert `public.log_consent_if_allowed(...)` (20251227192000 → vorherige Version)
**Aktion (konkret):**
- Restore-Quelle (empfohlen): `supabase/migrations/20251227141500_log_consent_patch_harden_owner_guard_and_scopes.sql` (enthält `CREATE OR REPLACE FUNCTION public.log_consent_if_allowed(...)`).
- Alternative Restore-Quelle (falls benötigt): `supabase/migrations/20251226191139_log_consent_auth_uid_check.sql`.

**Risiko / Data-loss Assessment:**
- Kein Datenverlust; aber ggf. **weniger hilfreiche Fehlertexte** und schwächeres Developer-Feedback für ungültige Scope-Keys.

#### 2) Profiles-Trigger Scope zurücksetzen (20251227180000 → UPDATE OF accepted_consent_version)
```sql
drop trigger if exists set_profiles_accepted_consent_at on public.profiles;
create trigger set_profiles_accepted_consent_at
  before insert or update of accepted_consent_version
  on public.profiles
  for each row
  execute function public.set_profiles_accepted_consent_at();
```
**Risiko / Data-loss Assessment:**
- Kein Datenverlust; aber Backfill-Fähigkeit sinkt (Rows mit `accepted_consent_at is null` werden nicht mehr bei beliebigen Updates repariert).

#### 3) `service_role` GRANT wiederherstellen (**NICHT EMPFOHLEN**)
**Nur wenn**: Incident/Outage und es existiert ein **zeitlich begrenzter** Support-Workflow ohne Client-Leak (kein `service_role` im Client), DPO-Freigabe liegt vor.
```sql
grant execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) to service_role;
```
**Reversal (Backout des Rollback-Schritts):**
```sql
revoke execute on function public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) from service_role;
```
**Risiko / Data-loss Assessment:**
- Kein Datenverlust, aber **deutlich höhere Missbrauchs-/Bypass-Risiken** (Least-Privilege wird aufgeweicht).

#### 4) `auth.uid()` Guard entfernen (**NICHT EMPFOHLEN**)
**Nur wenn**: Auth-Kontext ist in der Umgebung nachweislich nicht verfügbar (z. B. DB-Client bricht) und es existiert ein freigegebener Übergangsplan.
- Restore-Quelle (vor 20251226191139): `supabase/migrations/20251222173000_consents_scopes_object_bool.sql`

**Risiko / Data-loss Assessment:**
- Kein Datenverlust; aber Owner-Guarantee wird abgeschwächt (ein Teil der Defense-in-Depth entfällt).

#### 5) `cycle_data.age` NOT NULL entfernen (20251223180000)
```sql
alter table public.cycle_data alter column age drop not null;
```
**Risiko / Data-loss Assessment:**
- Kein Datenverlust; aber Datenintegrität sinkt (NULL-Werte werden wieder möglich).

#### 6) Scopes-Constraint entfernen / relaxen (20251222173000)
```sql
alter table public.consents drop constraint if exists consents_scopes_is_object_bool;
```
**Risiko / Data-loss Assessment:**
- Kein Datenverlust; aber Canonicalization/Validation wird geschwächt (unklare JSON-Formate könnten wieder persistiert werden).

#### 7) Profiles-Timestamp Trigger entfernen (20251222131000)
```sql
drop trigger if exists set_profiles_accepted_consent_at on public.profiles;
drop function if exists public.set_profiles_accepted_consent_at();
```
**Risiko / Data-loss Assessment:**
- Kein Datenverlust; aber Audit-Integrität sinkt (Client-Timestamps können wieder durchschlagen).

## Reviewer Notes

- Alle Änderungen sind Security-Hardening ohne neue Datenerfassung
- `service_role` Bypass wurde absichtlich entfernt (Least-Privilege)
- Scope-Canonicalization ist rückwärtskompatibel (Array-Input wird akzeptiert)
- Server-side Timestamps garantieren Audit-Integrität

## Result

✅ 8 Migrations abgedeckt (22.12 – 27.12)
✅ Keine Auswirkung auf personenbezogene Datenverarbeitung
✅ Verbesserung der technischen Schutzmaßnahmen gemäß Art. 32 DSGVO
✅ Audit-Integrität für Einwilligungsnachweis gemäß Art. 7 DSGVO
