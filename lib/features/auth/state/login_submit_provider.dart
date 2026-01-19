import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Patterns to detect invalid credentials error from Supabase.
const _kInvalidCredentialsPatterns = ['invalid', 'credentials'];

/// Patterns to detect email confirmation required error from Supabase.
const _kEmailConfirmationPatterns = ['confirm'];

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
    final message = error.message.toLowerCase();

    // Combined: code OR message pattern (defensive)
    final isInvalidCredentials = code == 'invalid_credentials' ||
        code == 'invalid_grant' ||
        _kInvalidCredentialsPatterns.every(message.contains);

    final isEmailNotConfirmed = code == 'email_not_confirmed' ||
        code == 'otp_expired' ||
        _kEmailConfirmationPatterns.every(message.contains);

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

    // Log unrecognized auth errors for inspection
    log.i(
      'auth_error_unrecognized: code=${code ?? "null"}, message=${sanitizeError(message) ?? message}',
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
