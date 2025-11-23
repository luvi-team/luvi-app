# BMAD-Template (Business → Modellierung → Architektur → DoD)

**Zweck:** Standardisierter Planungs-Prozess VOR Implementierung (MIWF-konform).

**Verwendung:**
1. Copy dieses Template in PR-Beschreibung oder separates Planungs-Dokument
2. Fülle alle 4 Sektionen aus (Business/Modellierung/Architektur/DoD)
3. Prüfe alle ⚠️ STOP-Kriterien
4. Erst nach vollständigem BMAD → PRP (Plan → Run → Prove)

---

## Business

**Ziel:** [1-2 Sätze: Was will der User erreichen? Welches Problem löst das Feature?]

**User-Story (optional):** Als [Rolle] möchte ich [Aktion], damit [Nutzen].

**DSGVO-Impact:** [Low / Medium / High] — [Kurze Begründung]

> **Hilfe:** Siehe `docs/privacy/dsgvo-impact-levels.md` für Definitionen.

### ⚠️ STOP-Kriterien (Business)

- [ ] **STOP:** Wenn DSGVO-Impact unklar → lies `docs/privacy/dsgvo-impact-levels.md`
- [ ] **STOP:** Wenn Impact = High, aber keine DSGVO-Review geplant → erstelle `docs/privacy/reviews/<branch>.md` (Template: `context/templates/dsgvo-review-template.md`)
- [ ] **STOP:** Wenn User-Story unklar → frage User nach Klarstellung (kein Raten!)

---

## Modellierung

**Datentypen:**
```sql
-- Beispiel: Neue Tabelle oder geänderte Spalten
CREATE TABLE cycle_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  cycle_length INT NOT NULL CHECK (cycle_length BETWEEN 21 AND 45),
  period_length INT NOT NULL CHECK (period_length BETWEEN 1 AND 10),
  lmp_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

> **Alternativ:** Link zu ERD (z.B. `docs/architecture/erd-cycle.md`) oder Inline-Tabelle für kleinere Änderungen.

**Datenfluss (Flow):**
```
User-Aktion → Screen → State (Riverpod) → Service → Supabase (DB/Edge Function) → Response → UI-Update
```

**Beispiel (Cycle-Input):**
```
User füllt Cycle-Input-Form aus
→ CycleInputScreen
→ cycleInputProvider (Riverpod)
→ SupabaseService.upsertCycleData({cycle_length, period_length, lmp_date})
→ Supabase: INSERT INTO cycle_logs ... (RLS-Policy prüft auth.uid())
→ Response: {success: true, cycle_id: ...}
→ UI: Navigation zu Dashboard + Snackbar "Zyklus gespeichert"
```

### ⚠️ STOP-Kriterien (Modellierung)

- [ ] **STOP:** Wenn PII/Gesundheitsdaten in Modellierung → RLS MUSS in Architektur-Sektion
- [ ] **STOP:** Wenn neue Tabelle, aber kein `user_id`-FK → ADR-0002 Least-Privilege verletzt
- [ ] **STOP:** Wenn Flow unklar (z.B. "irgendwie speichern") → Flow präzisieren (Screen → Service → DB)

---

## Architektur

**Schnittstellen:**

### Frontend
- **Screen:** `lib/features/cycle/screens/cycle_input_screen.dart`
- **State:** `lib/features/cycle/state/cycle_input_provider.dart` (Riverpod)
- **Widgets:** `lib/features/cycle/widgets/cycle_form_field.dart` (Reusable Input)

### Backend
- **Service:** `lib/services/supabase_service.dart` → Methode `upsertCycleData()`
- **Edge Function (optional):** `supabase/functions/compute-cycle-info/index.ts` (falls Server-Logik nötig)

### Datenbank
- **Tabelle:** `cycle_logs`
- **RLS-Policies:**
  ```sql
  -- SELECT Policy
  CREATE POLICY "Users can view own cycle logs"
    ON cycle_logs FOR SELECT
    USING (user_id = auth.uid());

  -- INSERT Policy
  CREATE POLICY "Users can insert own cycle logs"
    ON cycle_logs FOR INSERT
    WITH CHECK (user_id = auth.uid());

  -- UPDATE Policy
  CREATE POLICY "Users can update own cycle logs"
    ON cycle_logs FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

  -- DELETE Policy
  CREATE POLICY "Users can delete own cycle logs"
    ON cycle_logs FOR DELETE
    USING (user_id = auth.uid());
  ```
- **Trigger:**
  ```sql
  -- Auto-set user_id from auth context
  CREATE TRIGGER set_cycle_logs_user_id
    BEFORE INSERT ON cycle_logs
    FOR EACH ROW
    EXECUTE FUNCTION set_user_id_from_auth();
  ```

**Upsert-Strategie:**
```dart
// Conflict auf user_id (1 User = 1 aktiver Zyklus)
await supabase
  .from('cycle_logs')
  .upsert({
    'user_id': userId, // aus auth
    'cycle_length': cycleLength,
    'period_length': periodLength,
    'lmp_date': lmpDate.toIso8601String(),
  }, onConflict: 'user_id');
