## Test Support Guidelines

- Call `TestConfig.ensureInitialized();` in each test suite that boots a `MaterialApp`, `GoRouter`, or any widget relying on legal link bypasses or shared feature flags.
- Import `test/support/test_config.dart` at the top of your test and invoke the initializer in `main()` before registering tests.
- Tests needing feature-flag helpers can keep the normal import; no analyzer ignore is required when the initializer is used.
- Never import anything under `test/support/` from `lib/` code; it is strictly for tests.

Example:

```dart
import '../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  testWidgets('renders dashboard', (tester) async {
    // ...
  });
}
```
