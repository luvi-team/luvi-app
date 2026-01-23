# Runbook: Debug RLS-Policy (Row-Level Security)

**Zweck:** Schritt-für-Schritt Troubleshooting bei RLS-Fehlern (Supabase/PostgreSQL).

**Wann verwenden:**
- RLS-Check fails (z.B. anon-user kann Daten lesen, obwohl verboten)
- Migration erstellt Tabelle, aber RLS nicht aktiv
- Policy existiert, aber User kann nicht auf eigene Daten zugreifen
- `ERROR: new row violates row-level security policy`

**Voraussetzungen:**
- Supabase CLI installiert (`brew install supabase/tap/supabase`)
- Supabase-Projekt linked (`supabase link --project-ref <project-id>`)
- DB-Credentials (postgres-user + anon-key)

---

## Step 1: RLS-Status prüfen (ist RLS ON?)

**Problem:** Tabelle existiert, aber RLS nicht aktiviert → Policies werden ignoriert.

### 1.1 Local DB (Development)

```bash
# Supabase local DB starten (falls noch nicht läuft)
supabase start

# PostgreSQL-Shell öffnen
supabase db reset --db-url postgresql://postgres:postgres@localhost:54322/postgres

# In psql:
SELECT
  schemaname,
  tablename,
  relrowsecurity AS rls_enabled
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
JOIN pg_tables t ON c.relname = t.tablename AND n.nspname = t.schemaname
WHERE schemaname = 'public' AND tablename = '<your-table>';
```

**Erwartung:** `rls_enabled = t` (true)

**Falls `rls_enabled = f` (false):**
```sql
ALTER TABLE <your-table> ENABLE ROW LEVEL SECURITY;
```

**Dann Migration aktualisieren:**
```sql
-- In supabase/migrations/<timestamp>_create_<table>.sql
ALTER TABLE <your-table> ENABLE ROW LEVEL SECURITY;
```

### 1.2 Remote DB (Staging/Production)

```bash
# Supabase Dashboard → Settings → Database → Connection String kopieren
# Oder via CLI:
supabase db remote --db-url <connection-string>

# Dann wie 1.1
```

---

## Step 2: Policies prüfen (4 Policies vorhanden?)

**Problem:** RLS ON, aber Policies fehlen oder falsch konfiguriert.

### 2.1 Policies auflisten

```bash
# In psql:
SELECT
  schemaname,
  tablename,
  policyname,
  cmd AS command,  -- SELECT, INSERT, UPDATE, DELETE
  qual AS using_clause,
  with_check
FROM pg_policies
WHERE tablename = '<your-table>'
ORDER BY cmd;
```

**Erwartung (owner-based RLS):**

| policyname | command | using_clause | with_check |
|------------|---------|--------------|------------|
| Users can view own ... | SELECT | `(user_id = auth.uid())` | NULL |
| Users can insert own ... | INSERT | NULL | `(user_id = auth.uid())` |
| Users can update own ... | UPDATE | `(user_id = auth.uid())` | `(user_id = auth.uid())` |
| Users can delete own ... | DELETE | `(user_id = auth.uid())` | NULL |

**Falls Policies fehlen:**
```sql
-- Beispiel: SELECT-Policy erstellen
CREATE POLICY "Users can view own <table>"
  ON <your-table> FOR SELECT
  USING (user_id = auth.uid());

-- INSERT-Policy
CREATE POLICY "Users can insert own <table>"
  ON <your-table> FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- UPDATE-Policy
CREATE POLICY "Users can update own <table>"
  ON <your-table> FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- DELETE-Policy
CREATE POLICY "Users can delete own <table>"
  ON <your-table> FOR DELETE
  USING (user_id = auth.uid());
```

**Dann Migration aktualisieren** (siehe Step 1.1).

---

## Step 3: Trigger prüfen (`set_user_id_from_auth()`)

**Problem:** RLS + Policies vorhanden, aber `user_id` bleibt NULL → RLS-Bypass.

### 3.1 Trigger prüfen

```bash
# In psql:
SELECT
  trigger_name,
  event_manipulation AS event,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = '<your-table>';
```

**Erwartung:**

| trigger_name | event | action_statement |
|--------------|-------|------------------|
| set_<table>_user_id | INSERT | EXECUTE FUNCTION set_user_id_from_auth() |

**Falls Trigger fehlt:**
```sql
-- Funktion erstellen (falls noch nicht vorhanden)
CREATE OR REPLACE FUNCTION set_user_id_from_auth()
RETURNS TRIGGER AS $$
BEGIN
  NEW.user_id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger erstellen
CREATE TRIGGER set_<table>_user_id
  BEFORE INSERT ON <your-table>
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id_from_auth();
```

