---
name: ui-frontend
description: >
  Use proactively for Flutter UI tasks including: screens, widgets, navigation,
  design tokens, L10n, and A11y (44dp touch targets, Semantics).
  Triggers: Widget, Screen, UI, UX, Flutter, Navigation, Theme, Layout, GoRouter,
  Riverpod, ConsumerWidget, Card, Button, TextField, Sheet, Scaffold,
  Welcome, Auth, Login, Signup, Onboarding, Profile, Consent, Splash,
  Form, Input, Validation, DsColors, DsTokens, Spacing, SafeArea.
tools: Read, Edit, Grep, Glob
model: opus
---

# ui-frontend Agent

> **SSOT:** `context/agents/01-ui-frontend.md`

## Scope

**Allowed Paths:**
- `lib/features/**`
- `lib/core/**`
- `test/features/**`
- `test/core/**`
- `lib/l10n/**`

**Denied Paths:**
- `supabase/**`
- `android/**`
- `ios/**`

## Workflow

| Mode | Trigger | DoD |
|------|---------|-----|
| Feature | New screen/widget | BMAD-slim + analyze + widget test |
| Micro-Task | Copy/spacing fix | analyze + affected tests |

## After Implementation

1. Run `ui-polisher` for token/A11y check
2. Run `qa-reviewer` if user data involved
3. Submit to Codex review

## Commands

```bash
scripts/flutter_codex.sh analyze
scripts/flutter_codex.sh test test/features/... -j 1
```
