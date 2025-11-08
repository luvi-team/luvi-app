import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kProfileMode, visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/init_mode.dart';

class ResetSubmitNotifier extends AsyncNotifier<void> {
  // Instance-scoped test override to avoid global mutable state.
  bool? _testSilentOverride;

  @visibleForTesting
  void setTestOverride(bool? value) {
    _testSilentOverride = value;
  }

  @override
  FutureOr<void> build() {
    // No initialization needed; state is managed through submit().
  }

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
      await submitReset(email, silentOverride: _testSilentOverride);
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

// Zone key for per-test overrides to avoid process-global mutable state.
const Object _zoneKeyResetSilentOverride = #resetSilentOverride;

/// Helper for tests: runs [body] with a zone-scoped override that controls
/// the silent behavior of [submitReset] when Supabase is not initialized.
///
/// This avoids global mutable state and is safe for parallel test execution as
/// long as each test uses its own asynchronous chain.
@visibleForTesting
Future<T> runWithResetSilentOverride<T>(bool? value, Future<T> Function() body) async {
  return runZoned(
    body,
    zoneValues: <Object, Object?>{_zoneKeyResetSilentOverride: value},
  );
}

Future<void> submitReset(String email, {bool? silentOverride}) async {
  // In tests or when Supabase isn't initialized, simulate success to keep
  // widget tests deterministic and offline.
  if (!SupabaseService.isInitialized) {
    final isTest = InitModeBridge.resolve() == InitMode.test;
    final zoneOverride = Zone.current[_zoneKeyResetSilentOverride] as bool?;
    final allowSilent = (silentOverride ?? zoneOverride) ?? (kDebugMode || kProfileMode || isTest);
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
