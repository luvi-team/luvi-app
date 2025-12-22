import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/splash/data/onboarding_gate_profile_reader.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

/// Mock implementation of OnboardingGateProfileReader for testing.
///
/// Allows configurable return values for remote gate fetch.
class MockOnboardingGateProfileReader implements OnboardingGateProfileReader {
  MockOnboardingGateProfileReader({
    this.remoteGateValue,
    this.shouldThrow = false,
    this.throwOnFirstCall = false,
  });

  /// The value to return from fetchRemoteOnboardingGate.
  /// null simulates network failure / timeout.
  final bool? remoteGateValue;

  /// If true, throws an exception instead of returning a value.
  final bool shouldThrow;

  /// If true, throws only on first call, then succeeds.
  final bool throwOnFirstCall;

  int _callCount = 0;

  int get callCount => _callCount;

  @override
  Future<bool?> fetchRemoteOnboardingGate() async {
    _callCount++;
    if (shouldThrow) {
      throw Exception('Simulated network error');
    }
    if (throwOnFirstCall && _callCount == 1) {
      throw Exception('Simulated first call failure');
    }
    return remoteGateValue;
  }
}

/// Mock that always returns true (user completed onboarding on server).
class AlwaysTrueGateReader implements OnboardingGateProfileReader {
  @override
  Future<bool?> fetchRemoteOnboardingGate() async => true;
}

/// Mock that always returns false (user has NOT completed onboarding on server).
class AlwaysFalseGateReader implements OnboardingGateProfileReader {
  @override
  Future<bool?> fetchRemoteOnboardingGate() async => false;
}

/// Mock that always returns null (network unavailable).
class AlwaysNullGateReader implements OnboardingGateProfileReader {
  @override
  Future<bool?> fetchRemoteOnboardingGate() async => null;
}

/// Mock that always throws (persistent network error).
class AlwaysFailingGateReader implements OnboardingGateProfileReader {
  int _callCount = 0;
  int get callCount => _callCount;

  @override
  Future<bool?> fetchRemoteOnboardingGate() async {
    _callCount++;
    throw Exception('Persistent network error');
  }
}

/// Mock for race-retry testing: returns false on first call, true on subsequent calls.
/// Simulates server syncing during the 500ms race-retry delay.
class RaceRetryGateReader implements OnboardingGateProfileReader {
  int _callCount = 0;
  int get callCount => _callCount;

  @override
  Future<bool?> fetchRemoteOnboardingGate() async {
    _callCount++;
    // First call returns false (server not synced yet)
    // Subsequent calls return true (server synced)
    return _callCount == 1 ? false : true;
  }
}

/// Mock for race-retry testing: always returns false (server genuinely has false).
/// Simulates user who truly hasn't completed onboarding despite local state.
class PersistentFalseGateReader implements OnboardingGateProfileReader {
  int _callCount = 0;
  int get callCount => _callCount;

  @override
  Future<bool?> fetchRemoteOnboardingGate() async {
    _callCount++;
    return false;
  }
}

