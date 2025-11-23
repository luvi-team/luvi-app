# MCP Setup (read-only, dev)

## Einrichtung (Codex CLI)

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

3. **Verifikation:** Datei prüfen (`cat ~/.mcp/config.json`) und Codex CLI neu starten, sodass MCP geladen wird.

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

### Codex CLI: Connection Error
1. ✅ `~/.mcp/config.json` existiert?
2. ✅ `project_ref` in URL korrekt? (Supabase Dashboard → Settings → API)
3. ✅ Netzwerk-Verbindung zu `mcp.supabase.com`?

---

## Security & Best Practices

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
