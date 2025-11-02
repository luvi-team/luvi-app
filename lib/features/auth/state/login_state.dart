import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';

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
  static final RegExp _emailRegex =
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,63}$');
  static const int _kMinPasswordLength = 8;
  static const Object _noChange = Object();

  @override
  FutureOr<LoginState> build() => LoginState.initial();

  LoginState _current() => state.value ?? LoginState.initial();

  LoginState get currentState => _current();

  void setEmail(String value) => updateState(email: value);

  void setPassword(String value) => updateState(password: value);

  void clearGlobalError() => updateState(globalError: null);

  /// Eine (1) kanonische Variante inkl. globalError – kompatibel zu Provider/Tests.
  void updateState({
    String? email,
    String? password,
    Object? emailError = _noChange,
    Object? passwordError = _noChange,
    Object? globalError = _noChange,
  }) {
    final current = _current();
    state = AsyncData(
      current.copyWith(
        email: email ?? current.email,
        password: password ?? current.password,
        emailError: identical(emailError, _noChange)
            ? current.emailError
            : emailError as String?,
        passwordError: identical(passwordError, _noChange)
            ? current.passwordError
            : passwordError as String?,
        globalError: identical(globalError, _noChange)
            ? current.globalError
            : globalError as String?,
      ),
    );
  }

  /// MIWF: Simple client-side validation; server submit happens in the submit provider.
  Future<void> validateAndSubmit() async {
    state = await AsyncValue.guard(() async {
      final current = _current();

      String? eErr;
      String? pErr;

      if (!_emailRegex.hasMatch(current.email)) {
        eErr = AuthStrings.errEmailInvalid;
      }
      if (current.password.length < _kMinPasswordLength) {
        pErr = AuthStrings.errPasswordInvalid;
      }

      return current.copyWith(
        emailError: eErr,
        passwordError: pErr,
        globalError: null,
      );
    });
  }

  /// Helper method for tests to simplify synchronous access.
  LoginState debugState() => _current();
}

final loginProvider = AsyncNotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
  name: 'loginProvider',
);
