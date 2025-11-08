# Agents Index (Codex Interop)

Dies ist der Index für Codex (/status) und das Onboarding.

Scope & Nutzung: Gilt ab Repo-Root rekursiv; Default Auto-Role; Misch-Tasks via `role: …`; SSOT Acceptance v1.1.

Governance
- Dossiers (01–05): context/agents/README.md
- SSOT Acceptance v1.1 (Core + Role extensions): context/agents/_acceptance_v1.1.md
 - SSOT (Product): docs/product/app-context.md · docs/product/roadmap.md

Arbeitsweise
- Codex CLI-first; BMAD → PRP (Plan → Run → Prove).
- Required Checks (GitHub): Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · CodeRabbit · Vercel Preview Health (200 OK).
- Acceptance pro Rolle: „Core + Role extension“ gemäß SSOT v1.1.
- Antwortformat: verbindlich gemäß `docs/engineering/assistant-answer-format.md`.
- CI-Pflegezyklus: Actions-Pinning (checkout/upload-artifact/github-script) quartalsweise prüfen/aktualisieren; siehe `context/agents/_actions_todo.md`.
 - Branch-Strategie: kurze Feature-Branches, Squash & Merge, Required Checks als Gate (Trunk‑Based, stabiler Main).

Global Rules (Archon-first)
- Vor jedem Coding: Archon-Tasks prüfen → Taskstatus pflegen (todo→doing→review→done).
- RAG vor Implementierung (2–5 Stichworte, kurze Queries).
- Dossiers zuerst lesen: Phase-Definitionen, Consent, Ranking.
- PR: Dossier-Versionen/Links angeben.
- Keine globalen ENV in Shell; Secrets in projekt-lokalen `.env`.

Tooling (Flutter, Sandbox)
- Für Codex CLI sind Flutter-Läufe über `scripts/flutter_codex.sh` auszuführen (Analyse/Tests).
- Das Script kapselt `HOME`/`PUB_CACHE` in `.tooling/*` und deaktiviert Telemetrie; für `analyze`/`test` wird standardmäßig `--no-pub` gesetzt.
- `flutter test` benötigt ggf. Approval „ohne Sandbox“ (Loopback-Socket auf `127.0.0.1`).
- Beispiele: `scripts/flutter_codex.sh analyze`, `scripts/flutter_codex.sh test -j 1`.
- Optional (Build/Signing/Performance): `CODEX_USE_REAL_HOME=1 scripts/flutter_codex.sh <cmd>` nutzt das echte `$HOME` und den Default‑`PUB_CACHE` (z. B. `~/.gradle`, `~/.cocoapods`, `~/.pub-cache`).
  - Empfohlen nur außerhalb strenger Sandbox oder mit Approval; Analyze/Test bleiben standardmäßig im sicheren Modus.

## Flutter Test Execution Policy (MVP)
- Analyze bleibt sandboxed: `scripts/flutter_codex.sh analyze` (telemetry off, `--no-pub`).
- Tests sind erlaubt „ohne Sandbox“ ausschließlich über den Wrapper:
  - Erlaubt: `scripts/flutter_codex.sh test -j 1` (Loopback‑Socket auf `127.0.0.1` erforderlich; kein externer Netzverkehr).
  - Der Assistent kündigt Testläufe an und eskaliert mit Begründung „Loopback‑Socket nötig“. Session‑weite Einmal‑Freigabe ist zulässig.
  - Tests müssen offline sein (keine externen HTTP‑Calls). Bei Bedarf `--offline` nutzen oder Netzwerk via Mocks/`HttpOverrides` stubben.
- Stabilität/Performance:
  - Standard: `-j 1` um lokale Port/Isolate‑Flakes zu vermeiden; Ressourcen über `rootBundle`/Fixtures.
  - Paketverwaltung bleibt im sicheren Modus (`--no-pub`); Abhängigkeiten werden nicht während Tests aktualisiert.
- Safety‑Rails:
  - Keine Schreibzugriffe außerhalb des Repos; HOME/PUB_CACHE sind auf `.tooling/*` gesetzt.
  - Optional eskalieren: `CODEX_USE_REAL_HOME=1` ist für Tests nicht erforderlich und soll nicht genutzt werden.

Rollenwahl
- Default: Auto-Role (ankündigen). Misch-Tasks: `role: …` (Primärrolle zuerst).
- Auto-Role Map (SSOT): `context/agents/_auto_role_map.md`
- Traycer (optional, Features): `docs/engineering/traycer/prompt-mini.md`

Dual-Primary (Codex + Claude Code)
- **Codex CLI:** Nutzt AGENTS.md (diese Datei). Auto-Role via `/status`.
- **Claude Code:** Nutzt CLAUDE.md. Auto-Role gemäß SSOT‑Map: `context/agents/_auto_role_map.md`.
- **Shared Governance:** Beide nutzen context/agents/* (Dossiers, DoD, ADRs, SSOT v1.1).
- **Workflow:** Beide befolgen BMAD → PRP (Plan → Run → Prove).

Legacy (nur historisch)
- .claude/agents/* = Vor Codex-Umstellung, nicht mehr operativ.

Archon IDE Global Rules
- MCP-Server prüfen; Archon als Primärsystem nutzen.
- Task-Flow befolgen: `find_tasks` → `manage_task(status=doing)` → implementieren → `manage_task(status=review)` → `manage_task(status=done)`.
- RAG-Workflow anwenden: `rag_get_available_sources` → `rag_search_knowledge_base(query, source_id?)`.
- Tool-Referenz:
  - `find_projects`
  - `find_tasks`
  - `manage_task`
  - `rag_*`
- Queries kurz halten: 2–5 Keywords, keine langen Sätze.
