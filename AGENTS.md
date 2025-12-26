# Agents Index (Codex Interop)

This is the index for Codex (/status) and onboarding.

This repository works with three active dev agents:
- **Gemini** – Architect & Orchestrator for system-wide analysis, planning, and governance.
- **Codex CLI** – Backend/API, Supabase/DB administration, Privacy/QA, and technical reviewer.
- **Claude Code** – UI-Frontend & Dataviz (Flutter screens, widgets, charts) with GDPR awareness.

All three agents share the same SSOT sources: `AGENTS.md`, `context/agents/*` including `01–05`, `_acceptance_v1.1.md`, BMAD (`docs/bmad/global.md` + Sprint BMADs), `docs/product/app-context.md`, `docs/product/roadmap.md`, `docs/engineering/assistant-answer-format.md`, `docs/engineering/ai-reviewer.md`.

Scope & Usage: Applies from repo root recursively; Default Auto-Role; Mixed tasks via `role: …`; SSOT Acceptance v1.1.

## First 5 Minutes (Quickstart for Agents)

- LUVI is a Flutter/Riverpod app with Supabase backend and custom design system; this repo bundles UI screens, services, and Supabase migrations.
- Claude Code:
  - Open `CLAUDE.md` and the UI checklist (`docs/engineering/checklists/ui_claude_code.md`)
  - Read dossiers: `context/agents/01-ui-frontend.md` and `04-dataviz.md`
  - Scan code patterns: `lib/core/design_tokens`, `lib/core/theme`, `lib/core/widgets` and `lib/features/onboarding|dashboard|consent`
  - Run: `scripts/flutter_codex.sh analyze` and `scripts/flutter_codex.sh test -j 1`
  - Details: see BMAD & Acceptance
- Codex:
  - Read `AGENTS.md`, BMAD Global (`docs/bmad/global.md`) and Acceptance (`context/agents/_acceptance_v1.1.md`)
  - Read dossiers: `context/agents/02-api-backend.md`, `03-db-admin.md`, `05-qa-dsgvo.md`
  - Scan code patterns: `lib/features/**/state|data|domain`, `services/lib/**`, `supabase/migrations`
  - Run: `scripts/flutter_codex.sh analyze` and `scripts/flutter_codex.sh test -j 1`
  - Note Required Checks: Flutter analyze-test, privacy-gate, Greptile, Vercel Health
  - Workflow: BMAD → PRP (Plan → Run → Prove)

Governance
- Dossiers (01–05): context/agents/README.md
- SSOT Acceptance v1.1 (Core + Role extensions): context/agents/_acceptance_v1.1.md
- SSOT (Product): docs/product/app-context.md · docs/product/roadmap.md

Recommended Reading Order (for new devs/agents)
1. `docs/product/app-context.md` – What LUVI is and who it's for.
2. `docs/product/roadmap.md` – Which sprints/phases exist.
3. `docs/engineering/tech-stack.md` – How the stack is structured.
4. `AGENTS.md` + `context/agents/*` – Roles, governance, DoD/checks.

Workflow
- Codex CLI-first; BMAD → PRP (Plan → Run → Prove).
- Required Checks (GitHub): Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · Greptile Review (Required Check) · Vercel Preview Health (200 OK).
- AI review setup (Greptile merge gate, optional local CodeRabbit) is defined in docs/engineering/ai-reviewer.md. If anything else contradicts it for AI review/CI policy, ai-reviewer.md wins.
- Acceptance per role: "Core + Role extension" per SSOT v1.1.
- Answer format: binding per `docs/engineering/assistant-answer-format.md`.
- CI maintenance cycle: Actions pinning (checkout/upload-artifact/github-script) check/update quarterly; see `context/agents/_actions_todo.md`.
- Branch strategy: short feature branches, Squash & Merge, Required Checks as gate (Trunk-Based, stable Main).

Global Rules (Archon-first)
- Before any coding: Check Archon tasks → Maintain task status (todo→doing→review→done).
- RAG before implementation (2–5 keywords, short queries).
- Read dossiers first: Phase definitions, Consent, Ranking.
- PR: Include dossier versions/links.
- No global ENV in shell; Secrets in project-local `.env`.

Tooling (Flutter, Sandbox)
- For Codex CLI, run Flutter via `scripts/flutter_codex.sh` (analysis/tests).
- The script encapsulates `HOME`/`PUB_CACHE` in `.tooling/*` and disables telemetry; for `analyze`/`test`, `--no-pub` is set by default.
- `flutter test` may require approval "without sandbox" (loopback socket on `127.0.0.1`).
- Examples: `scripts/flutter_codex.sh analyze`, `scripts/flutter_codex.sh test -j 1`.
- Optional (Build/Signing/Performance): `CODEX_USE_REAL_HOME=1 scripts/flutter_codex.sh <cmd>` uses the real `$HOME` and default `PUB_CACHE` (e.g., `~/.gradle`, `~/.cocoapods`, `~/.pub-cache`).
  - Recommended only outside strict sandbox or with approval; Analyze/Test remain in safe mode by default.

