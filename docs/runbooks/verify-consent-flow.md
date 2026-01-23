# Runbook: Verify Consent Flow (DSGVO-konform)

**Zweck:** Consent-Management End-to-End testen (DSGVO Art. 6 + 9 Compliance).

**Wann verwenden:**
- Neuer Consent-Scope hinzugefügt (z.B. M4: "cycle_tracking", M5: "ai_workout_recommendations")
- Consent-UI geändert (z.B. Opt-in-Toggle, Erklärtexte)
- DSGVO-Audit vorbereiten (Evidence sammeln)
- Bug-Report: "User kann Feature nutzen, obwohl Consent fehlt"

**Voraussetzungen:**
- Supabase CLI/Studio-Zugriff
- Test-User-Account (lokal oder remote)
- Consent-Log-Tabelle existiert (`consent_logs`)

---

## Step 1: Consent-Scope definieren (BMAD)

### 1.1 Scope-Liste prüfen

**Erwartete Scopes (LUVI-Roadmap):**

| Scope | Feature | Impact | Milestone |
|-------|---------|--------|-----------|
| `cycle_tracking` | Zyklus-Daten erfassen | High (Gesundheitsdaten) | M4 |
| `ai_workout_recommendations` | AI-basierte Workout-Empfehlungen | High (PII + extern) | M5 |
| `newsletter_subscription` | Newsletter-Opt-in (Brevo) | Medium (Email extern) | M12 |
| `wearable_sync` | Sleep/HRV-Daten von Wearables | High (Gesundheitsdaten) | M13+ |

**In Code prüfen:**
```bash
# Consent-Scopes im Code suchen
grep -r "cycle_tracking" lib/

# Erwartung: Consent-UI + Consent-Log-Calls
```

### 1.2 Scope-Dokumentation

**DSGVO-Review prüfen:**
```bash
# Privacy-Review für Feature
cat docs/privacy/reviews/feat-m4-cycle-input.md

# Erwartung: Abschnitt "4. Consent" mit Scope-Definition
```

---

## Step 2: Consent-UI testen (Opt-in Flow)

### 2.1 Onboarding-Flow (First-Time User)

**Manueller Test:**
1. App zurücksetzen (lokale Daten löschen)
2. App starten → Splash → Login/Signup
3. Nach Login → Consent-Screen erscheint
4. Consent-Scope "Zyklus-Tracking" → Toggle aktivieren
5. Erklärtexte prüfen:
   - **Zweck:** "Wir speichern Länge, Periodendauer, LMP für phasenbasierte Empfehlungen"
   - **Rechte:** "Du kannst jederzeit widerrufen (Settings → Datenschutz)"
   - **Datentypen:** "Zyklus-Daten (Gesundheitsdaten gem. DSGVO Art. 9)"
6. Weiter → Consent-Log wird geschrieben (siehe Step 3)

**Widget-Test (automatisiert):**
```dart
// test/features/consent/consent_screen_test.dart
testWidgets('ConsentScreen zeigt cycle_tracking Toggle', (tester) async {
  await tester.pumpWidget(ConsentScreen());

  // Toggle finden
  final toggle = find.byKey(Key('consent_toggle_cycle_tracking'));
  expect(toggle, findsOneWidget);

  // Erklärtexte prüfen
  expect(find.text('Zyklus-Tracking'), findsOneWidget);
  expect(find.textContaining('Gesundheitsdaten'), findsOneWidget);

  // Toggle aktivieren
  await tester.tap(toggle);
  await tester.pumpAndSettle();

  // State prüfen (Riverpod)
  final provider = ProviderScope.containerOf(tester.element(toggle));
  final consentState = provider.read(consentProvider);
  expect(consentState.scopes.contains('cycle_tracking'), true);
});
```

### 2.2 Settings-Flow (Consent-Widerruf)

**Manueller Test:**
1. App → Settings → Datenschutz → Consent-Management
2. "Zyklus-Tracking" Toggle → deaktivieren
3. Bestätigungsdialog:
   - **Warnung:** "Workout-Empfehlungen werden deaktiviert"
   - **Daten:** "Möchtest du Zyklus-Daten löschen?" (optional)
