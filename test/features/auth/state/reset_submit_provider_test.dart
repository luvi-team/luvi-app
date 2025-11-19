import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/state/reset_submit_provider.dart';
import 'package:luvi_services/supabase_service.dart';
import 'package:luvi_services/init_mode.dart';

void main() {
  setUp(() {
    final originalResolve = InitModeBridge.resolve;
    // Ensure Supabase is considered not initialized.
    SupabaseService.resetForTest();
    // Ensure cleanup even if a test fails.
    addTearDown(() {
      InitModeBridge.resolve = originalResolve;
    });
  });

  test('Test mode: does not throw when Supabase is not initialized', () async {
    InitModeBridge.resolve = () => InitMode.test;

    // Should complete without throwing due to test-mode silent behavior.
    await submitReset('user@example.com');
  });

  test('Prod path: throws when Supabase is not initialized (override to simulate prod)', () async {
    InitModeBridge.resolve = () => InitMode.prod;
    // Force production-like behavior even under kDebugMode in unit tests.
    await runWithResetSilentOverride(false, () async {
      await expectLater(
        submitReset('user@example.com'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Supabase'),
          ),
        ),
      );
    });
  });
}
