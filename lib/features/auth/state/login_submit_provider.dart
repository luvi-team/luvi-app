import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
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
    await loginNotifier.validateAndSubmit();

    final loginAsync = ref.read(loginProvider);
    if (loginAsync.isLoading) {
      // Provider still loading; return early to avoid duplicate submission
      state = const AsyncData(null);
      return;
    }
    if (loginAsync.hasError) {
      // Provider has an error; propagate it
      loginNotifier.setGlobalError(AuthStrings.errLoginUnavailable);
      state = const AsyncData(null);
      return;
    }
    final loginState = loginAsync.requireValue;
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
        password: password,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _mapAuthException({
    required AuthException error,
    required LoginNotifier loginNotifier,
    required String email,
    required String password,
  }) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid') || message.contains('credentials')) {
      loginNotifier.updateState(
        email: email,
        password: password,
        emailError: AuthStrings.invalidCredentials,
        passwordError: null,
        globalError: null,
      );
    } else if (message.contains('confirm')) {
      loginNotifier.updateState(
        email: email,
        password: password,
        emailError: null,
        passwordError: null,
        globalError: AuthStrings.errConfirmEmail,
      );
    } else {
      loginNotifier.updateState(
        email: email,
        password: password,
        emailError: null,
        passwordError: null,
        globalError: AuthStrings.errLoginUnavailable,
      );
    }
  }
}

// Screen-scoped submit state; dispose when no longer listened to.
final loginSubmitProvider =
    AsyncNotifierProvider.autoDispose<LoginSubmitNotifier, void>(
  LoginSubmitNotifier.new,
  name: 'loginSubmitProvider',
);