**Dann Migration aktualisieren** (siehe Step 1.1).

### 3.2 Trigger testen

```bash
# Insert via anon-key (simuliert Client)
curl -X POST https://<project>.supabase.co/rest/v1/<your-table> \
  -H "apikey: <anon-key>" \
  -H "Authorization: Bearer <user-jwt>" \
  -H "Content-Type: application/json" \
  -d '{"field1": "value1", "field2": "value2"}'

# Dann DB prüfen: user_id gesetzt?
psql -h <db-host> -U postgres -d postgres
SELECT id, user_id, field1, created_at FROM <your-table> ORDER BY created_at DESC LIMIT 1;
```

**Erwartung:** `user_id` = `<user-id-from-jwt>`, NICHT NULL.

---

## Step 4: Anon-User Test (RLS blockiert unautorisierten Zugriff?)

**Problem:** RLS + Policies + Trigger vorhanden, aber anon-user kann trotzdem Daten lesen/schreiben.

### 4.1 Anon-User SELECT (sollte leer sein)

```bash
# Via curl (simuliert anon-key ohne JWT)
curl https://<project>.supabase.co/rest/v1/<your-table> \
  -H "apikey: <anon-key>"

# Erwartung: [] (leeres Array) ODER 401 Unauthorized
```

**Falls Daten zurückkommen:**
- ⚠️ **Problem:** SELECT-Policy fehlt oder falsch
- **Fix:** Siehe Step 2.1 (SELECT-Policy erstellen)

### 4.2 Anon-User INSERT (sollte rejected werden)

```bash
# Via curl (ohne JWT)
curl -X POST https://<project>.supabase.co/rest/v1/<your-table> \
  -H "apikey: <anon-key>" \
  -H "Content-Type: application/json" \
  -d '{"field1": "malicious", "user_id": "00000000-0000-0000-0000-000000000000"}'

# Erwartung: ERROR 403 (new row violates row-level security policy)
```

**Falls 201 Created:**
- ⚠️ **Problem:** INSERT-Policy fehlt oder Trigger setzt user_id nicht
- **Fix:** Siehe Step 2.1 (INSERT-Policy) + Step 3.1 (Trigger)

### 4.3 Auth-User SELECT (sollte nur eigene Daten zeigen)

```bash
# Test-User 1 erstellen (via Supabase Dashboard → Auth → Users)
# JWT für User 1 holen (via Supabase CLI oder Dashboard)

# Via curl (mit JWT von User 1)
curl https://<project>.supabase.co/rest/v1/<your-table> \
  -H "apikey: <anon-key>" \
  -H "Authorization: Bearer <user1-jwt>"

# Erwartung: Nur Rows mit user_id = <user1-id>
```

**Test-User 2 erstellen + JWT holen:**
```bash
curl https://<project>.supabase.co/rest/v1/<your-table> \
  -H "apikey: <anon-key>" \
  -H "Authorization: Bearer <user2-jwt>"

# Erwartung: Nur Rows mit user_id = <user2-id> (nicht User 1's Daten!)
```

**Falls User 2 User 1's Daten sehen kann:**
- ⚠️ **Problem:** SELECT-Policy nutzt nicht `auth.uid()` (vielleicht hardcoded?)
- **Fix:** Siehe Step 2.1 (Policy prüfen: `USING (user_id = auth.uid())`)

---

## Step 5: Migration & Rollback-Plan

**Problem behoben?** → Migration committen + testen.

### 5.1 Migration prüfen

```bash
# Alle Schritte in 1 Migration-File:
cat supabase/migrations/<timestamp>_create_<table>.sql
```

**Erwartete Struktur:**
```sql
-- 1. Tabelle erstellen
CREATE TABLE <your-table> (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  field1 TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. RLS aktivieren
ALTER TABLE <your-table> ENABLE ROW LEVEL SECURITY;

-- 3. Policies erstellen (4×)
CREATE POLICY "Users can view own <table>" ON <your-table> FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert own <table>" ON <your-table> FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update own <table>" ON <your-table> FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can delete own <table>" ON <your-table> FOR DELETE USING (user_id = auth.uid());

-- 4. Trigger erstellen
CREATE TRIGGER set_<table>_user_id
  BEFORE INSERT ON <your-table>
  FOR EACH ROW
  EXECUTE FUNCTION set_user_id_from_auth();
```

### 5.2 Migration lokal testen

```bash
# DB zurücksetzen (löscht alle Daten!)
supabase db reset

# Alle Migrations anwenden
supabase db push

# RLS-Check (Step 1-4) wiederholen
```

### 5.3 Rollback-Plan (falls Migration fehlschlägt)

