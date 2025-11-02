enum InitMode { prod, test }

typedef InitModeResolver = InitMode Function();

/// Lightweight bridge to expose the current InitMode to layers without a
/// Riverpod context (e.g., services package). The app is responsible for
/// wiring this via a Provider at startup.
class InitModeBridge {
  static InitModeResolver resolve = () => InitMode.prod;
}

