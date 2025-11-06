import 'package:flutter/foundation.dart';

enum InitMode { prod, test }

typedef InitModeResolver = InitMode Function();

/// Lightweight bridge to expose the current InitMode to layers without a
/// Riverpod context (e.g., services package). Production code must only read
/// the resolver via the getter; tests may override via the annotated setter.
///
/// Example usage in a test:
/// ```dart
/// final previous = InitModeBridge.resolve;
/// InitModeBridge.resolve = () => InitMode.test;
/// addTearDown(() => InitModeBridge.resolve = previous);
/// ```
abstract class InitModeBridge {
  InitModeBridge._();

  static InitModeResolver _resolver = () => InitMode.prod;

  /// Read the current resolver.
  static InitModeResolver get resolve => _resolver;

  /// Test-only override for the resolver. Do not use in production code.
  @visibleForTesting
  static set resolve(InitModeResolver newResolver) {
    _resolver = newResolver;
  }
}
