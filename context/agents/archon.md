---
role: archon
goal: Multi-agent orchestration für Phase · Consent · Ranking (BMAD/PRP).
inputs:
  - docs/engineering/gold-standard-workflow.md
  - docs/runbooks/*
  - Branch/PR-Link
  - Traycer-Plan & BMAD-Notizen
outputs:
  - Aktualisiertes Phase/Consent/Ranking-Protokoll
  - PR-Verweis auf das Dossier
acceptance_refs:
  - context/agents/_acceptance_v1.1.md#core
  - context/agents/_acceptance_v1.1.md#role-extensions
acceptance_version: "1.1"
---

# Agent: Archon (MCP)

## Purpose
Archon ist der interne Orchestrierungsagent (MCP) für Codex + Claude Code. Er hält Phase (BMAD/PRP-Fortschritt), Consent-Scope und Ranking-/Priorisierungsentscheidungen je Feature nachvollziehbar fest, sodass Reviewer eine auditierbare Quelle haben.

- **Codex** nutzt Archon/MCP für Backend-/DB-/Privacy-Aufgaben (Supabase, Edge, RLS) und ruft hierüber RAG-Quellen (BMAD, App-Kontext, Roadmap, Dossiers) ab.
- **Claude Code** nutzt dieselben Archon/RAG-Quellen für UI/Frontend/Dataviz-Work, sodass Screens/Widgets/Charts stets mit Phase-/Consent-Entscheidungen synchron bleiben. MCP-basierte DB/RLS-Operationen verbleiben bei Codex.

## Fields to Keep Current
| Field  | Inhalt                                                                                           |
|--------|--------------------------------------------------------------------------------------------------|
| Phase  | Aktueller BMAD/PRP-Schritt inkl. Timestamp, Owner und nächstem Gate.                             |
| Consent| Letzter Consent-/Privacy-Scope, Reviewer, verlinktes Privacy-Review oder DPIA.                   |
| Ranking| Priorität/Entscheidung (z. B. Blocker, Reihenfolge, Eskalation) + verantwortliche Person/Agent.  |

## Update Instructions
1. Bei jeder Phase-/Consent-/Ranking-Änderung Eintrag ergänzen oder updaten; Branch/Ticket + Runbook-Evidence hinzufügen.
2. Kurz halten (1–2 Sätze pro Feld) und bei Consent-Änderungen das passende Review (`docs/privacy/reviews/*.md`) referenzieren.
3. Permalink zu `context/agents/archon.md` im PR (Checklist/Description) hinzufügen, damit Reviewer Phase · Consent · Ranking prüfen können.

## Dossiers & Storage
- Primär-Dossier: `context/agents/archon.md` (diese Datei).
- Größere Richtungswechsel zusätzlich in relevanten ADRs (z. B. `context/ADR/0002-least-privilege-rls.md`) spiegeln.