4. Bestätigen → Consent-Log-Update (siehe Step 3.3)

---

## Step 3: Consent-Log verifizieren (DB)

### 3.1 Consent-Log Struktur prüfen

**Tabelle:** `consent_logs`

```sql
CREATE TABLE consent_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  version TEXT NOT NULL,           -- z.B. "v1.0"
  scopes TEXT[] NOT NULL,          -- ["cycle_tracking", "ai_workout_recommendations"]
  created_at TIMESTAMPTZ DEFAULT now(),

  -- RLS (owner-based)
  CONSTRAINT consent_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

-- RLS aktivieren
ALTER TABLE consent_logs ENABLE ROW LEVEL SECURITY;

-- Policies (4×)
CREATE POLICY "Users can view own consent logs" ON consent_logs FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert own consent logs" ON consent_logs FOR INSERT WITH CHECK (user_id = auth.uid());
-- UPDATE/DELETE analog
```

**Prüfen:**
```bash
supabase db remote --db-url <connection-string>

# In psql:
\d consent_logs

# Erwartung: Spalten user_id, version, scopes, created_at
```

### 3.2 Opt-in: Log-Entry nach Consent

**Nach Step 2.1 (Onboarding-Toggle aktiviert):**

```bash
# In psql:
SELECT id, user_id, version, scopes, created_at
FROM consent_logs
WHERE user_id = '<test-user-id>'
ORDER BY created_at DESC
LIMIT 1;

# Erwartung:
# | id | user_id | version | scopes | created_at |
# | ... | <test-user-id> | v1.0 | {"cycle_tracking"} | 2025-10-03 12:00:00 |
```

**Via curl (API-Test):**
```bash
# Log Consent (Flutter-App ruft auf)
curl -X POST https://<project>.supabase.co/rest/v1/consent_logs \
  -H "apikey: <anon-key>" \
  -H "Authorization: Bearer <user-jwt>" \
  -H "Content-Type: application/json" \
  -d '{"version": "v1.0", "scopes": ["cycle_tracking"]}'

# Erwartung: 201 Created + {id: "...", user_id: "...", ...}
```

### 3.3 Opt-out: Log-Entry nach Widerruf

**Nach Step 2.2 (Settings-Toggle deaktiviert):**

```bash
# Neuer Log-Entry (scopes leer ODER ohne "cycle_tracking")
SELECT scopes, created_at FROM consent_logs
WHERE user_id = '<test-user-id>'
ORDER BY created_at DESC
LIMIT 1;

# Erwartung:
# | scopes | created_at |
# | {} | 2025-10-03 12:05:00 |  (komplett widerrufen)
# ODER
# | {"ai_workout_recommendations"} | ...  (nur cycle_tracking entfernt)
```

**Wichtig:** Kein DELETE, sondern INSERT (Audit-Trail = alle Consent-Änderungen nachvollziehbar).

---

## Step 4: Feature-Gate testen (Consent-Prüfung)

### 4.1 Feature zugreifbar nur mit Consent

**Code-Beispiel (Cycle-Input-Screen):**
```dart
// lib/features/cycle/screens/cycle_input_screen.dart

@override
Widget build(BuildContext context) {
  final consentState = ref.watch(consentProvider);

  // Feature-Gate: Cycle-Input nur mit Consent
  if (!consentState.scopes.contains('cycle_tracking')) {
    return ConsentRequiredWidget(
      scope: 'cycle_tracking',
      message: 'Bitte aktiviere Zyklus-Tracking in den Einstellungen.',
    );
  }

  return CycleInputForm(...);
}
```

**Test:**
```bash
# 1. Consent deaktiviert (Step 2.2)
# 2. App → Cycle-Input-Screen öffnen
# Erwartung: ConsentRequiredWidget angezeigt (kein Form)

# 3. Consent aktivieren (Step 2.1)
# 4. App → Cycle-Input-Screen öffnen
# Erwartung: CycleInputForm angezeigt
```

### 4.2 Backend-Check (Edge Function)

