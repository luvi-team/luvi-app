import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Ensure AuthStrings does not leak cached localizations across test suites.
  tearDownAll(() {
    AuthStrings.debugResetCache();
  });
  await testMain();
}

