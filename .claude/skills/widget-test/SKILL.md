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
- Keywords: "create test", "widget test", "write tests"

## When NOT to Use
- Unit tests for pure Dart logic (use regular unit tests)
- Integration tests with backend (use integration test suite)
- The screen/widget already has tests

## Workflow

1. **Create test file** under `test/features/{feature}/`
2. **Use buildTestApp** from `test/support/test_app.dart`
3. **Load localization** with `AppLocalizations.delegate`
4. **Check Semantics** with `tester.ensureSemantics()`

## Test Setup

Every test file should start with:
```dart
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('ScreenName', () {
    testWidgets('renders correctly', (tester) async {
      // ...
    });
  });
}
```

**What `TestConfig.ensureInitialized()` handles:**
| Setup | Purpose |
|-------|---------|
| `TestWidgetsFlutterBinding` | Flutter test bindings |
| `VideoPlayerMock` | Prevents "VideoPlayer not initialized" errors |
| `AuthStrings` override | German localization for auth strings |
| `InitMode.test` | Disables network calls and timers |

**When to call:**
- Always at the start of `void main()`
- Before any `group()` or `testWidgets()` calls
- Only once per test file (not per test)

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

### Localization in Tests

`buildTestApp` already configures `AppLocalizations.delegate` - no extra setup required.

**Accessing L10n:**
```dart
final l10n = AppLocalizations.of(
  tester.element(find.byType(MyScreen)),
)!;
expect(find.text(l10n.someLabel), findsOneWidget);
```

## Run Tests
```bash
scripts/flutter_codex.sh test test/features/{feature}/{test_file}.dart
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing `pumpAndSettle()` | Call `pumpAndSettle()` after `pumpWidget()` for animations |
| Forgot `ensureSemantics()` | Always call `ensureSemantics()` before accessibility assertions |
| Wrong import path | Relative path `../../../support/test_app.dart` assumes test is 3 dirs deep (e.g., `test/features/auth/`). Adjust depth for your location. |
