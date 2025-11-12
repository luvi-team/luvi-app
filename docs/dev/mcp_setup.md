# MCP Setup (read-only, dev)

## Für Claude Code (CLI-basiert, empfohlen)

### 1. Supabase MCP Server hinzufügen
```bash
claude mcp add --transport http supabase https://mcp.supabase.com/mcp
```

### 2. Verifikation
```bash
claude mcp list
# Sollte zeigen: supabase: https://mcp.supabase.com/mcp (HTTP) - ⚠ Needs authentication
```

### 3. Claude Code neu starten
Beende Claude Code vollständig (Menü → Quit) und öffne es neu.

### 4. OAuth-Authentifizierung (automatisch)
Beim ersten Zugriff auf Supabase MCP (z.B. `/MCP` command):
1. Browser-Fenster öffnet sich automatisch
2. Login mit Supabase-Account
3. Organization-Zugriff gewähren
4. Projekt wählen (`luvi-dev`)

**KEIN Access Token nötig!** OAuth-Flow läuft automatisch.

### 5. Verifikation
Nach Neustart: `/MCP` command → "supabase" sollte in der Liste erscheinen.

---

## Für Codex CLI (URL-Parameter-basiert)

1. **Lokale Config anlegen (außerhalb des Repos):** Kopiere `mcp/supabase.mcp.json.example` nach `~/.mcp/config.json` und passe sie lokal an. **Keine Secrets committen.**

2. **Config-Format:**
```json
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=${PROJECT_REF}&read_only=1&features=database,docs"
    }
  }
}
```

**Hinweis:** Ersetze `${PROJECT_REF}` mit deinem Supabase Project Reference (z.B. `cwloioweaqvhibuzdwpi` für `luvi-dev`).

---

## Details & Sicherheit

- **Projekt:** `luvi-dev` (project_ref: siehe Supabase Dashboard → Settings → API)
- **Mode:** Read-only by design
- **Erlaubt:** Schema lesen (`describe_*`), SQL erklären (`explain_sql`), Migrations planen (`plan_migration`, `run_migration_dry_run`)
- **Verboten:** Write Operations (`execute_sql_write`, `run_migration`), Production-Zugriffe
- **Grundlage:** `context/ADR/0001-rag-first.md` (RAG-First), `context/ADR/0002-least-privilege-rls.md` (Least-Privilege RLS)

## Working Agreement

MCP liefert nur Hinweise. Jede DB-Änderung läuft über **PR → Supabase DB Dry-Run → Apply (dev) → RLS-Smoke**. Prod wird nie direkt via MCP angefasst.

---

## Troubleshooting

### Claude Code: "supabase" nicht in /MCP sichtbar
1. ✅ Via CLI hinzugefügt? (`claude mcp add ...`)
2. ✅ Claude Code neu gestartet? (vollständig beenden + neu öffnen)
3. ✅ OAuth-Flow durchgeführt? (Browser-Fenster sollte sich automatisch öffnen)
4. ✅ Verifikation: `claude mcp list` sollte "supabase" zeigen

### Codex CLI: Connection Error
1. ✅ `~/.mcp/config.json` existiert?
2. ✅ `project_ref` in URL korrekt? (Supabase Dashboard → Settings → API)
3. ✅ Netzwerk-Verbindung zu `mcp.supabase.com`?

---

## Security & Best Practices

### OAuth-Schutz (Claude Code)
- ✅ **Keine Secrets im Repo:** MCP-Config via CLI (intern gespeichert in `~/.claude.json`)
- ✅ **OAuth-Flow:** Browser-Login mit Supabase-Account (kein hardcoded Token)
- ✅ **Read-only by design:** Keine destructive Operations möglich

### project_ref ist KEIN Secret
- ℹ️ `project_ref` ist ein **öffentlicher Identifier** (wie eine URL)
- ℹ️ Secrets sind: `anon_key`, `service_role_key`, OAuth Tokens
- ✅ Sicher in Dokumentation/Beispielen zu verwenden

### Least-Privilege Prinzip (ADR-0002)
- ✅ **Read-only Mode:** Migrations nur als Dry-Run
- ✅ **No Write Access:** `execute_sql_write`, `run_migration` blockiert
- ✅ **Dev-only:** Keine Production-Zugriffe

### Best Practice: Example File
- ✅ `mcp/supabase.mcp.json.example` committed (Template für Codex CLI)
- ✅ Warnung: "NEVER commit secrets" im File
- ✅ Lokale Config außerhalb Repo (`~/.mcp/config.json`)
