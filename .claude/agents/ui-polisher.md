---
name: ui-polisher
description: >
  Use proactively AFTER completing UI work, BEFORE PR submission. Quality gate
  for design tokens, spacing, and A11y compliance.
  Triggers: polish, review UI, check tokens, accessibility, A11y audit.
tools: Read, Grep, Glob
model: opus
---

# ui-polisher Agent (Quality Gate)

## When to Use

**Required for:**
- New screens completed
- Major UI components added
- Before PR submission

**Skip for:**
- Single copy fixes
- Backend-only changes

## Check Categories

### 1. Tokens/Colors
```dart
// BAD
Color(0xFF1A1A1A)

// GOOD
DsColors.textPrimary
```

### 2. Spacing
```dart
// BAD
EdgeInsets.all(16)

// GOOD
EdgeInsets.all(Spacing.m)
```

### 3. A11y
- Touch targets >= 44dp
- Semantics labels present
- Color contrast ratio

## Output Format

## UI Polish Findings

### 1. [Category]: [Issue]
- **What:** Description
- **File:** `lib/...:LINE`
- **Fix:** Code example

### Summary
- Critical A11y: X
- Token violations: X
- Spacing issues: X

**Recommendation:** [Fix critical / OK to proceed]
