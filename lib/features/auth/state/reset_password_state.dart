import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ResetPasswordError { invalidEmail }

@immutable
class ResetPasswordState {
  const ResetPasswordState({this.email = '', this.error, this.isValid = false});

  final String email;
  final ResetPasswordError? error;
  final bool isValid;

  factory ResetPasswordState.initial() => const ResetPasswordState();

  static const Object _sentinel = Object();

  ResetPasswordState copyWith({
    String? email,
    Object? error = _sentinel,
    bool? isValid,
  }) {
    return ResetPasswordState(
      email: email ?? this.email,
      error: identical(error, _sentinel)
          ? this.error
          : error as ResetPasswordError?,
      isValid: isValid ?? this.isValid,
    );
  }
}

class ResetPasswordNotifier extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => ResetPasswordState.initial();

  static final RegExp _emailRegex =
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,63}$');

  void setEmail(String value) {
    final trimmed = value.trim();
    final validation = _validateEmail(trimmed);
    state = state.copyWith(
      email: trimmed,
      error: validation,
      isValid: validation == null && trimmed.isNotEmpty,
    );
  }

  void validate() {
    final validation = _validateEmail(state.email);
    state = state.copyWith(
      error: validation,
      isValid: validation == null && state.email.isNotEmpty,
    );
  }

  ResetPasswordError? _validateEmail(String email) {
    if (email.isEmpty) {
      return null;
    }
    return _emailRegex.hasMatch(email) ? null : ResetPasswordError.invalidEmail;
  }
}

final resetPasswordProvider =
    NotifierProvider.autoDispose<ResetPasswordNotifier, ResetPasswordState>(
      ResetPasswordNotifier.new,
      name: 'resetPasswordProvider',
    );
