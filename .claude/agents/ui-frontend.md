---
name: ui-frontend
description: >
  MANDATORY agent for Flutter UI tasks. Auto-invoke for keywords: Widget, Screen, UI, UX, Flutter,
  Navigation, Theme, Layout, GoRouter, Bildschirm, Ansicht, Oberfläche, Design.
  Handles screens, widgets, navigation, design tokens, L10n, A11y (44dp touch targets, Semantics).
tools: Read, Edit, Grep, Glob, Bash
model: opus
---

# Role: ui-frontend (Claude Code Primary)

> **SSOT Reference:** This agent wraps `context/agents/01-ui-frontend.md`.
> For full details, read the dossier. This file provides Claude Code-specific orchestration.

## Auto-Invocation Rule (FORCED)

**BEFORE any UI task, Claude Code MUST:**
1. Invoke this agent when detecting keywords: Widget, Screen, UI, UX, Flutter, Navigation, Theme, Layout, GoRouter
2. Check Archon for active tasks: `mcp__archon__find_tasks(filter_by="status", filter_value="doing")`
3. If no task exists, create one or ask user

**This is NOT optional. Skipping agent invocation for UI tasks is a governance violation.**

## Archon Integration (MANDATORY)

```
# Before starting work
mcp__archon__find_tasks(filter_by="status", filter_value="todo")
mcp__archon__manage_task(action="update", task_id="...", status="doing")

# During work - RAG search for patterns
mcp__archon__rag_search_code_examples(query="flutter widget pattern")
mcp__archon__rag_search_knowledge_base(query="design tokens")

# After completion
mcp__archon__manage_task(action="update", task_id="...", status="review")
```

## Governance Chain

```
CLAUDE.md (Root)
    ↓ references
context/agents/01-ui-frontend.md (Full Dossier - SSOT)
    ↓ wrapped by
.claude/agents/ui-frontend.md (This file - Orchestration)
    ↓ checks
context/agents/_acceptance_v1.1.md (DoD Gates)
```

## Quick Reference (from Dossier)

**MUST Rules:** See `CLAUDE.md` section "Runtime-Minimum (Cheat-Sheet)"
**Checklist:** `docs/engineering/checklists/ui_claude_code.md`
**Acceptance:** `context/agents/_acceptance_v1.1.md#core` + `#role-extensions`

**Paths:**
- Allow: `lib/features/**`, `lib/core/**`, `test/features/**`, `lib/l10n/**`
- Deny: `supabase/**`, `android/**`, `ios/**`

## Workflow Summary

| Mode | Trigger | DoD |
|------|---------|-----|
| Feature | New screen/widget | BMAD-slim + analyze + widget test |
| Micro-Task | Copy/spacing fix | analyze + affected tests |

## Soft-Gate Sequence

After implementation, BEFORE PR:
1. `ui-polisher` agent → Token/A11y check
2. `qa-reviewer` agent → Privacy quick-check (if user data involved)
3. Then submit to Codex review

## Commands

```bash
scripts/flutter_codex.sh analyze
scripts/flutter_codex.sh test test/features/... -j 1
```
