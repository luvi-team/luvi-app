import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/validation/email_validator.dart';

/// Login form state.
///
/// SECURITY: Password is intentionally NOT stored in this state class.
/// Passwords should only live in UI TextEditingController and be passed
/// directly to validation/submit methods as parameters.
class LoginState {
  final String email;
  final String? emailError;
  final String? passwordError;
  final String? globalError;

  const LoginState({
    this.email = '',
    this.emailError,
    this.passwordError,
    this.globalError,
  });

  factory LoginState.initial() => const LoginState();

  /// Returns true if form is ready for submission.
  ///
  /// Note: Password validation happens via validate(password: ...) which sets
  /// passwordError if invalid. After successful validation, passwordError is null.
  bool get isValid =>
      email.isNotEmpty && emailError == null && passwordError == null;

  LoginState copyWith({
    String? email,
    String? emailError,
    String? passwordError,
    String? globalError,
  }) {
    return LoginState(
      email: email ?? this.email,
      // Deliberately pass error fields directly (including null to clear them)
      emailError: emailError,
      passwordError: passwordError,
      globalError: globalError,
    );
  }
}

class LoginNotifier extends AsyncNotifier<LoginState> {
  // Client-side sanity guard; server-side validation stays authoritative.
  static const int _kMinPasswordLength = 8;
  static const Object _noChange = Object();

  @override
  FutureOr<LoginState> build() => LoginState.initial();

  LoginState _current() => state.value ?? LoginState.initial();

  LoginState get currentState => _current();

  void setEmail(String value) => updateState(email: value);

  void clearGlobalError() => updateState(globalError: null);

  void setGlobalError(String message) => updateState(globalError: message);

  /// Canonical state update method.
  ///
  /// SECURITY: Password is intentionally NOT a parameter here.
  /// Passwords should only be passed to validate/validateAndSubmit.
  void updateState({
    String? email,
    Object? emailError = _noChange,
    Object? passwordError = _noChange,
    Object? globalError = _noChange,
  }) {
    // Preserve any existing data even when state is loading/errored.
    final preserved = state.maybeWhen(
      data: (d) => d,
      orElse: () => state.value ?? LoginState.initial(),
    );
    state = AsyncData(
      preserved.copyWith(
        email: email ?? preserved.email,
        emailError: identical(emailError, _noChange)
            ? preserved.emailError
            : emailError as String?,
        passwordError: identical(passwordError, _noChange)
            ? preserved.passwordError
            : passwordError as String?,
        globalError: identical(globalError, _noChange)
            ? preserved.globalError
            : globalError as String?,
      ),
    );
  }

  /// Performs client-side validation only.
  ///
  /// Server-side submission is handled separately by login_submit_provider.
  ///
  /// SECURITY: [password] is validated but NOT persisted in state.
  /// Password should only live in TextEditingController, not in provider state.
  void validate({required String password}) {
    try {
      final current = _current();
      final trimmedEmail = current.email.trim();
      // SECURITY: Don't trim passwords - they may contain intentional spaces.

      String? eErr;
      String? pErr;

      if (trimmedEmail.isEmpty) {
        eErr = AuthStrings.errEmailEmpty;
      } else if (!EmailValidator.isValid(trimmedEmail)) {
        eErr = AuthStrings.errEmailInvalid;
      }

      if (password.isEmpty) {
        pErr = AuthStrings.errPasswordEmpty;
      } else if (password.length < _kMinPasswordLength) {
        pErr = AuthStrings.errPasswordInvalid;
      }

      state = AsyncData(
        current.copyWith(
          email: trimmedEmail,
          emailError: eErr,
          passwordError: pErr,
          globalError:
              (eErr == null && pErr == null) ? null : current.globalError,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Performs client-side validation only and completes synchronously.
  /// Any network submission or remote auth flow is handled by
  /// `login_submit_provider` to avoid mixing concerns.
  ///
  /// SECURITY: [password] is validated but NOT persisted in state.
  Future<void> validateAndSubmit({required String password}) async {
    validate(password: password);
  }

  @visibleForTesting
  /// Helper method for tests to simplify synchronous access.
  LoginState debugState() => _current();
}

// Screen-scoped form state; dispose automatically when screen is gone.
final loginProvider =
    AsyncNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  LoginNotifier.new,
  name: 'loginProvider',
);
