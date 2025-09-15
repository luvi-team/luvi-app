import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final String email;
  final String password;
  final String? error;
  const LoginState({this.email = '', this.password = '', this.error});

  bool get isValid => email.isNotEmpty && password.isNotEmpty && error == null;
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  void setEmail(String v) => state = LoginState(
        email: v,
        password: state.password,
        error: state.error,
      );

  void setPassword(String v) => state = LoginState(
        email: state.email,
        password: v,
        error: state.error,
      );

  void setError(String? e) => state = LoginState(
        email: state.email,
        password: state.password,
        error: e,
      );
}

final loginProvider =
    StateNotifierProvider<LoginNotifier, LoginState>((ref) => LoginNotifier());
