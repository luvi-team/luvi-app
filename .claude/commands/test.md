# Flutter Test

Run tests.

## All Tests:
```bash
scripts/flutter_codex.sh test -j 1
```

## Specific Test:
```bash
scripts/flutter_codex.sh test $ARGUMENTS
```

**Examples:**
```bash
scripts/flutter_codex.sh test test/features/auth/login_submit_guard_test.dart
scripts/flutter_codex.sh test test/features/auth/
```

## On Errors:
1. Check the error message
2. Compare expected vs actual
3. Fix test or implementation

**Flutter Tips:**
- Golden mismatch → `scripts/flutter_codex.sh test --update-goldens`
- Widget tree → `tester.element(find.byType(X)).debugDump()`
- Async issues → `await tester.pumpAndSettle()`
- State not updating → Check provider scoping
