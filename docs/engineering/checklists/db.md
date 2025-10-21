# DB‑Admin Checklist (Supabase · Postgres · RLS)

Ziel: Least‑Privilege mit RLS, saubere Migrationen, DSGVO‑Sicherung (Retention/Pseudonymisierung).

RLS & Ownership
- Tabellen mit RLS aktiv; Owner‑Policies (`user_id = auth.uid()`) für SELECT/INS/UPD/DEL.
- Trigger `set_user_id_from_auth()` (BEFORE INSERT) setzt `user_id`; `search_path` pinnen.
- Keine `service_role` im Client; Admin‑Rollen minimal, kein `BYPASSRLS` außerhalb Server.

Migrationen
- Idempotent (IF EXISTS/IF NOT EXISTS); bei riskanten ALTER → Add‑Copy‑Switch Pattern.
- Zero‑Downtime: `CREATE INDEX CONCURRENTLY`; Backups/PITR vor kritischen Changes.
- Drift vermeiden: Hotfix‑SQL zurück in Migrationen; Staging‑Test mit Produktionsnähe.

Datenqualität & Performance
- CHECK/FK/UNIQUE konsequent; FK‑Spalten indexiert; Partial‑Indexes für Hot‑Daten.
- Partitionierung nur bei sehr großen Tabellen/Time‑Series.

Privacy & Retention
- Pseudonymisierung/Hashing wo möglich; Spaltenschutz für sensible Felder.
- Retention‑Jobs (Löschung/Anonymisierung) nach Zweck; Backups mit Ablauf.

RLS‑Probe (Kurz)
- `SET ROLE authenticated; SET LOCAL "request.jwt.claim.sub" = '<uuid>';` → nur eigene Zeilen sichtbar.
- Als `anon` → 0 Zeilen/Verbot; Views/Funktionspfade respektieren RLS.

Quick Wins
- Trigger/Search‑Path‑Härtung; FK‑Index‑Audit; RLS‑Smoke‑Snippets ins Runbook übernehmen.

Verweise
- Runbook: `docs/runbooks/debug-rls-policy.md`

