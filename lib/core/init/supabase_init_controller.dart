import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class InitState {
  const InitState({
    this.initialized = false,
    this.error,
    this.configError = false,
    this.attempts = 0,
    this.maxAttempts = 5,
    this.lastAttemptAt,
    this.retryScheduled = false,
  });

  final bool initialized;
  final Object? error;
  final bool configError;
  final int attempts;
  final int maxAttempts;
  final DateTime? lastAttemptAt;
  final bool retryScheduled;

  bool get canRetry => !initialized && !configError;
  bool get hasAttemptsLeft => attempts < maxAttempts;

  InitState copyWith({
    bool? initialized,
    Object? error = _sentinel,
    bool? configError,
    int? attempts,
    int? maxAttempts,
    DateTime? lastAttemptAt,
    bool? retryScheduled,
  }) {
    return InitState(
      initialized: initialized ?? this.initialized,
      error: identical(error, _sentinel) ? this.error : error,
      configError: configError ?? this.configError,
      attempts: attempts ?? this.attempts,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      retryScheduled: retryScheduled ?? this.retryScheduled,
    );
  }

  static const _sentinel = Object();
}

class SupabaseInitController extends Notifier<InitState> {
  @override
  InitState build() {
    // Trigger initialization using envFile from provider
    // Schedule it for next frame to avoid modifying provider during build
    Future.microtask(() {
      final envFile = ref.read(supabaseEnvFileProvider);
      ensureInitialized(envFile: envFile);
    });
    return const InitState();
  }

  bool _started = false;
  Timer? _retryTimer;
  bool _disposed = false;
  String? _envFile;
  static final _random = math.Random();

  void ensureInitialized({required String envFile}) {
    // First call wins; subsequent calls with different envFile are ignored.
    assert(_envFile == null || _envFile == envFile,
           'envFile must be consistent across calls');
    _envFile ??= envFile;
    if (_started || SupabaseService.isInitialized) {
      _started = true;
      if (SupabaseService.isInitialized && !state.initialized) {
        _setState(state.copyWith(initialized: true, error: null, configError: false));
      }
      return;
    }
    _started = true;
    _attemptInit();
  }

  Future<void> retryNow() async {
    if (!state.canRetry || !state.hasAttemptsLeft) return;
    _retryTimer?.cancel();
    _setState(state.copyWith(retryScheduled: false));
    await _attemptInit();
  }

  Future<void> _attemptInit() async {
    if (_envFile == null) return;
    if (SupabaseService.isInitialized) {
      _setState(state.copyWith(initialized: true, error: null, configError: false));
      return;
    }

    final attempt = state.attempts + 1;
    _setState(state.copyWith(attempts: attempt, lastAttemptAt: DateTime.now()));
    try {
      await SupabaseService.tryInitialize(envFile: _envFile!);
      _setState(state.copyWith(initialized: true, error: null, configError: false));
      return;
    } catch (error, stack) {
      // Check for specific error types that indicate configuration issues
      final isConfig = error is StateError ||
                       error is FormatException ||
                       error is ArgumentError;

      // During tests, avoid reporting as uncaught errors to keep tests green
      // while the app shows the offline/initializing UI.
      final isTest = InitModeBridge.resolve() == InitMode.test;
      if (!isTest) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'supabase_init_controller',
          context: ErrorDescription('attempt $attempt of ${state.maxAttempts}'),
        ));
      }

      if (!isTest && !isConfig && state.hasAttemptsLeft && !_disposed) {
        // Exponential backoff without floating point: 500ms * (2^(attempt-1))
        final baseMs = 500 * (1 << (attempt - 1));
        // Symmetric jitter in [-20%, +20%] around baseMs
        final jitterRange = baseMs ~/ 5; // 20%
        final jitterMs = _random.nextInt(jitterRange * 2 + 1) - jitterRange;
        final delay = Duration(milliseconds: baseMs + jitterMs);
        _retryTimer?.cancel();
        _setState(state.copyWith(retryScheduled: true));
        _retryTimer = Timer(delay, () {
          if (_disposed) return;
          _setState(state.copyWith(retryScheduled: false));
          _attemptInit();
        });
      }
      // Record the error/config state regardless of scheduling a retry
      _setState(state.copyWith(error: error, configError: isConfig));
    }
  }

  void _setState(InitState value) {
    state = value;
  }

  /// Testing-only helper that clears internal state so a fresh initialization
  /// cycle can run in isolated tests. This does not touch SupabaseService
  /// itself; tests should also call SupabaseService.resetForTest() as needed.
  @visibleForTesting
  void resetForTesting() {
    _retryTimer?.cancel();
    _retryTimer = null;
    state = const InitState();
    _envFile = null;
    _started = false;
    _disposed = false;
  }

  void disposeController() {
    _disposed = true;
    _retryTimer?.cancel();
  }
}

/// Provider for the env file used during Supabase initialization.
///
/// Default is '.env.development'. The app root should override this to
/// '.env.production' in release mode:
///   ProviderScope(overrides: [
///     supabaseEnvFileProvider.overrideWithValue('.env.production'),
///   ], child: App())
final supabaseEnvFileProvider = Provider<String>((ref) => '.env.development');

/// App-scoped provider that constructs and initializes the
/// SupabaseInitController. The controller is kept alive for the app lifetime.
///
/// Tests can override this provider to supply a fresh controller and call
/// resetForTesting() to isolate state between runs:
///   final controller = SupabaseInitController()..resetForTesting();
///   await tester.pumpWidget(ProviderScope(overrides: [
///     supabaseInitControllerProvider.overrideWithValue(controller),
///   ], child: MyApp(...)));
final supabaseInitControllerProvider =
    NotifierProvider<SupabaseInitController, InitState>(() {
  return SupabaseInitController();
});
