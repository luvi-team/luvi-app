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

- CI-Pipeline: `flutter test` ✅
- Migration dry-run: `supabase db push --dry-run` ✅
- RLS Smoke Tests: `supabase/tests/rls_smoke.sql` ✅
- Negative Tests: `supabase/tests/rls_smoke_negative.sql` ✅

## Rollback Plan

```sql
-- WARNUNG: Nur im Notfall anwenden, in umgekehrter Reihenfolge!

-- 1) 20251227192000 - Revert zu vorheriger Funktionsversion
-- (Funktion aus vorherigem Backup wiederherstellen)

-- 2) 20251227180000 - Trigger auf UPDATE OF accepted_consent_version zurücksetzen
DROP TRIGGER IF EXISTS set_profiles_accepted_consent_at ON public.profiles;
CREATE TRIGGER set_profiles_accepted_consent_at
  BEFORE INSERT OR UPDATE OF accepted_consent_version
  ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.set_profiles_accepted_consent_at();

-- 3) 20251227141500 - service_role Zugriff wiederherstellen (NICHT EMPFOHLEN)
GRANT EXECUTE ON FUNCTION public.log_consent_if_allowed(uuid, text, jsonb, integer, integer) TO service_role;

-- 4) 20251226191139 - auth.uid() Check entfernen (NICHT EMPFOHLEN)
-- Funktion aus vorherigem Backup wiederherstellen

-- 5) 20251223180000 - NOT NULL entfernen
ALTER TABLE public.cycle_data ALTER COLUMN age DROP NOT NULL;

-- 6) 20251222174000-20251222173000 - Scopes Constraint entfernen
ALTER TABLE public.consents DROP CONSTRAINT IF EXISTS consents_scopes_is_object_bool;
-- Legacy Array-Format wieder erlauben (NICHT EMPFOHLEN)

-- 7) 20251222131000 - Trigger entfernen
DROP TRIGGER IF EXISTS set_profiles_accepted_consent_at ON public.profiles;
DROP FUNCTION IF EXISTS public.set_profiles_accepted_consent_at();
```

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
