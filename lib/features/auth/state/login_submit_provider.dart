import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/features/auth/l10n/auth_strings.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginSubmitNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) {
      return;
    }

    final loginNotifier = ref.read(loginProvider.notifier);
    // validateAndSubmit performs local (synchronous) validation only and does not
    // perform any network calls. However, the provider may still be in a loading
    // or error state due to concurrent updates (e.g. other auth flows) — handle safely.
    // SECURITY: Pass password as parameter, not stored in provider state.
    await loginNotifier.validateAndSubmit(password: password);

    final loginAsync = ref.read(loginProvider);
    if (loginAsync.isLoading) {
      // Provider still loading (concurrent update); return early to avoid duplicate submission.
      state = const AsyncData(null);
      return;
    }
    if (loginAsync.hasError) {
      // Provider has an error (unexpected for local validation); surface a global error
      loginNotifier.setGlobalError(AuthStrings.errLoginUnavailable);
      state = const AsyncData(null);
      return;
    }
    final loginState = loginAsync.maybeWhen(
      data: (d) => d,
      orElse: () => null,
    );
    if (loginState == null) {
      // Defensive: no data available; treat as temporarily unavailable.
      loginNotifier.setGlobalError(AuthStrings.errLoginUnavailable);
      state = const AsyncData(null);
      return;
    }
    final hasLocalErrors =
        loginState.emailError != null || loginState.passwordError != null;
    // If local validation reported errors, do not hit the network.
    // Keep the existing field errors intact for clear UX.
    if (hasLocalErrors) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    final sanitizedEmail = email.trim();

    try {
      await repository.signInWithPassword(
        email: sanitizedEmail,
        password: password,
      );

      loginNotifier.clearGlobalError();
      state = const AsyncData(null);
    } on AuthException catch (error) {
      _mapAuthException(
        error: error,
        loginNotifier: loginNotifier,
        email: sanitizedEmail,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      // Log sanitized error, set global error - no crash
      log.e(
        'login_submit_unexpected_error',
        tag: 'login_submit',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      loginNotifier.setGlobalError(AuthStrings.errLoginUnavailable);
      state = const AsyncData(null);
    }
  }

  void _mapAuthException({
    required AuthException error,
    required LoginNotifier loginNotifier,
    required String email,
  }) {
    final code = error.code?.toLowerCase();

    // Log warning if error code is missing (helps monitor edge cases)
    if (code == null) {
      log.w(
        'auth_error_missing_code: message=${sanitizeError(error) ?? "[redacted]"}',
        tag: 'login_submit',
      );

      // Fallback: no structured error.code available.
      // Note: AuthException.statusCode is String?, not int.
      // Keep this minimal to avoid fragile message pattern matching.
      // TODO(backend): Request consistent error codes to eliminate heuristic detection.
      // Known limitation: May false-positive on non-credential 401s (e.g., session expiry).
      final statusCode = error.statusCode;
      final isInvalidCredentials = statusCode == '401';

      if (isInvalidCredentials) {
        log.d('login_fallback_heuristic_triggered (statusCode=$statusCode)', tag: 'login_submit');
        loginNotifier.updateState(
          email: email,
          emailError: AuthStrings.invalidCredentials,
          passwordError: AuthStrings.invalidCredentials,
          globalError: null,
        );
        return;
      }

      loginNotifier.updateState(
        email: email,
        emailError: null,
        passwordError: null,
        globalError: AuthStrings.errLoginUnavailable,
      );
      return;
    }

    // Structured error code checks only (no fragile message patterns)
    final isInvalidCredentials = code == 'invalid_credentials' ||
        code == 'invalid_grant';

    final isEmailNotConfirmed = code == 'email_not_confirmed';
    final isOtpExpired = code == 'otp_expired';

    if (isInvalidCredentials) {
      // SSOT P0.7: Both fields show error on invalid credentials
      // SECURITY: Don't write password back into provider state
      loginNotifier.updateState(
        email: email,
        emailError: AuthStrings.invalidCredentials,
        passwordError: AuthStrings.invalidCredentials,
        globalError: null,
      );
      return;
    }

    if (isEmailNotConfirmed) {
      loginNotifier.updateState(
        email: email,
        emailError: null,
        passwordError: null,
        globalError: AuthStrings.errConfirmEmail,
      );
      return;
    }

    if (isOtpExpired) {
      // OTP expired: prompt user to request new verification email
      // Sets globalError to AuthStrings.errOtpExpired so UI can show specific message/action
      loginNotifier.updateState(
        email: email,
        emailError: null,
        passwordError: null,
        globalError: AuthStrings.errOtpExpired,
      );
      return;
    }

    // Log unrecognized auth errors for inspection
    log.i(
      'auth_error_unrecognized: code=$code, message=${sanitizeError(error) ?? "[redacted]"}',
      tag: 'login_submit',
    );

    loginNotifier.updateState(
      email: email,
      emailError: null,
      passwordError: null,
      globalError: AuthStrings.errLoginUnavailable,
    );
  }
}

// Screen-scoped submit state; dispose when no longer listened to.
final loginSubmitProvider =
    AsyncNotifierProvider.autoDispose<LoginSubmitNotifier, void>(
  LoginSubmitNotifier.new,
  name: 'loginSubmitProvider',
);
