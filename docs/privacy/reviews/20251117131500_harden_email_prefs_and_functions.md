# Privacy Review — 20251117131500_harden_email_prefs_and_functions

## Change
- Pin `search_path` für optionale Helfer-/Archon-Funktionen via DO-Block mit `IF EXISTS`-Checks.
- Aktualisiere die vier `email_preferences`-Policies, um `(user_id = (SELECT auth.uid()))` zu nutzen.
- Ergänze `IF NOT EXISTS`-Index für `public.archon_tasks(parent_task_id)`.

## Data Impact
- **Keine neuen Tabellen/Spalten**
- **Keine zusätzlichen Datenlese-/schreibpfade**
- Trigger- und Helper-Funktionskörper bleiben unverändert.

## Purpose / Risk
- Hardening: schützt vor `search_path`-Hijacking und Migrationsfehlern bei fehlenden optionalen Funktionen.
- Reduziert RLS-Overhead, indem per-row-`auth.*()`-Aufrufe vermieden werden.
- Risiko: kein funktionales Privacy-Risiko; Verhalten der RLS-Logik bleibt semantisch gleich.

## RLS / Access Control
- Owner-basierte RLS auf `email_preferences` (`user_id = auth.uid()`) bleibt erhalten.
- Policies nutzen nun Subquery-Pattern `(SELECT auth.uid())` gemäß Supabase-RLS-Best Practices.

## DPIA/DSGVO
- Keine Änderung am Verarbeitungsumfang oder an Datenkategorien.
- Keine neuen Auftragsverarbeiter/Transfers.

## Result
- ✅ Privacy- und sicherheitsfördernde Migration; keine weiteren Maßnahmen erforderlich.
