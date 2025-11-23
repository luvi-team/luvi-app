# DSGVO-Impact-Levels (LUVI)

**Zweck:** Standardisierte Bewertung des Datenschutz-Risikos für jedes Feature/PR.

**Verwendung:**
- In BMAD (Business-Sektion): DSGVO-Impact angeben
- In DSGVO-Review: Impact-Level dokumentieren
- In PR-Kommentaren: Begründung für Impact-Einstufung

---

## Low (Niedriges Risiko)

**Definition:**
- Kein Zugriff auf personenbezogene Daten (PII)
- Keine Datenbank-Operationen (nur UI/lokaler State)
- Kein Tracking/Analytics
- Keine externe Datenübermittlung

**Beispiele:**
- UI-only Widgets (z.B. Onboarding-Welcome-Screen, Theme-Toggle)
- Stateless Komponenten (z.B. Design-Token-Updates, Layout-Änderungen)
- Navigation/Routing-Änderungen (ohne PII-Context)

**Erforderliche Checks:**
- ✅ CI grün (flutter analyze/test)
- ✅ Greptile Review grün (CodeRabbit optional lokal als Preflight, kein GitHub-Check)
- ⚠️ Kein RLS-Check erforderlich

**Consent:**
- Kein spezifischer Consent-Scope nötig

---

## Medium (Mittleres Risiko)

**Definition:**
- **Lesen** von personenbezogenen Daten (PII) oder Gesundheitsdaten
- Anzeige bestehender Daten (z.B. Dashboard zeigt Zyklus-Phase)
- Consent-Scope vorhanden (User hat bereits eingewilligt)
- Keine neuen Tabellen/RLS-Policies
- Keine Schreib-Operationen auf sensiblen Daten

**Beispiele:**
- Dashboard-Widgets (Workout-Card zeigt phasenbasierte Empfehlung aus cycle_logs)
- Statistics-Charts (Zyklus-Verlauf visualisieren)
- Export-Funktionen (bestehende Daten als PDF)

**Erforderliche Checks:**
- ✅ CI grün (flutter analyze/test)
- ✅ Greptile Review grün (CodeRabbit optional lokal als Preflight, kein GitHub-Check)
- ✅ RLS-Check (bestehende Policies prüfen: SELECT-Policy vorhanden?)
- ✅ Consent-Scope verifizieren (User hat für Daten-Nutzung eingewilligt)
- ⚠️ Keine neuen Migrations/Policies erforderlich

**Consent:**
- Bestehender Scope ausreichend (z.B. "cycle_tracking")
- In DSGVO-Review dokumentieren: Welcher Scope?

---

## High (Hohes Risiko)

**Definition:**
- **Schreiben** von personenbezogenen Daten (PII) oder Gesundheitsdaten
- Neue Tabellen/Spalten mit sensiblen Daten
- Neue oder geänderte RLS-Policies
- Neue Consent-Scopes
- Datenübermittlung an Dritte (z.B. AI-Gateway, Newsletter-Service)
- Pseudonymisierung/Anonymisierung
- Lösch-/Export-Pfade (DSAR)

**Beispiele:**
- Cycle-Input (schreibt cycle_logs: LMP, Länge, Periodendauer)
- Symptom-Logging (neue Tabelle symptom_logs)
- AI-Gateway (überträgt Gesundheitsdaten an OpenAI EU-Project)
- Consent-Management (neue Consent-Scopes)
- Newsletter-Opt-in (Datenübermittlung an Brevo)
- Wearable-Sync (Sleep/HRV-Daten schreiben)

**Erforderliche Checks:**
- ✅ CI grün (flutter analyze/test)
- ✅ Greptile Review grün (CodeRabbit optional lokal als Preflight, kein GitHub-Check)
- ✅ **RLS-Check (vollständig):**
  1. `SELECT relrowsecurity FROM pg_class WHERE relname='<table>';` → true
  2. `SELECT * FROM pg_policies WHERE tablename='<table>';` → 4 Policies (SELECT/INSERT/UPDATE/DELETE)
  3. Policies nutzen `auth.uid()` (owner-based)
  4. Test als anon-user: `psql -U anon → SELECT * FROM <table>;` → denied
- ✅ **DSGVO-Review (vollständig):**
  - Privacy-Review unter `docs/privacy/reviews/<branch>.md`
  - Data Flow dokumentiert (Input → Processing → Output)
  - PII/Gesundheitsdaten klassifiziert
  - Consent-Scope definiert + Opt-in-Flow beschrieben
  - RLS/Security-Maßnahmen beschrieben
  - Evidence (curl-Tests, anon-user-Tests)
- ✅ **Migration + Trigger:**
  - Neue Tabelle → RLS ON + 4 Policies + set_user_id_from_auth() Trigger
  - Dokumentiert in Migration-File (SQL-Kommentare)
- ✅ **Consent-Logging:**
  - Neuer Scope → in Consent-UI + consent_logs
  - Version + Timestamp + Scopes gespeichert

**Consent:**
- Neuer Consent-Scope erforderlich (z.B. "ai_workout_recommendations", "newsletter_subscription")
- Explizit Opt-in (Toggle/Checkbox)
- Widerruf jederzeit möglich (Settings → Consent-Management)

---

## Entscheidungshilfe (Quick-Check)

```
Frage 1: Greifst du auf PII/Gesundheitsdaten zu?
├─ NEIN → Low
└─ JA → Frage 2

Frage 2: Schreibst du Daten in DB?
├─ NEIN (nur lesen) → Medium
└─ JA → Frage 3

Frage 3: Neue Tabelle/Spalte mit PII/Gesundheitsdaten?
├─ NEIN (bestehende Tabelle) → Medium (aber RLS-Check!)
└─ JA → High

Frage 4: Neue RLS-Policy oder Consent-Scope?
├─ NEIN → Medium
└─ JA → High

Frage 5: Datenübermittlung an Dritte?
├─ NEIN → (siehe Frage 1-4)
└─ JA → High
```

---

## Grenzfälle (häufige Fragen)

### "Ich ändere nur UI, aber zeige cycle_logs-Daten an"
→ **Medium** (PII-Read, kein Write)

### "Ich füge Spalte 'notes' zu cycle_logs hinzu (optional, User kann leer lassen)"
→ **High** (neue Spalte in PII-Tabelle, auch wenn optional)

### "Ich lösche Feature X, das PII nutzte"
→ **Medium** (kein Write, aber Code-Review für vollständige Löschung)

### "Ich refactore cycle-Service (kein Schema-Change)"
→ **Low** (wenn kein neuer PII-Zugriff) oder **Medium** (wenn bestehender PII-Zugriff bleibt)

### "Ich sende anonymisierte Daten an PostHog (kein user_id)"
→ **Low** (wenn wirklich anonymisiert, kein PII) — ABER: DSGVO-Review empfohlen zur Sicherheit

---

## Changelog

**v1.0 (2025-10-03):**
- Initial Definition (Low/Medium/High)
- Entscheidungshilfe + Grenzfälle
- Aligned mit ADR-0002 (RLS Least-Privilege), MIWF, DoD

**SSOT:** Diese Datei ist die Single Source of Truth für Impact-Levels. Bei Unklarheiten diese Datei aktualisieren, nicht duplizieren.
