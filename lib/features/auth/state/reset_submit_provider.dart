import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetSubmitNotifier extends AsyncNotifier<void> {
  @override
  void build() {}

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
    AsyncNotifierProvider.autoDispose<ResetSubmitNotifier, void>(
  ResetSubmitNotifier.new,
);
