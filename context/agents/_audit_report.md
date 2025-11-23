# Agenten-Audit – LUVI (Codex-Governance)

> Hinweis: Dieses Dokument ist ein Inventar-Snapshot für Governance-Audits. Einträge können historische/Legacy-Pfade enthalten (z. B. `.claude/agents/*`). Maßgeblich für die aktuelle Arbeitsweise sind die Dossiers unter `context/agents/*` und die SSOT Acceptance v1.1 (`context/agents/_acceptance_v1.1.md`).

## Bestand (Inventar)
| file | title (H1) | role/agent | purpose | last_updated |
|---|---|---|---|---|
| context/agents/01-ui-frontend.md | Agent: ui-frontend | ui-frontend | Governance-Dossier UI (Codex) | 2025-09-11 |
| context/agents/02-api-backend.md | Agent: api-backend | api-backend | Governance-Dossier Backend (Codex) | 2025-09-11 |
| context/agents/03-db-admin.md | Agent: db-admin | db-admin | Governance-Dossier DB (Codex) | 2025-09-11 |
| context/agents/04-dataviz.md | Agent: dataviz | dataviz | Governance-Dossier Dataviz (Codex) | 2025-09-11 |
| context/agents/05-qa-dsgvo.md | Agent: qa-dsgvo | qa-dsgvo | Governance-Dossier Privacy (Codex) | 2025-09-11 |
| context/agents/_acceptance_v1.1.md | Acceptance – SSOT v1.1 | meta | Core & Role-Extensions (Codex) | 2025-09-11 |
| context/agents/README.md | Agenten-Dossiers | meta | Index/Preamble, Pfade 01–05 | 2025-09-05 |
| context/agents/reqing-ball.md | Agent: reqing-ball | soft-gate (unmapped) | Requirement-Validator (max 5 Gaps) | 2025-09-05 |
| context/agents/ui-polisher.md | Agent: ui-polisher | soft-gate (unmapped) | UI-Heuristiken (Tokens/A11y) | 2025-09-05 |
| .claude/agents/ui-frontend.md | Rolle | legacy ui-frontend | Legacy-Operativ (nur Referenz) | 2025-09-03 |
| .claude/agents/api-backend.md | Rolle | legacy api-backend | Legacy-Operativ (nur Referenz) | 2025-09-03 |
| .claude/agents/db-admin.md | Rolle | legacy db-admin | Legacy-Operativ (nur Referenz) | 2025-09-03 |
| .claude/agents/dataviz.md | Rolle | legacy dataviz | Legacy-Operativ (nur Referenz) | 2025-09-03 |
| .claude/agents/qa-dsgvo.md | Rolle | legacy qa-dsgvo | Legacy-Operativ (nur Referenz) | 2025-09-03 |
| CLAUDE.md | LUVI Project Memory | legacy (meta) | Legacy/Interop, als Legacy gekennzeichnet | 2025-09-03 |
| docs/privacy/reviews/feat-sprint1-claude-agents.md | DSGVO Compliance Review | qa-dsgvo (review) | Review-Report zum Claude-Setup | 2025-09-04 |
| WARP.md | WARP.md | meta | IDE/Terminal-Hinweise, MCP/Claude-Notiz | 2025-09-04 |

## Konsistenz – Abgleich gegen Standard
- Rollenabgleich: 5 Kern-Dossiers mappen auf {ui-frontend, api-backend, db-admin, qa-dsgvo, dataviz} ✅
- Prozess/Governance: BMAD→PRP/DoD/Soft-Gates in Dossiers verankert (Operativer Modus) ✅
- DoD/Required Checks: Exakte Labels hinterlegt (Flutter CI / analyze-test (pull_request), Flutter CI / privacy-gate (pull_request), Greptile Review (Required Check)) ✅ (CodeRabbit optional lokal)
- DCM: Hinweis non-blocking in Acceptance vorhanden ✅
- SSOT: context/agents/_acceptance_v1.1.md (Version 1.1) vorhanden ✅

## Altlasten / Konflikte
- .claude/agents/*: Legacy, als Referenz belassen (keine operative Ausführung) → ok.
- CLAUDE.md: Als Legacy markiert; enthält alte Pfade (z. B. 04-dashboard-dataviz.md) – toleriert, da Legacy/Interop.
- Zusatz-Agenten (reqing-ball, ui-polisher): Soft-Gates, außerhalb 5‑Rollen – ok; keine acceptance_version nötig.

## Empfohlene Änderungen (minimal-diff)
- CLAUDE.md: Optional Hinweis ergänzen, dass Links veraltet sein können (Legacy-Block ist vorhanden – keine Pflicht).
- reqing-ball.md / ui-polisher.md: Optional Operativer Modus (Codex CLI-first) als 1‑Zeiler ergänzen.

## Quick-Win Patch-Snippets
(entfernt; Governance ist auf SSOT v1.1 ausgerichtet. Verifikation siehe Abschnitt „Checks – Read-Only“)

## Verifikation (Checks – Read-Only)
- Rollenfelder: rg -n ^role:\s*(ui-frontend|api-backend|db-admin|qa-dsgvo|dataviz) context/agents
- Acceptance-Version: rg -n ^acceptance_version:\s*1\.1 context/agents
- Required-Labels: rg -n "Flutter CI / analyze-test \(pull_request\).*Greptile Review" context/agents
- SSOT vorhanden: ls -l context/agents/_acceptance_v1.1.md
- README Preamble & Pfade: sed -n '1,120p' context/agents/README.md
- CLAUDE Legacy-Header: sed -n '1,20p' CLAUDE.md
