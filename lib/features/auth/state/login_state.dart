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
  @override
  FutureOr<LoginState> build() => LoginState.initial();

  LoginState _current() => state.value ?? LoginState.initial();

  void setEmail(String value) {
    final current = _current();
    state = AsyncData(
      current.copyWith(
        email: value,
        emailError: current.emailError,
        passwordError: current.passwordError,
        globalError: current.globalError,
      ),
    );
  }

  void setPassword(String value) {
    final current = _current();
    state = AsyncData(
      current.copyWith(
        password: value,
        emailError: current.emailError,
        passwordError: current.passwordError,
        globalError: current.globalError,
      ),
    );
  }

  void clearGlobalError() {
    final current = _current();
    state = AsyncData(current.copyWith(globalError: null));
  }

  /// Eine (1) kanonische Variante inkl. globalError – kompatibel zu Provider/Tests.
  void updateState({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? globalError,
  }) {
    final current = _current();
    state = AsyncData(
      current.copyWith(
        email: email ?? current.email,
        password: password ?? current.password,
        emailError: emailError,
        passwordError: passwordError,
        globalError: globalError,
      ),
    );
  }

  /// MIWF: einfache Client-Validierung; Server-Submit passiert im Submit-Provider.
  Future<void> validateAndSubmit() async {
    state = await AsyncValue.guard(() async {
      final current = _current();

      String? eErr;
      String? pErr;

      if (!current.email.contains('@')) {
        eErr = AuthStrings.errEmailInvalid;
      }
      if (current.password.length < 6) {
        pErr = AuthStrings.errPasswordInvalid;
      }

      return current.copyWith(
        emailError: eErr,
        passwordError: pErr,
        globalError: null,
      );
    });
  }

  /// Hilfsmethode für Tests, um synchronen Zugriff zu vereinfachen.
  LoginState debugState() => _current();
}

final loginProvider = AsyncNotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
