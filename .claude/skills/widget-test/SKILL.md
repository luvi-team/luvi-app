---
name: widget-test
description: Use when you have implemented a new screen or widget that needs widget tests
---

# Widget Test Skill

## Overview
Creates widget tests for Flutter screens/components using LUVI's test infrastructure.

## When to Use
- You just implemented a new screen
- You created a new reusable widget
- Keywords: "Test erstellen", "Widget Test", "write tests"

## When NOT to Use
- Unit tests for pure Dart logic (use regular unit tests)
- Integration tests with backend (use integration test suite)
- The screen/widget already has tests

## Workflow

1. **Create test file** under `test/features/{feature}/`
2. **Use buildTestApp** from `test/support/test_app.dart`
3. **Load localization** with `AppLocalizations.delegate`
4. **Check Semantics** with `tester.ensureSemantics()`

## Quick Reference

### buildTestApp
```dart
await tester.pumpWidget(
  buildTestApp(child: const MyScreen()),
);
await tester.pumpAndSettle();
```

### Semantics Check
```dart
final handle = tester.ensureSemantics();
// ... test
handle.dispose();
```

### Common Finders
```dart
find.byType(MyWidget)
find.text('Expected Text')
find.bySemanticsLabel('Semantic Label')
```

## Run Tests
```bash
scripts/flutter_codex.sh test test/features/{feature}/{test_file}.dart
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing `pumpAndSettle()` | Add after `pumpWidget()` for animations |
| Forgot `ensureSemantics()` | Always check Semantics in A11y test |
| Wrong import path | Use relative `../../../support/test_app.dart` |
