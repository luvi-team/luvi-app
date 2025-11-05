import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kProfileMode, visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/init_mode.dart';

class ResetSubmitNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit(
    String email, {
    required FutureOr<void> Function() onSuccess,
  }) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncLoading();
    // Ensure at least one event-loop turn where loading state is visible
    // so widget tests can observe the spinner after a tap.
    await Future<void>.delayed(const Duration(milliseconds: 1));
    try {
      await submitReset(email);
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

// Testability toggle: allows unit tests to simulate production behavior even when
// running under kDebugMode. Null = no override; true = force silent; false = force throw.
// IMPORTANT: Use addTearDown(() => debugSetResetSilentOverride(null)) in tests so cleanup
// runs even on failures. Alternatively, wrap test logic with runWithResetSilentOverride.
bool? _resetSilentOverride;

@visibleForTesting
void debugSetResetSilentOverride(bool? value) {
  // Allow clearing (setting to null) at any time; only assert when attempting
  // to set a non-null value while a previous non-null override is still active.
  assert(
    _resetSilentOverride == null || value == null,
    'Previous test did not reset _resetSilentOverride to null. '
    'Always call debugSetResetSilentOverride(null) in tearDown. '
    'Current value: $_resetSilentOverride, attempting to set: $value',
  );
  _resetSilentOverride = value;
}

/// Helper for tests: sets the override for the duration of [body] and restores
/// the previous value even if [body] throws.
@visibleForTesting
Future<T> runWithResetSilentOverride<T>(bool? value, Future<T> Function() body) async {
  final prev = _resetSilentOverride;
  _resetSilentOverride = value;
  try {
    return await body();
  } finally {
    _resetSilentOverride = prev;
  }
}

Future<void> submitReset(String email) async {
  // In tests or when Supabase isn't initialized, simulate success to keep
  // widget tests deterministic and offline.
  if (!SupabaseService.isInitialized) {
    final isTest = InitModeBridge.resolve() == InitMode.test;
    final allowSilent = _resetSilentOverride ?? (kDebugMode || kProfileMode || isTest);
    if (allowSilent) {
      // In debug/profile/test modes (or when overridden), allow silent success to keep flows offline.
      return;
    }
    throw StateError('Supabase is not initialized');
  }
  await supa.Supabase.instance.client.auth.resetPasswordForEmail(
    email,
    redirectTo: AppLinks.oauthRedirectUri,
  );
}
