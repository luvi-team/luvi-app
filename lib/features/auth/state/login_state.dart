import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/validation/email_validator.dart';

class LoginState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? globalError;

  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.globalError,
  });

  factory LoginState.initial() => const LoginState();

  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;

  LoginState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? globalError,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      // Fehlerfelder bewusst direkt übernehmen (auch null zum Leeren)
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

  void setPassword(String value) => updateState(password: value);

  void clearGlobalError() => updateState(globalError: null);

  void setGlobalError(String message) => updateState(globalError: message);

  /// Eine (1) kanonische Variante inkl. globalError – kompatibel zu Provider/Tests.
  void updateState({
    String? email,
    String? password,
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
        password: password ?? preserved.password,
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
  Future<void> validate() async {
    state = await AsyncValue.guard(() async {
      final current = _current();
      final trimmedEmail = current.email.trim();
      final trimmedPassword = current.password.trim();

      String? eErr;
      String? pErr;

      if (trimmedEmail.isEmpty) {
        eErr = AuthStrings.errEmailEmpty;
      } else if (!EmailValidator.isValid(trimmedEmail)) {
        eErr = AuthStrings.errEmailInvalid;
      }

      if (trimmedPassword.isEmpty) {
        pErr = AuthStrings.errPasswordEmpty;
      } else if (trimmedPassword.length < _kMinPasswordLength) {
        pErr = AuthStrings.errPasswordInvalid;
      }

      return current.copyWith(
        email: trimmedEmail,
        password: trimmedPassword,
        emailError: eErr,
        passwordError: pErr,
        // Only clear globalError when validation passes for both fields.
        globalError: (eErr == null && pErr == null)
            ? null
            : current.globalError,
      );
    });
  }

  /// Backward-compatible shim used by existing call sites and tests.
  /// Performs client-side validation; network submission remains elsewhere.
  Future<void> validateAndSubmit() async {
    await validate();
  }

  @visibleForTesting
  /// Helper method for tests to simplify synchronous access.
  LoginState debugState() => _current();
}

// Screen-scoped form state; dispose automatically when screen is gone.
final loginProvider = AsyncNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  LoginNotifier.new,
  name: 'loginProvider',
);
