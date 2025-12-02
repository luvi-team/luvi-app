### Summary
Die Claude-Agentenprinzipien wurden erfolgreich auf Codex übertragen. Alle Agenten-Dossiers (01–05) wurden harmonisiert, Acceptance-Blöcke ergänzt, Required-Checks präzisiert und ein SSOT angelegt. Legacy-Dateien bleiben referenziert, sind aber klar als solche markiert.

### Done
- 5 Agenten-Dossiers aktualisiert (`context/agents/01–05-*.md`)
  - Kopfblock ergänzt: `role, goal, inputs, outputs, acceptance, acceptance_version: 1.0`
  - Acceptance-Block enthält exakte Labels:
    - Required Checks (GitHub): Flutter CI / analyze-test (pull_request) ✅ · Flutter CI / privacy-gate (pull_request) ✅ · Greptile Review (Required Check) ✅ (CodeRabbit optional lokal)
    - DoD (Repo): flutter analyze ✅ · flutter test (≥1 Unit + ≥1 Widget) ✅ · ADRs gepflegt ✅ · DSGVO-Review aktualisiert ✅
    - Hinweis: DCM läuft CI-seitig non-blocking; Findings optional an Codex weitergeben
  - "Operativer Prompt" → "Operativer Modus (Codex CLI-first, .claude/* nur Referenz)"
- `context/agents/README.md` korrigiert
  - Pfade auf 01–05 gesetzt
  - Preamble ergänzt (Auto-Role Default, explicit role: … für Misch-Tasks)
  - Required-Checks & SSOT-Verweis aufgenommen
- `CLAUDE.md` als **Legacy** gekennzeichnet (Interop-Hinweis)
- Neues SSOT `context/agents/_acceptance_v1.md` angelegt (Version 1.0, identischer Acceptance-Block)

### Impact
- Governance dauerhaft im Repo verankert → wirkt automatisch in neuen Codex-Sessions und PRs
- Einheitliche Acceptance-Kriterien → keine Drift mehr zwischen Dossiers, CI und Merge-Gates
- Reviewer & Tools (Codex, Greptile Review, CI; CodeRabbit optional) arbeiten auf demselben Set an Regeln
- Legacy bleibt transparent, stört aber den Workflow nicht

### Next Steps (optional)
- Non-blocking Drift-Check-Skript (`_drift_check.sh`) anlegen, das `_drift_report.md` erzeugt
- Audit-Deliverables ergänzen (`_audit_report.md`, `_actions_todo.md`)
- Regelmäßig Commit & Push, damit Governance konsistent in allen PRs greift

### 2025-12-?? Dual-Agent-Reaktivierung
- Governance auf Dual-Agent-Modell aktualisiert:
  - Claude Code = Primary-Agent für UI/Frontend & Dataviz (siehe `CLAUDE.md`).
  - Codex = Primary-Agent für Backend/DB/Privacy und technischer Reviewer für Claude-Code-PRs.
  - SSOT-Quellen: `AGENTS.md`, `context/agents/*`, `_acceptance_v1.1.md`.
