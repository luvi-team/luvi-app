import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luvi_app/features/state/auth_controller.dart';

class LoginSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  LoginSubmitNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(authRepositoryProvider);
      final response = await repo.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return response;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void reset() => state = const AsyncData(null);
}

final loginSubmitProvider =
    StateNotifierProvider.autoDispose<LoginSubmitNotifier, AsyncValue<void>>(
  LoginSubmitNotifier.new,
);