```

### ⚠️ STOP-Kriterien (Architektur)

- [ ] **STOP:** Wenn DSGVO-Impact = High/Medium, aber kein RLS → lies `docs/runbooks/debug-rls-policy.md`
- [ ] **STOP:** Wenn neue Tabelle, aber keine 4 RLS-Policies (SELECT/INSERT/UPDATE/DELETE) → ADR-0002 verletzt
- [ ] **STOP:** Wenn Trigger fehlt (`set_user_id_from_auth()`) → user_id könnte leer bleiben → RLS-Bypass-Risiko
- [ ] **STOP:** Wenn service_role im Client-Code → ADR-0002 verletzt (kein service_role im Client/Terminal!)
- [ ] **STOP:** Wenn Edge Function, aber keine Rate-Limits → lies `docs/runbooks/test-edge-function-locally.md`

---

## DoD (Definition of Done)

**Tests:**
- [ ] **Unit-Tests:** ≥1 Test für Service-Logik (z.B. `test/services/supabase_service_test.dart`)
  - Beispiel: `test('upsertCycleData inserts valid data')`
- [ ] **Widget-Tests:** ≥1 Test für Screen/Widget (z.B. `test/features/cycle/cycle_input_screen_test.dart`)
  - Beispiel: `test('CycleInputScreen renders form fields')`
- [ ] **Golden-Tests (optional):** Visuelle Regression (nur bei UI-kritischen Widgets)

**RLS-Check (bei DSGVO-Impact = High/Medium):**
- [ ] **1. RLS ON:**
  ```bash
  psql -h <db-host> -U postgres -d postgres
  SELECT relrowsecurity FROM pg_class WHERE relname='cycle_logs';
  # Erwartung: t (true)
  ```
- [ ] **2. Policies existieren (4×):**
  ```bash
  SELECT * FROM pg_policies WHERE tablename='cycle_logs';
  # Erwartung: 4 Zeilen (SELECT, INSERT, UPDATE, DELETE)
  ```
- [ ] **3. Policies nutzen auth.uid():**
  ```bash
  SELECT policyname, qual, with_check FROM pg_policies WHERE tablename='cycle_logs';
  # Erwartung: "user_id = auth.uid()" in qual/with_check
  ```
- [ ] **4. Anon-Test (denied):**
  ```bash
  psql -h <db-host> -U anon -d postgres
  SELECT * FROM cycle_logs;
  # Erwartung: ERROR: new row violates row-level security policy
  ```

> **Hilfe:** Siehe `docs/runbooks/debug-rls-policy.md` bei RLS-Fehlern.

**CI/CD:**
- [ ] `flutter analyze` → 0 errors
- [ ] `flutter test` → all tests passed
- [ ] Privacy-Gate (falls DB-Touch) → grün
- [ ] Greptile Review (Required Check) → "0 blocking issues" (CodeRabbit optional lokal als Preflight; Details siehe `docs/engineering/ai-reviewer.md`)

**DSGVO-Review (bei DSGVO-Impact = High):**
- [ ] Privacy-Review erstellt: `docs/privacy/reviews/<branch>.md`
- [ ] Template genutzt: `context/templates/dsgvo-review-template.md`
- [ ] Data Flow dokumentiert (Input → Processing → Output)
- [ ] Consent-Scope definiert (falls neue Einwilligung nötig)
- [ ] Evidence vorhanden (curl-Tests, anon-user-Tests)

**ADRs:**
- [ ] Relevante ADRs aktualisiert (bei Architektur-/Security-Entscheidung):
  - ADR-0001 (RAG-First): Falls neue Referenz-Quellen
  - ADR-0002 (RLS Least-Privilege): Falls neue RLS-Policies/Tabellen
  - ADR-0003 (MIWF): Falls neue Guards nach Evidenz

**Dokumentation:**
- [ ] README/Feature-Docs aktualisiert (falls User-facing Feature)
- [ ] Code-Kommentare für komplexe Logik (z.B. Cycle-Berechnung)
- [ ] API-Contracts dokumentiert (bei Edge Functions)

### ⚠️ STOP-Kriterien (DoD)

- [ ] **STOP:** Wenn Tests nicht grün → kein Merge (fix tests first!)
- [ ] **STOP:** Wenn RLS-Check fails → lies `docs/runbooks/debug-rls-policy.md`
- [ ] **STOP:** Wenn DSGVO-Impact = High, aber keine Privacy-Review → erstelle Review (Template: `context/templates/dsgvo-review-template.md`)
- [ ] **STOP:** Wenn Greptile Review "blocking issues" → fixe Issues ODER begründe Ignore im PR-Kommentar

---

## Erfolgskriterien (Ready for Merge)

**Alle Checkboxen oben ✅ + alle STOP-Kriterien geprüft**

**Zusätzlich:**
- [ ] PR-Template vollständig ausgefüllt (`.github/pull_request_template.md`)
- [ ] Branch-Protection Required Checks grün:
  - Flutter CI / analyze-test (pull_request)
  - Flutter CI / privacy-gate (pull_request)
  - Greptile Review
- [ ] (Optional) Lokales CodeRabbit-Review (`@coderabbitai review`) abgearbeitet (nur lokaler Preflight, kein GitHub-Required-Check; Policy siehe `docs/engineering/ai-reviewer.md`)
- [ ] Alle PR-Kommentare "resolved"

### ⚠️ FINAL STOP

- [ ] **STOP:** Wenn IRGENDEINE Checkbox oben fehlt → **KEIN MERGE**
- [ ] **STOP:** Wenn Required Checks rot → **KEIN MERGE** (kein Admin-Override ohne Begründung!)

---

## Nächster Schritt nach BMAD

**PRP (Plan → Run → Prove):**
1. **Plan:** Mini-Plan (Why/What/How) für ersten kleinen Schritt
2. **Run:** Implementierung (kleinste Schritte, MIWF: Happy Path zuerst)
3. **Prove:** `flutter analyze`, `flutter test`, RLS-Check (siehe DoD oben)

**Beispiel (Cycle-Input):**
1. Plan: "Migration für cycle_logs-Tabelle + RLS"
2. Run: `supabase/migrations/<timestamp>_create_cycle_logs.sql`
3. Prove: RLS-Check (4 Schritte oben) → grün? → Weiter zu "Frontend-Screen"

---

## Beispiel: Ausgefülltes BMAD (Cycle-Input, M4)

### Business
**Ziel:** User kann Zyklusdaten (Länge, Periodendauer, LMP) eingeben → App berechnet aktuelle Phase → zeigt phasenbasierte Workout-Empfehlungen.

**DSGVO-Impact:** **High** — Zyklus-Daten (LMP, Länge, Periodendauer) sind Gesundheitsdaten gem. DSGVO Art. 9.

### Modellierung
**Datentypen:** Siehe SQL-Snippet oben (cycle_logs-Tabelle).

**Flow:**
```
Onboarding-Screen → Cycle-Input-Form → cycleInputProvider (validate) → SupabaseService.upsertCycleData() → cycle_logs INSERT (RLS-Check) → Dashboard (zeigt Phase + Workout-Card)
```

### Architektur
**Frontend:** `lib/features/cycle/screens/cycle_input_screen.dart`, Riverpod State `cycleInputProvider`.

**Backend:** `lib/services/supabase_service.dart` → `upsertCycleData()` (Upsert on conflict=user_id).

**DB:** Tabelle `cycle_logs`, 4 RLS-Policies (siehe oben), Trigger `set_user_id_from_auth()`.

### DoD
- [x] Unit-Test: `supabase_service_test.dart` → `upsertCycleData()` valid/invalid cases
- [x] Widget-Test: `cycle_input_screen_test.dart` → renders form + validation
- [x] RLS-Check: 4 Steps (siehe oben) → ✅ grün
- [x] Privacy-Review: `docs/privacy/reviews/feat-m4-cycle-input.md`
- [x] CI grün (analyze/test/privacy-gate)
- [x] Greptile Review: 0 blocking issues (CodeRabbit optional lokal)

**STOP-Kriterien:** Alle geprüft ✅ → Ready for Merge.

---

## Changelog

**v1.0 (2025-10-03):**
- Initial Template mit Safety-Rails (⚠️ STOP-Kriterien)
- Aligned mit MIWF, ADR-0002 (RLS), DoD
- Beispiel: Cycle-Input (M4)

**SSOT:** Dieses Template ist die Single Source of Truth für BMAD-Prozess. Änderungen hier pflegen, nicht duplizieren.