```sql
-- In supabase/migrations/<timestamp>_rollback_<table>.sql

-- 1. Trigger löschen
DROP TRIGGER IF EXISTS set_<table>_user_id ON <your-table>;

-- 2. Policies löschen
DROP POLICY IF EXISTS "Users can view own <table>" ON <your-table>;
DROP POLICY IF EXISTS "Users can insert own <table>" ON <your-table>;
DROP POLICY IF EXISTS "Users can update own <table>" ON <your-table>;
DROP POLICY IF EXISTS "Users can delete own <table>" ON <your-table>;

-- 3. RLS deaktivieren (NUR temporär für Debug, NIEMALS in Production!)
ALTER TABLE <your-table> DISABLE ROW LEVEL SECURITY;

-- 4. Tabelle löschen (falls komplett zurückrollen)
DROP TABLE IF EXISTS <your-table>;
```

**Rollback anwenden:**
```bash
supabase db push --file supabase/migrations/<timestamp>_rollback_<table>.sql
```

---

## Step 6: Häufige Fehler & Fixes

### 6.1 "user_id cannot be null"
**Symptom:** INSERT fails mit `ERROR: null value in column "user_id" violates not-null constraint`

**Ursache:** Trigger fehlt oder `auth.uid()` ist NULL (User nicht eingeloggt).

**Fix:**
- Trigger prüfen (Step 3.1)
- JWT-Token valide? (`curl -H "Authorization: Bearer <jwt>"` → 401 = invalid)

### 6.2 "new row violates row-level security policy"
**Symptom:** INSERT/UPDATE fails trotz auth

**Ursache:** `WITH CHECK` in Policy blockiert (z.B. User versucht `user_id` zu ändern).

**Fix:**
```sql
-- Falsch (blockiert, wenn user_id im Request mitgesendet wird)
WITH CHECK (user_id = auth.uid())

-- Richtig (Trigger setzt user_id automatisch, Client sendet NICHT user_id)
-- Client-Code:
await supabase.from('<table>').insert({
  field1: 'value1',
  // KEIN user_id hier!
});
```

### 6.3 "permission denied for table <table>"
**Symptom:** SELECT/INSERT fails mit `permission denied`

**Ursache:** anon-Role hat keine GRANT-Permissions.

**Fix:**
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON <your-table> TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON <your-table> TO authenticated;
```

**In Migration hinzufügen** (nach `CREATE TABLE`).

### 6.4 Service-Role im Client-Code
**Symptom:** RLS-Tests lokal grün, aber Production zeigt fremde Daten.

**Ursache:** Client nutzt `service_role` (bypassed RLS) statt `anon`-key.

**Fix:**
```bash
# Im Code suchen:
grep -r "service_role" lib/

# Erwartung: KEINE Treffer (service_role nur in Edge Functions erlaubt!)
```

**Richtig (Client):**
```dart
final supabase = Supabase.instance.client; // nutzt anon-key automatisch
```

**Falsch (Client):**
```dart
final supabase = SupabaseClient(url, serviceRoleKey); // ❌ NIEMALS im Client!
```

---

## Checkliste (Copy-Paste für PR-Kommentar)

```markdown
## RLS-Check ✅

- [ ] **Step 1:** RLS ON (`relrowsecurity = t`)
- [ ] **Step 2:** 4 Policies vorhanden (SELECT/INSERT/UPDATE/DELETE)
- [ ] **Step 3:** Trigger `set_user_id_from_auth()` aktiv
- [ ] **Step 4.1:** Anon-User SELECT → `[]` (leer)
- [ ] **Step 4.2:** Anon-User INSERT → `403 Forbidden`
- [ ] **Step 4.3:** Auth-User SELECT → nur eigene Daten
- [ ] **Step 5:** Migration committed + lokal getestet
- [ ] **Step 6:** Kein `service_role` im Client-Code (`grep -r "service_role" lib/` → keine Treffer)

**Evidence:**
[Screenshots/Terminal-Output hier einfügen]
```

---

## Weiterführende Links

- **Supabase RLS Docs:** https://supabase.com/docs/guides/auth/row-level-security
- **PostgreSQL RLS Docs:** https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- **ADR-0002 (LUVI):** `context/ADR/0002-least-privilege-rls.md`
- **BMAD-Template (RLS-Sektion):** `context/templates/bmad-template.md#architektur`

---

## Changelog

**v1.0 (2025-10-03):**
- Initial Runbook (6 Steps: RLS ON → Policies → Trigger → Tests → Migration → Häufige Fehler)
- Aligned mit ADR-0002 (Least-Privilege), BMAD-Template, DoD
