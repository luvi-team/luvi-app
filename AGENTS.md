# Agents Index (Codex Interop)

Dies ist der Index für Codex (/status) und das Onboarding.

Scope & Nutzung: Gilt ab Repo-Root rekursiv; Default Auto-Role; Misch-Tasks via `role: …`; SSOT Acceptance v1.1.

Governance
- Dossiers (01–05): context/agents/README.md
- SSOT Acceptance v1.1 (Core + Role extensions): context/agents/_acceptance_v1.1.md

Arbeitsweise
- Codex CLI-first; BMAD → PRP (Plan → Run → Prove).
- Required Checks (GitHub): Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · CodeRabbit · Vercel Preview Health (200 OK).
- Acceptance pro Rolle: „Core + Role extension“ gemäß SSOT v1.1.
- Antwortformat: verbindlich gemäß `docs/engineering/assistant-answer-format.md`.
- CI-Pflegezyklus: Actions-Pinning (checkout/upload-artifact/github-script) quartalsweise prüfen/aktualisieren; siehe `context/agents/_actions_todo.md`.
- Branch-Strategie: kurze Feature-Branches, Squash & Merge, Required Checks als Gate (Trunk‑Based, stabiler Main).

Quickstart (SSOT)
- Einstieg/Links siehe `README.md:1` → App‑Kontext, Tech‑Stack, Roadmap, Gold‑Standard (inkl. „Praktische Anleitung · Ultra‑Slim“)

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