**Code-Beispiel (AI-Gateway):**
```typescript
// supabase/functions/ai-gateway/index.ts

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  const supabase = createClient(...);
  const { data: { user } } = await supabase.auth.getUser();

  // Consent prüfen
  const { data: consentLog } = await supabase
    .from("consent_logs")
    .select("scopes")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false })
    .limit(1)
    .single();

  if (!consentLog?.scopes.includes("ai_workout_recommendations")) {
    return new Response("Consent required", { status: 403 });
  }

  // AI-Call nur mit Consent...
});
```

**Test:**
```bash
# Ohne Consent
curl -X POST https://<project>.supabase.co/functions/v1/ai-gateway \
  -H "Authorization: Bearer <user-jwt-ohne-consent>" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Test"}'

# Erwartung: 403 Forbidden + "Consent required"

# Mit Consent
curl -X POST https://<project>.supabase.co/functions/v1/ai-gateway \
  -H "Authorization: Bearer <user-jwt-mit-consent>" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Test"}'

# Erwartung: 200 OK + AI-Response
```

---

## Step 5: Audit-Trail prüfen (DSGVO-Nachweis)

### 5.1 Consent-Historie

**Frage:** Wann hat User Consent gegeben/widerrufen?

```bash
# Alle Consent-Änderungen für User
SELECT version, scopes, created_at
FROM consent_logs
WHERE user_id = '<test-user-id>'
ORDER BY created_at ASC;

# Erwartung (Beispiel):
# | version | scopes | created_at |
# | v1.0 | {"cycle_tracking"} | 2025-10-03 10:00:00 |  (Opt-in)
# | v1.0 | {"cycle_tracking", "ai_workout_recommendations"} | 2025-10-03 11:00:00 |  (zweiter Scope)
# | v1.0 | {"ai_workout_recommendations"} | 2025-10-03 12:00:00 |  (cycle_tracking widerrufen)
# | v1.0 | {} | 2025-10-03 13:00:00 |  (alles widerrufen)
```

**Audit-Frage:** User behauptet "Ich habe nie zugestimmt" → Log prüfen.

### 5.2 DSAR-Export (Datenauskunft)

**User-Request:** "Zeig mir alle Daten, die ihr über mich habt."

```bash
# Export-Function (Edge Function oder Admin-Script)
SELECT
  cl.version,
  cl.scopes,
  cl.created_at,
  cyc.cycle_length,
  cyc.period_length,
  cyc.lmp_date
FROM consent_logs cl
LEFT JOIN cycle_logs cyc ON cyc.user_id = cl.user_id
WHERE cl.user_id = '<user-id>'
ORDER BY cl.created_at DESC;

# Export als JSON
-- siehe docs/compliance/dsar-export-template.sql (TODO: erstellen)
```

### 5.3 Lösch-Pfad (Widerruf-Auswirkung)

**User-Request:** "Lösche meine Zyklus-Daten."

```sql
-- In Settings → Datenschutz → "Zyklus-Daten löschen"
DELETE FROM cycle_logs WHERE user_id = '<user-id>';

-- Consent-Log bleibt (Audit-Trail)
-- ABER: Scope "cycle_tracking" aus aktuellstem Log entfernen (Step 3.3)
```

**Wichtig:** Consent-Logs NIEMALS löschen (Audit-Trail für DSGVO-Nachweise).

---

## Step 6: Version-Management (Consent-Texte ändern)

### 6.1 Neue Consent-Version (z.B. v1.1)

**Szenario:** Erklärtexte ändern sich (z.B. "Wir nutzen jetzt EU-Modelle statt US").

**Prozess:**
1. Consent-Version in Code ändern: `version: "v1.1"`
2. User mit `v1.0` → Consent-Screen erneut zeigen (Re-Opt-in)
3. Neuer Consent-Log-Entry mit `v1.1`

**Code-Beispiel:**
```dart
// lib/features/consent/consent_provider.dart

const CURRENT_CONSENT_VERSION = "v1.1";

Future<bool> needsReConsent(String userId) async {
  final latestLog = await supabase
    .from('consent_logs')
    .select('version')
    .eq('user_id', userId)
    .order('created_at', ascending: false)
    .limit(1)
    .single();

  return latestLog['version'] != CURRENT_CONSENT_VERSION;
}
```

