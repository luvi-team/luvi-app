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

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      emailError: state.emailError,
      passwordError: state.passwordError,
      globalError: state.globalError,
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      emailError: state.emailError,
      passwordError: state.passwordError,
      globalError: state.globalError,
    );
  }

  void clearGlobalError() {
    state = state.copyWith(globalError: null);
  }

  /// Eine (1) kanonische Variante inkl. globalError – kompatibel zu Provider/Tests.
  void updateState({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? globalError,
  }) {
    state = state.copyWith(
      email: email ?? state.email,
      password: password ?? state.password,
      emailError: emailError,
      passwordError: passwordError,
      globalError: globalError,
    );
  }

  /// MIWF: einfache Client-Validierung; Server-Submit passiert im Submit-Provider.
  void validateAndSubmit() {
    String? eErr;
    String? pErr;

    if (!state.email.contains('@')) {
      eErr = AuthStrings.errEmailInvalid;
    }
    if (state.password.length < 6) {
      pErr = AuthStrings.errPasswordInvalid;
    }

    state = state.copyWith(
      emailError: eErr,
      passwordError: pErr,
      globalError: null,
    );
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);
