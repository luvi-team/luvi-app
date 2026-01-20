# Flutter Test

Run tests.

## All Tests:
```bash
# -j 1: Serial execution for test isolation
# (Supabase mocks, filesystem, provider state)
scripts/flutter_codex.sh test -j 1
```

## Specific Test:
```bash
# $TEST_PATH accepts: file path, directory, or glob pattern
scripts/flutter_codex.sh test $TEST_PATH
```

**Accepted formats:**
- Single file: `test/features/auth/login_test.dart`
- Directory: `test/features/auth/`
- Glob pattern: `test/**/*_test.dart`

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
- Widget tree → `debugDumpApp()`
- Async issues → `await tester.pumpAndSettle()`
- State not updating → Check provider scoping
