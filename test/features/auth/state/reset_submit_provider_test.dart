import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/state/reset_submit_provider.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/init_mode.dart';

void main() {
  setUp(() {
    // Ensure Supabase is considered not initialized.
    SupabaseService.resetForTest();
    // Clear any previous override.
    debugSetResetSilentOverride(null);
  });

  tearDown(() {
    // Reset override and mode resolver after each test.
    debugSetResetSilentOverride(null);
    InitModeBridge.resolve = () => InitMode.prod;
  });

  test('Test mode: does not throw when Supabase is not initialized', () async {
    InitModeBridge.resolve = () => InitMode.test;

    // Should complete without throwing due to test-mode silent behavior.
    await submitReset('user@example.com');
  });

  test('Prod path: throws when Supabase is not initialized (override to simulate prod)', () async {
    InitModeBridge.resolve = () => InitMode.prod;
    // Force production-like behavior even under kDebugMode in unit tests.
    debugSetResetSilentOverride(false);

    expect(
      () => submitReset('user@example.com'),
      throwsA(isA<Exception>()),
    );
  });
}