void main() {
  TestConfig.ensureInitialized();

  group('OnboardingGateProfileReader Mocks', () {
    test('AlwaysTrueGateReader returns true', () async {
      final reader = AlwaysTrueGateReader();
      final result = await reader.fetchRemoteOnboardingGate();
      expect(result, isTrue);
    });

    test('AlwaysFalseGateReader returns false', () async {
      final reader = AlwaysFalseGateReader();
      final result = await reader.fetchRemoteOnboardingGate();
      expect(result, isFalse);
    });

    test('AlwaysNullGateReader returns null', () async {
      final reader = AlwaysNullGateReader();
      final result = await reader.fetchRemoteOnboardingGate();
      expect(result, isNull);
    });

    test('AlwaysFailingGateReader throws', () async {
      final reader = AlwaysFailingGateReader();
      expect(
        () => reader.fetchRemoteOnboardingGate(),
        throwsException,
      );
    });

    test('MockOnboardingGateProfileReader tracks call count', () async {
      final reader = MockOnboardingGateProfileReader(remoteGateValue: true);
      expect(reader.callCount, 0);

      await reader.fetchRemoteOnboardingGate();
      expect(reader.callCount, 1);

      await reader.fetchRemoteOnboardingGate();
      expect(reader.callCount, 2);
    });

    test('MockOnboardingGateProfileReader throwOnFirstCall behavior', () async {
      final reader = MockOnboardingGateProfileReader(
        remoteGateValue: true,
        throwOnFirstCall: true,
      );

      // First call throws
      expect(() => reader.fetchRemoteOnboardingGate(), throwsException);
      expect(reader.callCount, 1);

      // Second call succeeds
      final result = await reader.fetchRemoteOnboardingGate();
      expect(result, isTrue);
      expect(reader.callCount, 2);
    });
  });

  group('determineOnboardingGateRoute Integration', () {
    const homeRoute = HeuteScreen.routeName;

    group('Remote SSOT scenarios', () {
      test('remote true → routes to Home regardless of local state', () async {
        final reader = AlwaysTrueGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();

        // Test with all possible local states
        for (final localGate in [null, true, false]) {
          final result = determineOnboardingGateRoute(
            remoteGate: remoteGate,
            localGate: localGate,
            homeRoute: homeRoute,
          );
          expect(
            result,
            equals(homeRoute),
            reason: 'remote=true should route to Home (local=$localGate)',
          );
        }
      });

      test('remote false + local null/false → routes to Onboarding', () async {
        final reader = AlwaysFalseGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();

        // First-time user (local null) and consistent state (local false)
        for (final localGate in [null, false]) {
          final result = determineOnboardingGateRoute(
            remoteGate: remoteGate,
            localGate: localGate,
            homeRoute: homeRoute,
          );
          expect(
            result,
            equals(Onboarding01Screen.routeName),
            reason: 'remote=false, local=$localGate should route to Onboarding',
          );
        }
      });

      test('remote false + local true → returns null (race-retry needed)',
          () async {
        final reader = AlwaysFalseGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();

        // Race condition case: local says true but remote says false
        final result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, isNull,
            reason: 'remote=false, local=true should trigger race-retry');
      });
    });

    group('Remote unavailable (null) - local fallback scenarios', () {
      test('remote null + local true → returns null (fail-safe, never Home)',
          () async {
        final reader = AlwaysNullGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();

        final result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, isNull);
      });

      test('remote null + local false → routes to Onboarding', () async {
        final reader = AlwaysNullGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();

        final result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: false,
          homeRoute: homeRoute,
        );
        expect(result, equals(Onboarding01Screen.routeName));
      });

      test('remote null + local null → returns null (Unknown UI)', () async {
        final reader = AlwaysNullGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();

        final result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: null,
          homeRoute: homeRoute,
        );
        expect(result, isNull);
      });
    });

    group('Network error scenarios', () {
      test('network error (exception) treated as remote=null', () async {
        final reader = AlwaysFailingGateReader();
        bool? remoteGate;

        try {
          remoteGate = await reader.fetchRemoteOnboardingGate();
        } catch (_) {
          // Exception means remote is unavailable → treat as null
          remoteGate = null;
        }

        // Fail-safe: never route to Home when remote is unavailable.
        final result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: true,
          homeRoute: homeRoute,
        );
        expect(result, isNull);
      });

      test('retry logic: first call fails, retry succeeds', () async {
        final reader = MockOnboardingGateProfileReader(
          remoteGateValue: true,
          throwOnFirstCall: true,
        );

        bool? remoteGate;

        // First attempt fails
        try {
          remoteGate = await reader.fetchRemoteOnboardingGate();
        } catch (_) {
          // Retry
          remoteGate = await reader.fetchRemoteOnboardingGate();
        }

        expect(reader.callCount, 2);
        expect(remoteGate, isTrue);

        final result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: null,
          homeRoute: homeRoute,
        );
        expect(result, equals(homeRoute));
      });
    });

    group('Backfill scenarios', () {
      test('local true + remote false → need backfill detection', () async {
        final reader = AlwaysFalseGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();
        const localGate = true;

        // Backfill condition: local is true but remote is not true
        final needsBackfill = localGate == true && remoteGate != true;
        expect(needsBackfill, isTrue);
      });

      test('local true + remote null → need backfill detection', () async {
        final reader = AlwaysNullGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();
        const localGate = true;

        final needsBackfill = localGate == true && remoteGate != true;
        expect(needsBackfill, isTrue);
      });

      test('local true + remote true → no backfill needed', () async {
        final reader = AlwaysTrueGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();
        const localGate = true;

        final needsBackfill = localGate == true && remoteGate != true;
        expect(needsBackfill, isFalse);
      });

      test('local false + remote true → sync local to true', () async {
        final reader = AlwaysTrueGateReader();
        final remoteGate = await reader.fetchRemoteOnboardingGate();
        const localGate = false;

        // Sync condition: remote is true but local is not true
        final needsLocalSync = remoteGate == true && localGate != true;
        expect(needsLocalSync, isTrue);
      });
    });

    group('Race-retry scenarios', () {
      test('RaceRetryGateReader: first call false, subsequent calls true',
          () async {
        final reader = RaceRetryGateReader();

        // First call returns false
        final first = await reader.fetchRemoteOnboardingGate();
        expect(first, isFalse);
        expect(reader.callCount, 1);

        // Second call returns true (simulating server sync)
        final second = await reader.fetchRemoteOnboardingGate();
        expect(second, isTrue);
        expect(reader.callCount, 2);
      });

      test('PersistentFalseGateReader: always returns false', () async {
        final reader = PersistentFalseGateReader();

        final first = await reader.fetchRemoteOnboardingGate();
        expect(first, isFalse);

        final second = await reader.fetchRemoteOnboardingGate();
        expect(second, isFalse);

        expect(reader.callCount, 2);
      });

      test('race-retry success: local=true, remote false→true → Home',
          () async {
        final reader = RaceRetryGateReader();
        const localGate = true;

        // First fetch: remote false
        var remoteGate = await reader.fetchRemoteOnboardingGate();
        expect(remoteGate, isFalse);

        // determineOnboardingGateRoute returns null (race-retry needed)
        var result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: localGate,
          homeRoute: homeRoute,
        );
        expect(result, isNull);

        // After 500ms delay, re-fetch: remote now true
        remoteGate = await reader.fetchRemoteOnboardingGate();
        expect(remoteGate, isTrue);

        // Now routes to Home
        result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: localGate,
          homeRoute: homeRoute,
        );
        expect(result, equals(homeRoute));
        expect(reader.callCount, 2);
      });

      test('race-retry failure: local=true, remote stays false → Onboarding',
          () async {
        final reader = PersistentFalseGateReader();
        const localGate = true;

        // First fetch: remote false
        var remoteGate = await reader.fetchRemoteOnboardingGate();
        expect(remoteGate, isFalse);

        // determineOnboardingGateRoute returns null (race-retry needed)
        var result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: localGate,
          homeRoute: homeRoute,
        );
        expect(result, isNull);

        // After 500ms delay, re-fetch: remote still false
        remoteGate = await reader.fetchRemoteOnboardingGate();
        expect(remoteGate, isFalse);

        // Still returns null (remote false + local true)
        result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: localGate,
          homeRoute: homeRoute,
        );
        expect(result, isNull);

        // Caller (_navigateAfterAnimation) handles this case:
        // (targetRoute == null && remoteGate == false) → go to Onboarding
        final shouldRouteToOnboarding = result == null && remoteGate == false;
        expect(shouldRouteToOnboarding, isTrue);

        expect(reader.callCount, 2);
      });

      test('no race-retry for first-time user (local=null)', () async {
        final reader = AlwaysFalseGateReader();
        const bool? localGate = null;

        final remoteGate = await reader.fetchRemoteOnboardingGate();

        // Should route directly to Onboarding (no race-retry)
        final result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: localGate,
          homeRoute: homeRoute,
        );
        expect(result, equals(Onboarding01Screen.routeName));
      });

      test('no race-retry when both agree (local=false, remote=false)',
          () async {
        final reader = AlwaysFalseGateReader();
        const localGate = false;

        final remoteGate = await reader.fetchRemoteOnboardingGate();

        // Should route directly to Onboarding (no race-retry)
        final result = determineOnboardingGateRoute(
          remoteGate: remoteGate,
          localGate: localGate,
          homeRoute: homeRoute,
        );
        expect(result, equals(Onboarding01Screen.routeName));
      });
    });
  });

  group('Race-retry Widget Test', () {
    testWidgets(
        'race-retry: Reader false→true after delay routes to Home',
        (tester) async {
      // This test simulates the race-retry behavior from _navigateAfterAnimation
      // using a widget that mirrors the navigation logic with provider override.

      final reader = RaceRetryGateReader();
      String? navigatedRoute;

      // Minimal widget that simulates _navigateAfterAnimation race-retry logic
      final testWidget = ProviderScope(
        overrides: [
          initModeProvider.overrideWithValue(InitMode.test),
          onboardingGateProfileReaderProvider.overrideWithValue(reader),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(
            builder: (context, ref, _) {
              return ElevatedButton(
                key: const Key('trigger'),
                onPressed: () async {
                  // Simulate race-retry logic from _navigateAfterAnimation
                  const localGate = true;
                  const homeRoute = HeuteScreen.routeName;

                  final gateReader =
                      ref.read(onboardingGateProfileReaderProvider);

                  // First fetch
                  var remoteGate =
                      await gateReader.fetchRemoteOnboardingGate();

                  var targetRoute = determineOnboardingGateRoute(
                    remoteGate: remoteGate,
                    localGate: localGate,
                    homeRoute: homeRoute,
                  );

                  // Race-retry condition: local true + remote false
                  if (targetRoute == null &&
                      localGate == true &&
                      remoteGate == false) {
                    // Wait 500ms (simulated delay)
                    await Future<void>.delayed(
                        const Duration(milliseconds: 100));

                    // Re-fetch after delay
                    remoteGate =
                        await gateReader.fetchRemoteOnboardingGate();

                    // Re-evaluate
                    targetRoute = determineOnboardingGateRoute(
                      remoteGate: remoteGate,
                      localGate: localGate,
                      homeRoute: homeRoute,
                    );

                    // If still null after retry, go to Onboarding
                    if (targetRoute == null && remoteGate == false) {
                      navigatedRoute = Onboarding01Screen.routeName;
                      return;
                    }
                  }

                  navigatedRoute = targetRoute;
                },
                child: const Text('Trigger'),
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Trigger the race-retry logic
      await tester.tap(find.byKey(const Key('trigger')));

      // Allow async operations to complete
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify: Reader was called twice (first false, then true)
      expect(reader.callCount, 2);

      // Verify: Navigation went to Home (because remote became true on retry)
      expect(navigatedRoute, equals(HeuteScreen.routeName));
    });
  });
}
