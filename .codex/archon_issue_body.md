---
# Archon  S0.5 Foundation – MCP-Connect, Dossiers, RAG & Kanban

**Warum (Sinn & Nutzen)**  
Archon ist unser **Kommando-Zentrum** für AI-Coding: kuratiertes Wissen (RAG), **Tasks/Kanban** und **MCP-Schnittstelle** für Agenten (Claude Code, Codex). Ergebnis: **konsistente Antworten**, reproduzierbare Workflows, weniger Drift ("Archon-first").

**Was bereits erledigt ist**
- **Install & Start**: Docker Compose (UI 3737, MCP 8051, API 8181) – healthy.
- **Settings**: Chat = **Anthropic (Claude 3.5 Haiku)**, Embeddings = **Google/Gemini `text-embedding-004`**, Hybrid/Reranking/Contextual Embeddings **ON**.
- **MCP-Connect**: `claude mcp add …` und Codex-Konfiguration; `find_projects/find_tasks` liefern Ergebnisse.
- **Knowledge (extern)**: Supabase-RLS/Policies/Best-Practices als gezielte URLs; Chunks/Embeddings hoch (Index **OK**).
- **Dossiers (intern)**: `phase_definitions.md`, `consent_texts.md (v1.1 DPF)`, `ranking_heuristic.md`; als **Projekt-Dokumente** verknüpft (Titel & Version aktualisiert).
- **Qualitäts-Aufräumen**: Ältere Consent-Quelle (mit TODO) **gelöscht** → RAG liefert nur noch **v1.1**.
- **Kanban-Flow**: Projekt „MVP-Onboarding“ + 3 Tasks (Consent-Copy, Phasenlogik spiegeln, A/B-Kurz-Consent); Statuswechsel via MCP verifiziert.

**Scope dieses Issues (Produktionalisierung/Feinschliff)**
1) **Knowledge konsolidieren**
   - Optional: Kombi-Quelle `LUVI_Dossiers_v1.1.md` hochladen (1 Upload statt 3).
   - Quellen **taggen/benennen** (z. B. `internal`, `SSOT`, `v1.1`, `consent`, `supabase`, `rls`, `policy`).
   - Doppelte/alte Knowledge-Karten **archivieren/löschen** (verhindert Misch-Snippets).
2) **MCP in beiden Repo-Kontexten**
   - Claude MCP auch im **LUVI-Repo-Ordner** registrieren (nicht nur im Archon-Ordner), damit Agenten in App-Kontext sofort Archon nutzen.
3) **RAG-Smokes (kurz, echte Queries)**
   - "row level security", "auth.uid() policy example", "policy USING WITH CHECK", "Consent DE short".
   - Erwartung: 1–3 sinnvolle Snippets + Quelle/URL je Query.
4) **IDE Global Rules & Workflows**
   - Archon-„IDE Global Rules“ in `AGENTS.md`/`CLAUDE.md` spiegeln (Archon-first; Task-Zyklus; RAG vor Coding).
   - `PLANNING.md` & `EXECUTION.md` kurz finalisieren.
5) **Docs/README**
   - Kurzer Abschnitt „Archon usage“ + Troubleshooting (Env-Vorrang `.env` vs. Shell, Knowledge „Indexed“, Duplicate sources).

**Akzeptanzkriterien (DoD)**
- Knowledge-Liste: **nur aktuelle** Consent-Quelle (v1.1) aktiv; Tags gesetzt; optional Kombi-Quelle vorhanden.
- MCP-Connect auch im **LUVI-Repo** verifiziert (`claude mcp list`).
- RAG-Smokes liefern je Query ≥1 sinnvolles Snippet (mit Quelle/URL); „Consent DE short“ zeigt v1.1-Text.
- `AGENTS.md` enthält Archon-IDE-Regeln; `PLANNING.md`/`EXECUTION.md` liegen vor.
- README-Abschnitt „Archon usage“ + Troubleshooting ergänzt.

**Troubleshooting (Kurz)**
- **Falsche Supabase-URL** in Shell-ENV überschreibt `.env` → Shell-Vars entfernen; Compose neu starten.
- **RAG 0 Treffer** → prüfen, ob Quelle **Indexed** ist und Query kurz halten (2–5 Keywords).
- **Consent-Mischung** → alte Knowledge-Karte **archivieren/löschen**; nur v1.1 aktiv lassen.

**Nächste Schritte**
- [ ] Quellen taggen/benennen; alte Consent-Karte archivieren/löschen
- [ ] (Optional) `LUVI_Dossiers_v1.1.md` hochladen
- [ ] MCP auch im LUVI-Repo registrieren und verifizieren
- [ ] RAG-Smokes (4 Queries) ausführen & Ergebnisse dokumentieren
- [ ] `AGENTS.md`/`PLANNING.md`/`EXECUTION.md` finalisieren
- [ ] README „Archon usage“ + Troubleshooting ergänzen

_Assignee:_ <@your-username>  
_Komponenten:_ knowledge-base, mcp, docs, governance
---
