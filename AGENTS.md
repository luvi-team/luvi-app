# Agents Index (Codex Interop)

Dies ist der Index für Codex (/status) und das Onboarding.

Scope & Nutzung: Gilt ab Repo-Root rekursiv; Default Auto-Role; Misch-Tasks via `role: …`; SSOT Acceptance v1.1.

Governance
- Dossiers (01–05): context/agents/README.md
- SSOT Acceptance v1.1 (Core + Role extensions): context/agents/_acceptance_v1.1.md

Arbeitsweise
- Codex CLI-first; BMAD → PRP (Plan → Run → Prove).
- Required Checks (GitHub): Flutter CI / analyze-test (pull_request) · Flutter CI / privacy-gate (pull_request) · CodeRabbit.
- Acceptance pro Rolle: „Core + Role extension“ gemäß SSOT v1.1.

Rollenwahl
- Default: Auto-Role (ankündigen). Misch-Tasks: `role: …` (Primärrolle zuerst).

Interop/Legacy
- .claude/agents/* & CLAUDE.md = Legacy (nur Referenz), operativ gilt Codex.
