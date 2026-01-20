# Flutter Test

Run tests.

## All Tests:
```bash
# -j 1: Serielle Ausführung für Test-Isolation
# (Supabase Mocks, Filesystem, Provider State)
scripts/flutter_codex.sh test -j 1
```

## Specific Test:
```bash
# $TEST_PATH akzeptiert: Dateipfad, Verzeichnis, oder Glob-Pattern
scripts/flutter_codex.sh test $TEST_PATH
```

**Akzeptierte Formate:**
- Einzelne Datei: `test/features/auth/login_test.dart`
- Verzeichnis: `test/features/auth/`
- Glob-Pattern: `test/**/*_test.dart`

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
