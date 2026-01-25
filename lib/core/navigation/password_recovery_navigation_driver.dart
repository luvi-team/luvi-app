import 'dart:async';

import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

typedef PasswordRecoveryNavigateCallback = void Function();

/// Listens to Supabase auth events to trigger navigation into the
/// password reset flow when a password-recovery deep link is received.
class PasswordRecoveryNavigationDriver {
  PasswordRecoveryNavigationDriver({
    required Stream<supa.AuthChangeEvent> authEvents,
    required PasswordRecoveryNavigateCallback onNavigateToCreatePassword,
  }) : _onNavigateToCreatePassword = onNavigateToCreatePassword {
    _subscription = authEvents.listen(
      _handleEvent,
      onError: (Object error, StackTrace stackTrace) {
        log.w(
          'password_recovery_nav_stream_error',
          tag: 'password_recovery_nav',
          error: sanitizeError(error) ?? error.runtimeType,
          stack: stackTrace,
        );
      },
    );
  }

  final PasswordRecoveryNavigateCallback _onNavigateToCreatePassword;
  StreamSubscription<supa.AuthChangeEvent>? _subscription;
  Timer? _resetTimer;

  /// Debounce duration to suppress duplicate rapid events.
  /// Supabase may emit multiple passwordRecovery events for a single link click.
  static const _debounceResetDuration = Duration(milliseconds: 500);

  bool _hasNavigated = false;

  void _handleEvent(supa.AuthChangeEvent event) {
    if (event == supa.AuthChangeEvent.passwordRecovery) {
      if (_hasNavigated) return;
      _hasNavigated = true;
      _onNavigateToCreatePassword();

      // Reset flag after debounce to allow NEW recovery attempts in the same session.
      // This is for subsequent password reset links, NOT for re-processing the same link.
      // Using Timer instead of Future.delayed to support cancellation on dispose.
      _resetTimer?.cancel();
      _resetTimer = Timer(_debounceResetDuration, () {
        _hasNavigated = false;
      });
    }
  }

  Future<void> dispose() async {
    _resetTimer?.cancel();
    _resetTimer = null;
    await _subscription?.cancel();
    _subscription = null;
  }
}
