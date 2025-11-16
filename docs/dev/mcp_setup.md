# MCP Setup für Supabase

1. Kopiere `mcp/supabase.mcp.json.example` nach `~/.mcp/supabase.mcp.json` (oder den MCP-Config-Pfad deines Editors/Agents, z. B. Claude Code oder Cursor) und aktiviere ihn dort.
2. Verbindung ist read-only und auf `database,docs` limitiert; nutze sie nur gegen das `luvi-dev`-Projekt (`project_ref=cwloioweaqvhibuzdwpi`).
3. Erlaubte Calls: `list_tables`, `list_migrations`, `list_extensions`, `execute_sql` (nur `SELECT`/`EXPLAIN`). Siehe `context/ADR/0002-least-privilege-rls.md` (Least-Privilege RLS) als Begründung für die Read-Only-Restriktion.
4. Schreibende Tools oder Prod-Instanzen sind untersagt – keine `INSERT/UPDATE/DELETE`, kein Zugriff auf andere Supabase-Projekte.
5. Bei Unsicherheiten erst intern rückfragen; Config-Datei niemals ins Repo committen.
