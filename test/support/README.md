## Test Support Guidelines

- Import `test/support/test_config.dart` in every test that boots a `MaterialApp`, `GoRouter`, or other app entrypoint. The file sets up AppLinks bypasses and shared feature-flag config for tests.
- Never import this file (or anything else under `test/support/`) from `lib/` code. It is intended strictly for tests.

Example:

```dart
// ignore: unused_import
import '../support/test_config.dart';
```
