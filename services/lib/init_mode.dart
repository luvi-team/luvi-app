enum InitMode { prod, test }

typedef InitModeResolver = InitMode Function();

/// Lightweight bridge to expose the current InitMode to layers without a
/// Riverpod context (e.g., services package). The app is responsible for
/// wiring this via a Provider at startup.
///
/// Note: The static, mutable [resolve] is intended for tests to override.
/// Always restore the original resolver in tearDown to prevent cross-test
/// pollution.
///
/// Example usage in a test:
/// ```dart
/// final previous = InitModeBridge.resolve;
/// InitModeBridge.resolve = () => InitMode.test;
/// addTearDown(() => InitModeBridge.resolve = previous);
/// ```
class InitModeBridge {
  static InitModeResolver resolve = () => InitMode.prod;
}
