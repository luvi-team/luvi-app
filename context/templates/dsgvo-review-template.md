# Privacy Review: [Feature-Name]

**Branch:** [feat/m4-cycle-input]
**PR:** [#123]
**Reviewer:** [Agent-Name oder User]
**Date:** [YYYY-MM-DD]
**DSGVO-Impact:** [Low / Medium / High] — siehe `docs/privacy/dsgvo-impact-levels.md`

---

## 1. Purpose (Zweck)

**Was macht das Feature?** [1-2 Sätze]

**Warum brauchen wir es?** [Business-Grund, User-Story]

**Beispiel (Cycle-Input):**
> User kann Zyklusdaten (Länge, Periodendauer, LMP) eingeben, damit App phasenbasierte Workout-Empfehlungen zeigen kann.

---

## 2. Data Flow (Datenfluss)

**Input → Processing → Output**

```
[User-Aktion]
→ [Screen/Widget]
→ [State (Riverpod)]
→ [Service/API]
→ [DB/Edge Function/Extern]
→ [Response]
→ [UI-Update]
```

**Beispiel (Cycle-Input):**
```
User füllt Cycle-Input-Form aus (cycle_length, period_length, lmp_date)
→ CycleInputScreen
→ cycleInputProvider (Riverpod, Validation)
→ SupabaseService.upsertCycleData()
→ Supabase DB: INSERT INTO cycle_logs (RLS-Policy prüft auth.uid())
→ Response: {success: true, cycle_id: UUID}
→ UI: Navigation zu Dashboard + Snackbar "Zyklus gespeichert"
```

**Externe Datenübermittlung:** [Ja/Nein]
- Falls Ja: Wohin? (z.B. OpenAI EU-Project, Brevo Newsletter-Service)
- Falls Ja: Zweck? (z.B. AI-Workout-Recommendation, Newsletter-Opt-in)
- Falls Ja: DPA/SCCs vorhanden? [Ja/Nein]

---

## 3. PII / Health Data (Personenbezogene Daten)

**Welche Daten werden verarbeitet?**

- [ ] **Keine PII** → DSGVO-Impact = Low
- [ ] **Identifikatoren** (user_id, email, name) → Medium/High
- [ ] **Gesundheitsdaten** (Zyklus, Symptome, Schlaf, HRV) → **High** (DSGVO Art. 9)
- [ ] **Biometrische Daten** (Wearable-Sync, Foto-Logging) → **High** (DSGVO Art. 9)
- [ ] **Andere sensible Daten** (z.B. Ernährungspräferenzen, Journaling) → Medium/High

**Daten-Klassifizierung (Cycle-Input Beispiel):**
- ✅ `user_id` (UUID) — Identifikator (indirekt PII)
- ✅ `cycle_length` (INT) — Gesundheitsdaten (DSGVO Art. 9)
- ✅ `period_length` (INT) — Gesundheitsdaten (DSGVO Art. 9)
- ✅ `lmp_date` (DATE) — Gesundheitsdaten (DSGVO Art. 9)
- ✅ `created_at` (TIMESTAMPTZ) — Technische Metadaten (nicht PII)

**Rechtsgrundlage:**
- [ ] Einwilligung (DSGVO Art. 6 Abs. 1 lit. a) — **Standard für LUVI**
- [ ] Vertragserfüllung (DSGVO Art. 6 Abs. 1 lit. b)
- [ ] Berechtigtes Interesse (DSGVO Art. 6 Abs. 1 lit. f) — **NUR für essenzielle Features**

**Gesonderte Einwilligung (DSGVO Art. 9 Abs. 2 lit. a):**
- [ ] **Ja** — Gesundheitsdaten (explizite Einwilligung erforderlich)
- [ ] Nein — Keine Gesundheitsdaten

---

## 4. Consent (Einwilligung)

**Consent-Scope:** [z.B. "cycle_tracking", "ai_workout_recommendations", "newsletter_subscription"]

**Opt-in Flow:**
```
[Screen/Widget wo Consent erfragt wird]
→ [Toggle/Checkbox + Erklärtexte]
→ [User akzeptiert]
→ [Consent-Log: version, scopes, timestamp]
→ [Feature aktiviert]
```

**Beispiel (Cycle-Input, M4):**
```
Onboarding-Screen 04: "Zyklus-Tracking"
→ Toggle "Zyklus-Daten erfassen" + Erklärtexte ("Wir speichern Länge, Periodendauer, LMP für phasenbasierte Empfehlungen")
→ User aktiviert Toggle
→ Consent-Log: {version: "v1.0", scopes: ["cycle_tracking"], timestamp: 2025-10-03T12:00:00Z}
→ Cycle-Input-Screen wird in Navigation freigeschaltet
```

**Opt-out / Widerruf:**
- [ ] **Jederzeit möglich** (Settings → Consent-Management)
- [ ] **Auswirkungen dokumentiert** (z.B. "Cycle-Tracking deaktiviert → keine Workout-Empfehlungen")
- [ ] **Daten-Löschung** (optional: User kann Daten löschen bei Widerruf)

**Granularität:**
- [ ] **Granular** (User kann einzelne Scopes aktivieren/deaktivieren) — **LUVI-Standard**
- [ ] All-or-Nothing (User akzeptiert alles oder nichts) — **NUR bei essentiellen Features**

---

## 5. RLS / Security (Row-Level Security)

**Tabellen mit PII/Gesundheitsdaten:**

### Tabelle: `cycle_logs`

**RLS Enabled:**
- [ ] `ALTER TABLE cycle_logs ENABLE ROW LEVEL SECURITY;` ✅

**Policies (4×):**
- [ ] **SELECT Policy:** `Users can view own cycle logs` — `USING (user_id = auth.uid())`
- [ ] **INSERT Policy:** `Users can insert own cycle logs` — `WITH CHECK (user_id = auth.uid())`
- [ ] **UPDATE Policy:** `Users can update own cycle logs` — `USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid())`
- [ ] **DELETE Policy:** `Users can delete own cycle logs` — `USING (user_id = auth.uid())`

**Trigger:**
- [ ] `set_user_id_from_auth()` — Auto-setzt `user_id` aus `auth.uid()` bei INSERT

**Service-Role:**
- [ ] **KEIN service_role im Client** ✅ (ADR-0002 Least-Privilege)
- [ ] Service-Role nur in Edge Functions (falls nötig, z.B. Admin-Operationen) — **dokumentiert + begründet**

**Secrets:**
- [ ] **Keine Secrets im Code** (.env*, credentials, API-Keys) ✅
- [ ] Secrets in Supabase Vault oder GitHub Secrets ✅

**Encryption:**
- [ ] **At-Rest:** Supabase-Default (AES-256) ✅
- [ ] **In-Transit:** HTTPS/TLS ✅
- [ ] **Client-Side (optional):** Verschlüsselung vor Upload (z.B. Journaling) — **NUR wenn extra-sensibel**

---

## 6. Evidence (Nachweise)

**RLS-Tests:**

### 1. RLS ON
```bash
psql -h <db-host> -U postgres -d postgres
SELECT relrowsecurity FROM pg_class WHERE relname='cycle_logs';
# Output: t (true) ✅
```

### 2. Policies existieren (4×)
```bash
SELECT policyname FROM pg_policies WHERE tablename='cycle_logs';
# Output:
# Users can view own cycle logs
# Users can insert own cycle logs
# Users can update own cycle logs
# Users can delete own cycle logs
# ✅ 4 Policies
```

### 3. Policies nutzen auth.uid()
```bash
SELECT policyname, qual, with_check FROM pg_policies WHERE tablename='cycle_logs';
# Output prüfen: "user_id = auth.uid()" in qual/with_check ✅
```

### 4. Anon-User Test (denied)
```bash
psql -h <db-host> -U anon -d postgres
SELECT * FROM cycle_logs;
# Output: ERROR: new row violates row-level security policy ✅
```

**Curl-Tests (API/Edge Functions):**
```bash
# Beispiel: Upsert Cycle-Data
curl -X POST https://<project>.supabase.co/rest/v1/cycle_logs \
  -H "apikey: <anon-key>" \
  -H "Authorization: Bearer <user-jwt>" \
  -H "Content-Type: application/json" \
  -d '{"cycle_length": 28, "period_length": 5, "lmp_date": "2025-10-01"}'

# Erwartung: 201 Created + {id: UUID, user_id: <from-jwt>, ...} ✅
```

**Consent-Log Verify:**
```bash
# Prüfen: Consent-Log existiert nach Opt-in
psql -h <db-host> -U postgres -d postgres
SELECT * FROM consent_logs WHERE user_id = '<test-user-id>' ORDER BY created_at DESC LIMIT 1;
# Output: {version: "v1.0", scopes: ["cycle_tracking"], created_at: ...} ✅
```

---

## 7. DSGVO-Impact Summary

**Impact-Level:** [Low / Medium / High]

**Begründung:**
- [Kurze Zusammenfassung: Was macht dieses Feature DSGVO-relevant?]

**Beispiel (Cycle-Input):**
> **High** — Feature schreibt Gesundheitsdaten (cycle_logs: LMP, Länge, Periodendauer) in DB. DSGVO Art. 9 erfordert explizite Einwilligung + strenge Sicherheitsmaßnahmen (RLS, Encryption, Audit-Trail).

**Risiken:**
- [ ] **Hoch:** Gesundheitsdaten-Leak bei fehlendem RLS → **Mitigation:** RLS 4× + Trigger + Tests
- [ ] **Mittel:** Consent nicht granular → **Mitigation:** Consent-Scopes + Widerruf jederzeit
- [ ] **Niedrig:** Logs enthalten PII → **Mitigation:** Kein Logging von PII (nur user_id, kein cycle_length in Logs)

**Compliance-Checks:**
- [ ] **DSFA/DPIA:** Nicht erforderlich (Standard-Feature) ODER **erforderlich** (neue Datenverarbeitung) — siehe `docs/compliance/dpia-cycle-tracking.md`
- [ ] **DSAR-Ready:** Export-Pfad vorhanden (User kann cycle_logs exportieren) ✅
- [ ] **Lösch-Pfad:** User kann cycle_logs löschen (Settings → Daten löschen) ✅

---

## 8. Recommendations (Empfehlungen)

**Sofort (vor Merge):**
- [ ] [z.B. "RLS-Test 4 durchführen (siehe Evidence)"]
- [ ] [z.B. "Consent-Scope 'cycle_tracking' in consent_logs verifizieren"]
- [ ] [z.B. "Kein service_role im Client-Code (grep 'service_role' lib/)"]

**Short-Term (nächster Sprint):**
- [ ] [z.B. "Export-Funktion für cycle_logs (DSAR)"]
- [ ] [z.B. "Lösch-Funktion in Settings (Widerruf-Auswirkung)"]

**Long-Term (Roadmap):**
- [ ] [z.B. "DPIA für AI-Gateway (M5) — Datenübermittlung an OpenAI EU"]
- [ ] [z.B. "Audit-Trail für Admin-Zugriffe (Post-MVP)"]

---

## 9. Sign-Off

**Reviewer:** [Name/Agent]
**Status:** [✅ Approved | ⚠️ Approved with Recommendations | ❌ Rejected]

**Begründung (falls Rejected):**
- [z.B. "RLS-Test 4 fails → kein Merge bis RLS-Policies grün"]

**Next Steps:**
- [z.B. "Merge erlaubt nach RLS-Fix + Re-Review"]

---

## Changelog

**v1.0 (2025-10-03):**
- Initial Template mit 9 Sektionen (Purpose → Sign-Off)
- Aligned mit DSGVO Art. 6/9, ADR-0002 (RLS), DoD
- Beispiel: Cycle-Input (M4)

**SSOT:** Dieses Template ist die Single Source of Truth für Privacy-Reviews. Änderungen hier pflegen, nicht duplizieren.
