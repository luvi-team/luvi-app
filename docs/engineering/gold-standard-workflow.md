# LUVI Gold-Standard Workflow

## Ziel
Reproduzierbarer Solo-Dev-Prozess für DSGVO-konforme FemTech-App. Leitsatz: Architektur vor Interaktion.

## Rollen (5-Agenten)
UI/Frontend (Flutter + GoRouter + Riverpod)
API/Backend (Supabase Edge, Contracts/Validation, MIWF)
DB-Admin (Schema, Migrations, RLS owner-based)
QA/DSGVO (Privacy-Reviews, Opt-in/Opt-out, Audit-Trail)
Dashboard/DataViz (ab M11)

## Governance & ADRs
ADR-0001 RAG-First Wissenshierarchie: interne Refs/ADRs → Codebase → extern (sparsam, belegt) → LLM-Wissen.
ADR-0002 Least-Privilege & RLS: RLS ON, owner-Policies; service_role nie im Client.
ADR-0003 MIWF: Happy Path zuerst; Guards nur nach Evidenz (Sentry/PostHog).

## Definition of Done (DoD)
- CI grün (flutter analyze, flutter test)
- Tests: mind. ≥ 1 Unit + ≥ 1 Widget pro Story
- DSGVO-Review aktualisiert
- ADRs gepflegt
- PR-Template Pflichtfelder inkl. Babysitting-Level, AI pre/post Commit, RLS-Check
- CodeRabbit (Lite) Status grün (Branch-Protection Required)

## Required-Checks (GitHub)
Siehe `context/agents/_acceptance_v1.1.md#core`

## Rollen-spezifische DoD-Checks
- UI/Frontend & DataViz: flutter analyze ✅ · flutter test (≥ 1 Unit + ≥ 1 Widget) ✅ · CodeRabbit ✅ · ADRs/DSGVO-Note ✅
- API/Backend: dart analyze, dart test (services/contracts) ✅ · Privacy-Gate (bei DB-Touches) ✅ · CodeRabbit ✅ · ADRs ✅
- DB-Admin: Migrations & RLS-Policies/Trigger aktualisiert + dokumentiert ✅ · Kein service_role im Client ✅ · Privacy-Gate ✅ · CodeRabbit ✅ · ADRs ✅
- QA/DSGVO: Privacy-Review (docs/privacy/reviews/.md) ✅ · Privacy-Gate ✅ · CodeRabbit ✅ · ADRs ✅

## Prozessrahmen
BMAD (vor Implementierung):
Business (Ziele, DSGVO) → Modellierung (Flows/ERD, Tabellen/Policies) → Architektur (Schnittstellen, Trigger, Upsert) → DoD/Teststrategie → Rollenabnahme.

PRP (je Story):
Plan (Mini-Plan + Why/What/How) → Run (kleinste Schritte; erst erklären, dann Befehle) → Prove (Lint/Tests/RLS/API-Checks; Diff; DSGVO-Notiz) → Ready for review.

## Soft-Gates
Req’ing Ball (max. 5 Gaps, Was/Warum/Wie, File:Line)
UI-Polisher (Tokens, Kontrast, Spacing, Typo, States)
CodeRabbit Lite (line-by-line)

## Agenten-Governance (aktualisiert)
- AGENTS.md (Repo-Root) als Index, Default Auto-Role, Misch-Tasks role: …
- Dossiers 01–05 unter context/agents/ als Governance-Quelle
- Header-Schema (Front-Matter): role, goal, inputs, outputs, acceptance, acceptance_version: 1.1
  - inputs beinhalten ERD: „PRD, ERD, ADRs 0001–0003, Branch/PR-Link“
  - acceptance verweist nur auf SSOT (Core + Role Extensions)
- SSOT Acceptance: context/agents/_acceptance_v1.1.md
- Interop/Legacy: .claude/*, CLAUDE.md nur Referenz; operativ Codex CLI-first.

## GitHub / Branch-Protection
Required Checks: Siehe `context/agents/_acceptance_v1.1.md#core`