## Flutter Test Execution Policy (MVP)
- Analyze remains sandboxed: `scripts/flutter_codex.sh analyze` (telemetry off, `--no-pub`).
- Tests are allowed "without sandbox" exclusively via the wrapper:
  - Allowed: `scripts/flutter_codex.sh test -j 1` (loopback socket on `127.0.0.1` required; no external network traffic).
  - The assistant announces test runs and escalates with reason "loopback socket needed". Session-wide one-time approval is permitted.
  - Tests must be offline (no external HTTP calls). Use `--offline` if needed or stub network via Mocks/`HttpOverrides`.
- Stability/Performance:
  - Default: `-j 1` to avoid local port/isolate flakes; resources via `rootBundle`/fixtures.
  - Package management remains in safe mode (`--no-pub`); dependencies are not updated during tests.
- Safety Rails:
  - No writes outside the repo; HOME/PUB_CACHE are set to `.tooling/*`.
  - Optional escalation: `CODEX_USE_REAL_HOME=1` is not required for tests and should not be used.

Quickstart (SSOT)
- Entry/links see `README.md:1` → App Context, Tech Stack, Roadmap, Gold Standard (including "Practical Guide · Ultra-Slim")

Role Selection
- Default: Auto-Role (announce). Mixed tasks: `role: …` (primary role first).
- Auto-Role Map (SSOT): `context/agents/_auto_role_map.md`
- Traycer (optional, features): `docs/engineering/traycer/prompt-mini.md`

## Agent-Binding (Roles → Agents)

- **architect-orchestrator** → Primary: Gemini, Review: Human
- `ui-frontend` → Primary: Claude Code (Frontend/Dataviz), Review: Codex
- `dataviz` → Primary: Claude Code, Review: Codex
- `api-backend` → Primary: Codex
- `db-admin` → Primary: Codex
- `qa-dsgvo` → Primary: Codex

Codex takes over UI/Dataviz tasks only when Claude Code is unavailable (e.g., model/token limits).

### Codex CLI (Backend + Review)

- Primary for: `api-backend`, `db-admin`, `qa-dsgvo`.
- Review agent for PRs from Claude Code (`ui-frontend`/`dataviz`); merge only after Codex approval.
- Works strictly according to BMAD → PRP and uses `scripts/flutter_codex.sh` for Analyze/Test (sandboxed), Supabase-MCP for DB/RLS/Policies, and Archon/MCP for tasks & knowledge work.
- Governance sources: `AGENTS.md`, `context/agents/*` (Dossiers, DoD, ADRs, SSOT v1.1) + BMAD + Product SSOTs.
- Legacy note: Former Claude assets are archived under `context/archive/claude-code-legacy/`.

### Claude Code (Frontend / Dataviz)

- Primary for: `ui-frontend`, `dataviz`.
- Governance: `AGENTS.md`, `CLAUDE.md` in repo root, and `context/agents/01-ui-frontend.md` and `context/agents/04-dataviz.md`.
- PRs always go to Codex for technical review + CI/governance checks before merge.

Work-Modes (informal, Dual-Agent)
- **High Impact** (DB/PII/AI/Security): Codex leads, full BMAD/PRP ceremony, appropriate tests, Privacy-Review/GDPR check; Claude Code provides UI support only after coordination.
- **Normal Features**: UI/Dataviz → Claude Code implements & documents BMAD-slim per `CLAUDE.md`, Codex reviews; Backend/DB → Codex implements, Required Checks (Greptile/CI) as gate.
- **Micro-Tasks**: Pure UI/copy fixes without state → Claude Code (Analyze + affected tests); Backend-only/infra fixes → Codex (Analyze/Test scope as appropriate).
  - Quick-Ref: High Impact → Codex Ownership, ≥Unit+Widget Tests; Normal Features → Agent by domain, Traycer optional; Micro-Tasks → lean Analyze/Test per domain.
- Soft-Gates: `reqing-ball` before High-Impact Backend/DB/Privacy features for requirements clarification; `ui-polisher` after new screens/complex UI diffs before Codex review for Token/A11y checks.

RAG Usage & Fallback (for Codex)
- Standard: Load context via Archon/MCP first (Dossiers & SSOTs) before designing code or proposing migrations.
- Typical examples:
  - DB/Supabase: Supabase schema + ADR-0002 (Least-Privilege & RLS) + Tech-Stack (Backend/Infra).
  - Privacy/Consent: Safety & Scope (v1.0), Consent texts (v1.1), App-Context (Privacy section).
  - Feed/Ranking/Phase: App-Context (Pillars & Goals), Phase definitions (v1.1), Ranking heuristic (v1.1), Agents & Tools (Agent contracts).
- Fallback: If Archon/MCP is unavailable, work directly with SSOT documents in the repo (App-Context, Roadmap, Tech-Stack, Dossiers v1.x) and briefly describe in the plan which sources you used.

Archon IDE Global Rules
- Check MCP server; use Archon as primary system.
- Follow task flow: `find_tasks` → `manage_task(status=doing)` → implement → `manage_task(status=review)` → `manage_task(status=done)`.
- Apply RAG workflow: `rag_get_available_sources` → `rag_search_knowledge_base(query, source_id?)`.
- Tool reference:
  - `find_projects`
  - `find_tasks`
  - `manage_task`
  - `rag_*`
- Keep queries short: 2–5 keywords, no long sentences.
