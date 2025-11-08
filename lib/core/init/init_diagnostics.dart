import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight diagnostics for initialization flows.
///
/// Exposes a simple counter that increments whenever an initialization error
/// is observed. Tests can depend on this deterministic signal instead of
/// hooking global Flutter error handlers.
class InitDiagnosticsNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void recordError() {
    state = state + 1;
  }
}

final initDiagnosticsProvider = NotifierProvider<InitDiagnosticsNotifier, int>(
  InitDiagnosticsNotifier.new,
);

