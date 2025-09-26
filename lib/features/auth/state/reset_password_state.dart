import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/strings/auth_strings.dart';

@immutable
class ResetPasswordState {
  const ResetPasswordState({
    this.email = '',
    this.errorText,
    this.isValid = false,
  });

  final String email;
  final String? errorText;
  final bool isValid;
}

class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  ResetPasswordNotifier() : super(const ResetPasswordState());

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  void setEmail(String value) {
    final trimmed = value.trim();
    final error = _validateEmail(trimmed);
    state = ResetPasswordState(
      email: trimmed,
      errorText: error,
      isValid: error == null && trimmed.isNotEmpty,
    );
  }

  void validate() {
    final error = _validateEmail(state.email);
    state = ResetPasswordState(
      email: state.email,
      errorText: error,
      isValid: error == null && state.email.isNotEmpty,
    );
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return null;
    }
    return _emailRegex.hasMatch(email) ? null : AuthStrings.errEmailInvalid;
  }
}

final resetPasswordProvider =
    StateNotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
  (ref) => ResetPasswordNotifier(),
);