**Test:**
```bash
# User mit v1.0-Consent
SELECT version FROM consent_logs WHERE user_id = '<user-id>' ORDER BY created_at DESC LIMIT 1;
# → "v1.0"

# App-Start → needsReConsent() → true → Consent-Screen zeigen

# User akzeptiert → neuer Log mit v1.1
INSERT INTO consent_logs (user_id, version, scopes) VALUES ('<user-id>', 'v1.1', '{"cycle_tracking"}');
```

---

## Checkliste (Copy-Paste für PR-Kommentar)

```markdown
## Consent-Flow Verify ✅

- [ ] **Step 1:** Consent-Scope dokumentiert (DSGVO-Review + BMAD)
- [ ] **Step 2.1:** Onboarding-UI zeigt Toggle + Erklärtexte
- [ ] **Step 2.2:** Settings-UI erlaubt Widerruf
- [ ] **Step 3.1:** `consent_logs` Tabelle existiert + RLS ON
- [ ] **Step 3.2:** Opt-in schreibt Log-Entry (scopes = ["cycle_tracking"])
- [ ] **Step 3.3:** Opt-out schreibt Log-Entry (scopes = [] oder entfernt)
- [ ] **Step 4.1:** Feature-Gate blockiert ohne Consent
- [ ] **Step 4.2:** Backend-Check (Edge Function) → 403 ohne Consent
- [ ] **Step 5.1:** Audit-Trail vollständig (alle Consent-Änderungen sichtbar)
- [ ] **Step 5.2:** DSAR-Export getestet (alle User-Daten exportierbar)
- [ ] **Step 5.3:** Lösch-Pfad getestet (Daten löschbar, Log bleibt)
- [ ] **Step 6:** Version-Management (Re-Opt-in bei Änderungen)

**Evidence:**
[Screenshots, SQL-Queries, curl-Output hier einfügen]
```

---

## Häufige Fehler & Fixes

### "Consent-Log leer, obwohl Toggle aktiviert"
**Symptom:** User aktiviert Toggle, aber `consent_logs` bleibt leer.

**Ursache:** API-Call failed (RLS-Policy fehlt oder anon-key falsch).

**Fix:**
```bash
# RLS-Check (siehe docs/runbooks/debug-rls-policy.md)
# Curl-Test (Step 3.2)
```

### "Feature nutzbar ohne Consent"
**Symptom:** User kann Cycle-Input öffnen, obwohl Consent fehlt.

**Ursache:** Feature-Gate fehlt (Code prüft Consent nicht).

**Fix:**
```dart
// Vor Feature-Zugriff immer prüfen:
final consented = await ref.read(consentProvider.notifier).hasScope('cycle_tracking');
if (!consented) {
  return ConsentRequiredWidget(...);
}
```

### "Consent-Log-Duplikate"
**Symptom:** Mehrere identische Einträge (gleiche scopes, gleiche Version).

**Ursache:** User spammt Toggle (mehrfache API-Calls).

**Fix:**
```dart
// Debounce Toggle-Änderungen (500ms)
Timer? _debounce;

void onToggleChanged(bool value) {
  _debounce?.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    logConsent(...);
  });
}
```

---

## Weiterführende Links

- **DSGVO Art. 6 (Rechtmäßigkeit):** https://dsgvo-gesetz.de/art-6-dsgvo/
- **DSGVO Art. 9 (Gesonderte Einwilligung):** https://dsgvo-gesetz.de/art-9-dsgvo/
- **DSGVO-Impact-Levels (LUVI):** `docs/privacy/dsgvo-impact-levels.md`
- **DSGVO-Review-Template:** `context/templates/dsgvo-review-template.md`
- **ADR-0002 (RLS Least-Privilege):** `context/ADR/0002-least-privilege-rls.md`

---

## Changelog

**v1.0 (2025-10-03):**
- Initial Runbook (6 Steps: Scope → UI → Log → Feature-Gate → Audit → Version)
- Aligned mit DSGVO Art. 6/9, BMAD-Template, DSGVO-Review-Template
