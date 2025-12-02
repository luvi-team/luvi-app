# Agents Index (Codex Interop)

Dies ist der Index für Codex (/status) und das Onboarding.

Dieses Repo arbeitet mit zwei aktiven Dev-Agenten:
- **Codex CLI** – Backend/API, Supabase/DB-Administration, Privacy/QA sowie technischer Reviewer.
- **Claude Code** – UI-Frontend & Dataviz (Flutter Screens, Widgets, Charts) mit DSGVO-Awareness.

Beide Agenten teilen dieselben SSOT-Quellen: `AGENTS.md`, `context/agents/*` inkl. `01–05`, `_acceptance_v1.1.md`, BMAD (`docs/bmad/global.md` + Sprint-BMADs), `docs/product/app-context.md`, `docs/product/roadmap.md`, `docs/engineering/assistant-answer-format.md`, `docs/engineering/ai-reviewer.md`.

Scope & Nutzung: Gilt ab Repo-Root rekursiv; Default Auto-Role; Misch-Tasks via `role: …`; SSOT Acceptance v1.1.

## First 5 Minutes (Quickstart für Agents)

- LUVI ist eine Flutter/Riverpod-App mit Supabase-Backend und eigenem Design System; dieses Repo bündelt UI-Screens, Services und Supabase-Migrationen.
- Claude Code: Öffne `CLAUDE.md`, die UI-Checkliste (`docs/engineering/checklists/ui_claude_code.md`) sowie die Dossiers `context/agents/01-ui-frontend.md`/`04-dataviz.md`; scanne `lib/core/design_tokens`, `lib/core/theme`, `lib/core/widgets` und `lib/features/onboarding|dashboard|consent` für Patterns und führe `scripts/flutter_codex.sh analyze` plus `scripts/flutter_codex.sh test -j 1` aus (Details siehe BMAD & Acceptance).
- Codex: Lies `AGENTS.md`, die Dossiers `context/agents/02-*`, `03-*`, `05-*`, BMAD (`docs/bmad/global.md`) und `context/agents/_acceptance_v1.1.md`; checke Backend-/Privacy-Code unter `lib/features/**/state|data|domain`, `services/lib/**` und `supabase/migrations`, beachte Required Checks (Flutter analyze-test, privacy-gate, Greptile, Vercel Health) und folge BMAD → PRP.

Governance
- Dossiers (01–05): context/agents/README.md
- SSOT Acceptance v1.1 (Core + Role extensions): context/agents/_acceptance_v1.1.md
 - SSOT (Product): docs/product/app-context.md · docs/product/roadmap.md

Empfohlene Lesereihenfolge (für neue Devs/Agents)
1. `docs/product/app-context.md` – Was LUVI ist und für wen.
2. `docs/product/roadmap.md` – Welche Sprints/Phasen es gibt.
3. `docs/engineering/tech-stack.md` – Wie der Stack aufgebaut ist.
4. `AGENTS.md` + `context/agents/*` – Rollen, Governance, DoD/Checks.

Arbeitsweise
- Codex CLI-first; BMAD → PRP (Plan → Run → Prove).
- Required Checks (GitHub): Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · Greptile Review (Required Check) · Vercel Preview Health (200 OK).
- AI review setup (Greptile merge gate, optional local CodeRabbit) is defined in docs/engineering/ai-reviewer.md. If anything else contradicts it, ai-reviewer.md wins.
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

Quickstart (SSOT)
- Einstieg/Links siehe `README.md:1` → App‑Kontext, Tech‑Stack, Roadmap, Gold‑Standard (inkl. „Praktische Anleitung · Ultra‑Slim“)

Rollenwahl
- Default: Auto-Role (ankündigen). Misch-Tasks: `role: …` (Primärrolle zuerst).
- Auto-Role Map (SSOT): `context/agents/_auto_role_map.md`
- Traycer (optional, Features): `docs/engineering/traycer/prompt-mini.md`

