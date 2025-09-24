import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  void setEmail(String v) => state = LoginState(
        email: v,
        password: state.password,
        emailError: state.emailError,
        passwordError: state.passwordError,
        globalError: state.globalError,
      );

  void setPassword(String v) => state = LoginState(
        email: state.email,
        password: v,
        emailError: state.emailError,
        passwordError: state.passwordError,
        globalError: state.globalError,
      );

  void clearGlobalError() => state = LoginState(
        email: state.email,
        password: state.password,
        emailError: state.emailError,
        passwordError: state.passwordError,
        globalError: null,
      );

  void updateState({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? globalError,
  }) {
    state = LoginState(
      email: email ?? state.email,
      password: password ?? state.password,
      // accept provided values directly, even if null (clears old errors)
      emailError: emailError,
      passwordError: passwordError,
      globalError: globalError,
    );
  }

  /// MIWF-Validierung gemäß Figma-Fehlertexten.
  void validateAndSubmit() {
    String? eErr;
    String? pErr;
    if (!state.email.contains('@')) {
      eErr = 'Ups, bitte E-Mail überprüfen';
    }
    if (state.password.length < 6) {
      pErr = 'Ups, bitte Passwort überprüfen';
    }
    state = LoginState(
      email: state.email,
      password: state.password,
      emailError: eErr,
      passwordError: pErr,
      globalError: null,
    );
    // Supabase sign-in folgt im nächsten Schritt (MVP).
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);
