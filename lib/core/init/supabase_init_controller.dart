import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/init_mode.dart';

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

class SupabaseInitController extends ChangeNotifier {
  SupabaseInitController();

  InitState _state = const InitState();
  InitState get state => _state;

  bool _started = false;
  Timer? _retryTimer;
  bool _disposed = false;
  String? _envFile;
  static final _random = math.Random();

  void ensureInitialized({required String envFile}) {
    _envFile ??= envFile;
    if (_started || SupabaseService.isInitialized) {
      _started = true;
      if (SupabaseService.isInitialized && !_state.initialized) {
        _setState(_state.copyWith(initialized: true, error: null, configError: false));
      }
      return;
    }
    _started = true;
    _attemptInit();
  }

  Future<void> retryNow() async {
    if (!_state.canRetry || !_state.hasAttemptsLeft) return;
    _retryTimer?.cancel();
    _setState(_state.copyWith(retryScheduled: false));
    await _attemptInit();
  }

  Future<void> _attemptInit() async {
    if (_envFile == null) return;
    if (SupabaseService.isInitialized) {
      _setState(_state.copyWith(initialized: true, error: null, configError: false));
      return;
    }

    final attempt = _state.attempts + 1;
    _setState(_state.copyWith(attempts: attempt, lastAttemptAt: DateTime.now()));
    try {
      await SupabaseService.tryInitialize(envFile: _envFile!);
      _setState(_state.copyWith(initialized: true, error: null, configError: false));
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
          context: ErrorDescription('attempt $attempt of ${_state.maxAttempts}'),
        ));
      }

      _setState(_state.copyWith(error: error, configError: isConfig));

      // In tests do not schedule retry timers to avoid pending timers
      if (!isTest && !isConfig && _state.hasAttemptsLeft && !_disposed) {
        // Exponential backoff without floating point: 500ms * (2^(attempt-1))
        final baseMs = 500 * (1 << (attempt - 1));
        final jitterMs = _random.nextInt(400);
        final delay = Duration(milliseconds: baseMs + jitterMs);
        _retryTimer?.cancel();
        _setState(_state.copyWith(retryScheduled: true));
        _retryTimer = Timer(delay, () {
          if (_disposed) return;
          _setState(_state.copyWith(retryScheduled: false));
          _attemptInit();
        });
      }
    }
  }

  void _setState(InitState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    super.dispose();
  }
}

// Global controller instance used by the app root.
final supabaseInitController = SupabaseInitController();