## Agent-Binding (Rollen → Agenten)

- `ui-frontend` → Primär: Claude Code (Frontend/Dataviz), Review: Codex
- `dataviz` → Primär: Claude Code, Review: Codex
- `api-backend` → Primär: Codex
- `db-admin` → Primär: Codex
- `qa-dsgvo` → Primär: Codex

Codex übernimmt UI/Dataviz-Aufgaben nur, wenn Claude Code nicht verfügbar ist (z. B. Modell-/Token-Limits).

### Codex CLI (Backend + Review)

- Primär für: `api-backend`, `db-admin`, `qa-dsgvo`.
- Review-Agent für PRs von Claude Code (`ui-frontend`/`dataviz`); Merge nur nach Codex-Freigabe.
- Arbeitet strikt nach BMAD → PRP und nutzt `scripts/flutter_codex.sh` für Analyze/Test (sandboxed), Supabase-MCP für DB/RLS/Policies sowie Archon/MCP für Tasks & Wissensarbeit.
- Governance-Quellen: `AGENTS.md`, `context/agents/*` (Dossiers, DoD, ADRs, SSOT v1.1) + BMAD + Produkt-SSOTs.
- Legacy-Hinweis: ehemalige Claude-Assets liegen archiviert unter `context/archive/claude-code-legacy/`.

### Claude Code (Frontend / Dataviz)

- Primär für: `ui-frontend`, `dataviz`.
- Governance: `AGENTS.md`, `CLAUDE.md` im Repo-Root sowie `context/agents/01-ui-frontend.md` und `context/agents/04-dataviz.md`.
- PRs gehen vor dem Merge immer an Codex zur technischen Review + CI/Governance-Checks.

Work-Modes (informell, Dual-Agent)
- **High Impact** (DB/PII/AI/Security): Codex führt, volle BMAD/PRP-Ceremony, passende Tests, Privacy-Review/DSGVO-Check; Claude Code liefert UI-Support nur nach Abstimmung.
- **Normale Features**: UI/Dataviz → Claude Code implementiert & dokumentiert BMAD-slim gemäß `CLAUDE.md`, Codex reviewed; Backend/DB → Codex implementiert, Required Checks (Greptile/CI) als Gate.
- **Micro-Tasks**: reine UI-/Copy-Fixes ohne State → Claude Code (Analyze + betroffene Tests); Backend-only/infra-Fixes → Codex (Analyze/Test scope passend).
  - Quick-Ref: High Impact → Codex Ownership, ≥Unit+Widget Tests; Normale Features → Agent nach Domäne, Traycer optional; Micro-Tasks → schlanker Analyze/Test je Domäne.
- Soft-Gates: `reqing-ball` vor High-Impact-Backend/DB/Privacy-Features zur Anforderungs-Schärfung; `ui-polisher` nach neuen Screens/komplexen UI-Diffs vor Codex-Review für Token/A11y-Checks.

RAG-Nutzung & Fallback (für Codex)
- Standard: Kontext zuerst über Archon/MCP laden (Dossiers & SSOTs), bevor du Code entwirfst oder Migrations vorschlägst.
- Typische Beispiele:
  - DB/Supabase: Supabase-Schema + ADR-0002 (Least-Privilege & RLS) + Tech-Stack (Backend/Infra).
  - Privacy/Consent: Safety & Scope (v1.0), Consent-Texte (v1.1), App-Kontext (Datenschutz-Abschnitt).
  - Feed/Ranking/Phase: App-Kontext (Pillars & Ziele), Phase-Definitionen (v1.1), Ranking-Heuristik (v1.1), Agents & Tools (Agent-Contracts).
- Fallback: Wenn Archon/MCP nicht verfügbar ist, arbeite direkt mit den SSOT-Dokumenten im Repo (App-Kontext, Roadmap, Tech-Stack, Dossiers v1.x) und beschreibe im Plan kurz, welche Quellen du verwendet hast.

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
