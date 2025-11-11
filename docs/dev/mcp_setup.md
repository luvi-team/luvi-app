# MCP Setup (read-only, dev)

1. **Lokale Config anlegen (außerhalb des Repos):** Kopiere `mcp/supabase.mcp.json.example` nach `~/.mcp/supabase.json` (oder den MCP-Config-Pfad deines Agents) und passe sie lokal an. **Keine Secrets committen.**
2. **Scope:** Die Verbindung ist read-only gegen **`luvi-dev`** (`project_ref=cwloioweaqvhibuzdwpi`) und auf die Features `database,docs` limitiert.
3. **Erlaubt vs. verboten:**  
   - Erlaubt: Schema lesen (`describe_*`), SQL erklären (`explain_sql`), Migrations planen/dry-run (`plan_migration`, `run_migration_dry_run`).  
   - Verboten: jegliche Writes (`execute_sql_write`, `run_migration`), Prod-Verknüpfungen und andere Supabase-Projekte.  
   - Grundlage: `context/ADR/0002-least-privilege-rls.md` (Least-Privilege RLS).
4. **Working Agreement:** MCP liefert nur Hinweise. Jede DB-Änderung läuft über **PR → Supabase DB Dry-Run → Apply (dev) → RLS-Smoke**. Prod wird nie direkt via MCP angefasst.
5. Bei Unsicherheiten intern rückfragen; Config-Dateien bleiben lokal.
