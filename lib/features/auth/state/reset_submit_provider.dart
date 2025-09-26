import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  ResetSubmitNotifier() : super(const AsyncData(null));

  Future<void> submit(
    String email, {
    required FutureOr<void> Function() onSuccess,
  }) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncLoading();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state = const AsyncData(null);
      await onSuccess();
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final resetSubmitProvider =
    StateNotifierProvider<ResetSubmitNotifier, AsyncValue<void>>(
  (ref) => ResetSubmitNotifier(),
);
