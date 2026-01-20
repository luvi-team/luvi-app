---
name: figma-to-flutter
description: Use when you need to convert a Figma design or screenshot into Flutter code with design tokens
---

# Figma → Flutter Skill

## Overview
Converts Figma designs into Flutter code using LUVI's design token system (DsColors, Spacing, Sizes).

## When to Use
- You have a Figma screenshot or design to implement
- You're building a new screen or component from a visual reference
- Keywords in request: "Figma", "Screenshot", "bau nach", "implementiere Screen", "UI-Design", "Mockup"

## When NOT to Use
- Pure logic/backend changes without UI
- Refactoring existing screens (no new design)
- Bug fixes in existing UI

## Workflow

### 1. Extract Colors
```bash
grep -n "Figma: #HEXCODE" lib/core/design_tokens/colors.dart
```
- Found → Use existing token
- Not found → Create new token with `/// Figma: #HEXCODE`

### 2. Extract Spacing
```bash
grep -n "Figma: XXpx" lib/core/design_tokens/spacing.dart
```

### 3. Extract Sizes
```bash
grep -n "Figma: XXpx" lib/core/design_tokens/sizes.dart
```

### 3a. Token Creation (if not found)

When adding new tokens, follow these patterns:

**Color Token** (`lib/core/design_tokens/colors.dart`):
```dart
/// Figma: #E91E63 (Primary CTA Pink)
static const Color primaryCtaPink = Color(0xFFE91E63);
```

**Spacing Token** (`lib/core/design_tokens/spacing.dart`):
```dart
/// Figma: 24px (Screen padding)
static const double screenPadding = 24.0;
```

**Size Token** (`lib/core/design_tokens/sizes.dart`):
```dart
/// Figma: 56px (Large button height)
static const double buttonHeightL = 56.0;
```

**Naming Convention:**
- Use camelCase for all token names
- Include context in name: `cardBackgroundNeutral`, not just `neutral`
- Comment format: `/// Figma: #HEXCODE (Context)` or `/// Figma: XXpx (Context)`

### 4. Find Reference Screen
- Glob: `lib/features/*/screens/*.dart`
- Auth: `lib/features/auth/screens/`
- Onboarding: `lib/features/onboarding/screens/`

### 5. Implement with:
- `DsColors.*` for colors
- `Spacing.*` for spacing
- `Sizes.*` for dimensions
- `Semantics(label: AppLocalizations.of(context)!.xxx)` for A11y

### 6. Create Widget Test
- Under `test/features/{feature}/`
- Use `buildTestApp` from `test/support/test_app.dart`

### 7. Verify
```bash
scripts/flutter_codex.sh analyze
```

## Quick Reference

See `TOKEN_MAPPING.md` for Figma Hex → Flutter Token mappings.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Hardcoded colors `Color(0xFF...)` | Use `DsColors.*` token |
| Hardcoded spacing `EdgeInsets.all(16)` | Use `Spacing.m` |
| Missing Semantics | Add `Semantics(label: l10n.xxx)` |
| Forgot Widget Test | Always create test under `test/features/` |
| `fontWeight: FontWeight.w400` for Variable Fonts | Use `fontVariations: [FontVariation('wght', 400)]` |
| Variable Font without `fontVariations` | Figtree/Playfair always require `fontVariations` |
