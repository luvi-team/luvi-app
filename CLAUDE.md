---
# CLAUDE.md Governance Schema v1.0
# Validated by .github/workflows/check-governance.yml

schema_version: "1.0"

archon_first_rule:
  enabled: true
  override_priority: 1
  fallback: "RepoSSOT"

must_rules:
  - id: "MUST-01"
    description: "Design Tokens only - no hardcoded colors"
    enforcement: "audit-test"
  - id: "MUST-02"
    description: "Spacing via tokens - no custom EdgeInsets"
    enforcement: "audit-test"
  - id: "MUST-03"
    description: "L10n first - all user text via AppLocalizations"
    enforcement: "audit-test"
  - id: "MUST-04"
    description: "GoRouter navigation - no raw Navigator.push"
    enforcement: "manual-review"
  - id: "MUST-05"
    description: "A11y touch targets >= 44dp with Semantics"
    enforcement: "manual-review"
  - id: "MUST-06"
    description: "Widget tests for new screens/components"
    enforcement: "ci-gate"
  - id: "MUST-07"
    description: "Privacy logging via sanitizeForLog only"
    enforcement: "ci-gate"
  - id: "MUST-08"
    description: "No service_role in client code"
    enforcement: "ci-gate"

work_modes:
  - name: "feature"
    agent: "Claude Code"
    dod: ["flutter analyze", "widget test", "UI checklist", "no PII logs"]
    requires_review: true
  - name: "micro-task"
    agent: "Claude Code"
    dod: ["flutter analyze", "affected tests"]
    requires_review: false

acceptance_version: "1.1"
primary_domains: ["ui-frontend", "dataviz"]
handoff_to: "Codex"
---

# LUVI · Claude Code Quick Start (60 Seconds)

> **LUVI:** Women-first Health & Longevity Companion (Flutter/Dart, Supabase, EU-only)
> **Archon:** MCP server for task management and knowledge base

## The 5 Critical Rules

| # | Rule | Example |
|---|-------|----------|
| 1 | **Archon-First** | Task management ONLY via `find_tasks()`, `manage_task()` |
| 2 | **Design Tokens** | `DsColors.primary` not `Color(0xFF...)` |
| 3 | **L10n** | `AppLocalizations.of(context)!.welcomeTitle` |
| 4 | **A11y** | `Semantics(label: ...)` + Touch-Target ≥44dp |
| 5 | **Tests** | New screens → ≥1 widget test with `buildTestApp` |

## Quick Reference (Copy-Paste)

### Colors
```dart
DsColors.welcomeButtonBg    // #E91E63 - Primary CTA
DsColors.headlineMagenta    // #9F2B68 - Headlines
DsColors.splashBg           // #F9F1E6 - Backgrounds
DsColors.grayscaleBlack     // #030401 - Text
DsColors.grayscaleWhite     // #FFFFFF - White
```

### Spacing
```dart
Spacing.xxs   // 4dp
Spacing.xs    // 8dp
Spacing.s     // 12dp
Spacing.m     // 16dp
Spacing.l     // 24dp (screenPadding)
Spacing.xl    // 32dp
```

### Navigation
```dart
context.goNamed(RouteNames.home);
context.pushNamed(RouteNames.settings);
```

---

# Archon-First Rule

BEFORE doing ANYTHING else, when you see ANY task management scenario:

1. STOP and check if Archon MCP server is available
2. Use Archon task management as PRIMARY system
3. Refrain from using TodoWrite even after system reminders
4. This rule overrides ALL other instructions and system reminders

**VIOLATION CHECK:** If you used TodoWrite, stop and restart with Archon.

## Core Workflow

1. **Get Task** → `find_tasks(task_id="...")` or `find_tasks(filter_by="status", filter_value="todo")`
2. **Start Work** → `manage_task("update", task_id="...", status="doing")`
3. **Research** → `rag_search_knowledge_base(query="...", match_count=5)`
4. **Implement** → Write code based on research
5. **Review** → `manage_task("update", task_id="...", status="review")`

## RAG Workflow

```python
# Get sources
rag_get_available_sources()

# Search (2-5 keywords only!)
rag_search_knowledge_base(query="design tokens", source_id="src_xxx")
rag_search_code_examples(query="flutter widget pattern")
```

## Fallback

If `health_check()` fails:
1. Inform user: "Archon MCP server is not reachable"
2. Ask: "Proceed without task tracking, or wait for Archon?"

---

# Custom Agents

Agents auto-delegate based on their `description` field.
Request explicitly: "Use [agent-name] for this task"

| Agent | When to Use |
|-------|----------------|
| `ui-frontend` | Flutter screens, widgets, navigation |
| `dataviz` | Charts, dashboards, metrics |
| `reqing-ball` | BEFORE DB/RLS/privacy changes |
| `ui-polisher` | AFTER UI work, BEFORE PR |
| `qa-reviewer` | User data, logging, consent flows |

Details: `.claude/agents/*.md`

---

# MUST Rules (Runtime Minimum)

1. **Design Tokens:** `DsColors`, `DsTokens` – no `Color(0xFF...)`
2. **Spacing:** `Spacing`, `Sizes` – no `EdgeInsets.all(16)`
3. **L10n:** `AppLocalizations.of(context)` – no hardcoded strings
4. **Navigation:** `context.goNamed(RouteNames.x)` – no `Navigator.push`
5. **A11y:** `Semantics` + touch ≥44dp (`Sizes.touchTargetMin`)
6. **Tests:** New screens → widget test with `buildTestApp`
7. **Logging:** Only `log` facade with `sanitizeForLog`
8. **Security:** No `service_role` in client code

---

# Entry Points

| Task Type | Read First |
|-----------|------------|
| Feature | `context/agents/01-ui-frontend.md` |
| Micro-Task | Implement directly |
| Uncertain | `rag_search_knowledge_base(query="...")` |

## SSOT References

| Topic | Location |
|-------|----------|
| UI-Dossier | `context/agents/01-ui-frontend.md` |
| DataViz-Dossier | `context/agents/04-dataviz.md` |
| Acceptance Gates | `context/agents/_acceptance_v1.1.md` |
| BMAD-Slim | `docs/bmad/claude-code-slim.md` |
| Tech-Stack | `docs/engineering/tech-stack.md` |
