# ADR-0001: RAG-First Wissenshierarchie
Status: Accepted
Kontext: Halluzinationen vermeiden; verlässliche Quellen erzwingen.
Entscheidung: Reihenfolge 1) RAG/Docs, 2) Codebase, 3) Extern (Research), 4) LLM-Wissen.
Konsequenzen: Referenzen in /context/refs pflegen; Prompts verweisen auf RAG vor LLM.
Changelog:
- 2025-11-12: Supabase MCP (read-only, OAuth-basiert) integriert für Claude Code → Schema/Docs/SQL-Erklärungen als RAG-Quelle. Setup via `claude mcp add` CLI.
- 2025-11-23: Claude Code als Client entfernt; RAG (Supabase MCP, Archon) wird nur noch von Codex CLI genutzt.
- 2025-12-??: Claude Code als aktiver UI/Frontend-Agent reaktiviert; nutzt dieselben RAG-Quellen (Archon/MCP, BMAD) wie Codex. MCP-basierte DB/RLS-Operationen bleiben primär Codex vorbehalten.
