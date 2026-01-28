import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/analytics/analytics_recorder.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/privacy/consent_config.dart';
import 'package:luvi_app/features/splash/state/splash_controller.dart';
import 'package:luvi_app/core/init/session_dependencies.dart';
import 'package:luvi_app/features/splash/state/splash_state.dart';
import 'package:luvi_services/device_state_service.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock DeviceStateService for testing.
class MockDeviceStateService extends DeviceStateService {
  MockDeviceStateService({
    required super.prefs,
    this.mockHasCompletedWelcome = true,
  });

  final bool mockHasCompletedWelcome;

  @override
  bool get hasCompletedWelcome => mockHasCompletedWelcome;
}

/// Mock UserStateService for testing.
class MockUserStateService extends UserStateService {
  MockUserStateService({
    required super.prefs,
    this.mockAcceptedConsentVersion,
    this.mockHasCompletedOnboarding,
    this.mockHasSeenWelcome,
  });

  final int? mockAcceptedConsentVersion;
  final bool? mockHasCompletedOnboarding;
  final bool? mockHasSeenWelcome;

  @override
  int? get acceptedConsentVersionOrNull => mockAcceptedConsentVersion;

  @override
  bool? get hasCompletedOnboardingOrNull => mockHasCompletedOnboarding;

  @override
  bool? get hasSeenWelcomeOrNull => mockHasSeenWelcome;

  @override
  Future<void> bindUser(String? userId) async {}

  @override
  Future<void> setHasCompletedOnboarding(bool value) async {}

  @override
  Future<void> setAcceptedConsentVersion(int version) async {}

  @override
  Future<void> markWelcomeSeen() async {}
}

/// Mock AnalyticsRecorder for testing.
class MockAnalyticsRecorder implements AnalyticsRecorder {
  final List<String> recordedEvents = [];

  @override
  void recordEvent(
    String name, {
    Map<String, Object?> properties = const <String, Object?>{},
  }) {
    recordedEvents.add(name);
  }
}

/// Default profile fetcher for tests - returns all gates passed.
Future<Map<String, dynamic>?> _defaultProfileFetcher() async {
  return <String, dynamic>{
    'accepted_consent_version': ConsentConfig.currentVersionInt,
    'has_completed_onboarding': true,
  };
}

/// Creates a test ProviderContainer with all necessary overrides.
ProviderContainer createTestContainer({
  bool isAuthenticated = true,
  String? currentUserId = 'test-uid',
  bool deviceHasCompletedWelcome = true,
  int? userAcceptedConsentVersion,
  bool? userHasCompletedOnboarding,
  bool? userHasSeenWelcome,
  Future<Map<String, dynamic>?> Function()? profileFetcher,
  MockAnalyticsRecorder? analytics,
  required SharedPreferences prefs,
}) {
  return ProviderContainer(
    overrides: [
      initModeProvider.overrideWithValue(InitMode.test),
      isAuthenticatedFnProvider.overrideWithValue(() => isAuthenticated),
      currentUserIdFnProvider.overrideWithValue(() => currentUserId),
      deviceStateServiceProvider.overrideWith(
        (_) async => MockDeviceStateService(
          prefs: prefs,
          mockHasCompletedWelcome: deviceHasCompletedWelcome,
        ),
      ),
      userStateServiceProvider.overrideWith(
        (_) async => MockUserStateService(
          prefs: prefs,
          mockAcceptedConsentVersion:
              userAcceptedConsentVersion ?? ConsentConfig.currentVersionInt,
          mockHasCompletedOnboarding: userHasCompletedOnboarding ?? true,
          mockHasSeenWelcome: userHasSeenWelcome ?? true,
        ),
      ),
      profileFetcherProvider.overrideWithValue(
        profileFetcher ?? _defaultProfileFetcher,
      ),
      analyticsRecorderProvider
          .overrideWithValue(analytics ?? MockAnalyticsRecorder()),
      onboardingBackfillProvider.overrideWithValue(
        ({required bool hasCompletedOnboarding}) async {},
      ),
    ],
  );
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SplashController Gate-Outcomes', () {
    test('welcome nicht gesehen → SplashResolved(welcome)', () async {
      final container = createTestContainer(
        prefs: prefs,
        deviceHasCompletedWelcome: false,
      );
      addTearDown(container.dispose);

      final controller = container.read(splashControllerProvider.notifier);

      // Initial state
      expect(container.read(splashControllerProvider), isA<SplashInitial>());

      // Run gate check
      await controller.checkGates();

      // Verify outcome
      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashResolved>());
      expect(
        (state as SplashResolved).targetRoute,
        equals(RoutePaths.welcome),
      );
    });

    test('nicht authentifiziert → SplashResolved(authSignIn)', () async {
      final container = createTestContainer(
        prefs: prefs,
        isAuthenticated: false,
        deviceHasCompletedWelcome: true,
      );
      addTearDown(container.dispose);

      final controller = container.read(splashControllerProvider.notifier);
      await controller.checkGates();

      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashResolved>());
      expect(
        (state as SplashResolved).targetRoute,
        equals(RoutePaths.authSignIn),
      );
    });

    test('profile fetch fail → SplashUnknown', () async {
      final container = createTestContainer(
        prefs: prefs,
        profileFetcher: () async => throw Exception('Network error'),
      );
      addTearDown(container.dispose);

      final controller = container.read(splashControllerProvider.notifier);
      await controller.checkGates();

      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashUnknown>());
      expect((state as SplashUnknown).canRetry, isTrue);
      expect(state.retryCount, equals(0));
    });

    test('consent outdated → SplashResolved(consentOptions)', () async {
      final container = createTestContainer(
        prefs: prefs,
        userAcceptedConsentVersion: null, // No consent accepted
        profileFetcher: () async => <String, dynamic>{
          'accepted_consent_version': null, // Remote also null
          'has_completed_onboarding': true,
        },
      );
      addTearDown(container.dispose);

      final controller = container.read(splashControllerProvider.notifier);
      await controller.checkGates();

      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashResolved>());
      expect(
        (state as SplashResolved).targetRoute,
        equals(RoutePaths.consentOptions),
      );
    });

    test('alle gates bestanden → SplashResolved(heute)', () async {
      final container = createTestContainer(
        prefs: prefs,
        deviceHasCompletedWelcome: true,
        isAuthenticated: true,
        userAcceptedConsentVersion: ConsentConfig.currentVersionInt,
        userHasCompletedOnboarding: true,
        profileFetcher: () async => <String, dynamic>{
          'accepted_consent_version': ConsentConfig.currentVersionInt,
          'has_completed_onboarding': true,
        },
      );
      addTearDown(container.dispose);

      final controller = container.read(splashControllerProvider.notifier);
      await controller.checkGates();

      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashResolved>());
      expect(
        (state as SplashResolved).targetRoute,
        equals(RoutePaths.heute),
      );
    });
  });

  group('SplashController Retry-Logik', () {
    test('retry nach Unknown → SplashResolved bei Erfolg', () async {
      int callCount = 0;

      final container = createTestContainer(
        prefs: prefs,
        profileFetcher: () async {
          callCount++;
          if (callCount <= 2) {
            // First two calls (initial + retry inside checkGates) fail
            throw Exception('Network error');
          }
          // Third call succeeds (from manual retry)
          return <String, dynamic>{
            'accepted_consent_version': ConsentConfig.currentVersionInt,
            'has_completed_onboarding': true,
          };
        },
      );
      addTearDown(container.dispose);

      final controller = container.read(splashControllerProvider.notifier);

      // First checkGates fails
      await controller.checkGates();
      expect(container.read(splashControllerProvider), isA<SplashUnknown>());

      // Retry succeeds
      await controller.retry();

      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashResolved>());
    });

    test('max retries erreicht → retry() ist no-op', () async {
      final container = createTestContainer(
        prefs: prefs,
        profileFetcher: () async => throw Exception('Persistent error'),
      );
      addTearDown(container.dispose);

      final controller = container.read(splashControllerProvider.notifier);

      // Initial checkGates fails
      await controller.checkGates();
      expect(container.read(splashControllerProvider), isA<SplashUnknown>());

      // Exhaust all retries
      for (int i = 0; i < SplashUnknown.maxRetries; i++) {
        await controller.retry();
      }

      // State after max retries
      final stateAfterMaxRetries = container.read(splashControllerProvider);
      expect(stateAfterMaxRetries, isA<SplashUnknown>());
      expect(
        (stateAfterMaxRetries as SplashUnknown).canRetry,
        isFalse,
        reason: 'canRetry should be false after max retries',
      );

      // Additional retry should be no-op
      await controller.retry();

      // State unchanged
      expect(
        container.read(splashControllerProvider),
        equals(stateAfterMaxRetries),
      );
    });
  });

  group('SplashController Concurrency', () {
    test('doppelter checkGates() → nur einer läuft (_inFlight Guard)',
        () async {
      int callCount = 0;

      final container = createTestContainer(
        prefs: prefs,
        profileFetcher: () async {
          callCount++;
          // Simulate slow network
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return <String, dynamic>{
            'accepted_consent_version': ConsentConfig.currentVersionInt,
            'has_completed_onboarding': true,
          };
        },
      );

      // Keep provider alive during async operations (required for autoDispose)
      final subscription = container.listen(
        splashControllerProvider,
        (prev, next) {},
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });

      final controller = container.read(splashControllerProvider.notifier);

      // Start two parallel calls
      final future1 = controller.checkGates();
      final future2 = controller.checkGates();

      await Future.wait([future1, future2]);

      // Should resolve to home (all gates passed)
      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashResolved>());
      expect(
        (state as SplashResolved).targetRoute,
        equals(RoutePaths.heute),
      );

      // The _inFlight guard prevents parallel execution of checkGates().
      // Expected call count breakdown:
      // - _fetchRemoteProfileWithRetry: up to 2 calls (initial + 1 internal retry on failure)
      // - No RaceRetryNeeded path in this test (all gates pass → remote=true, local=true)
      // - Second concurrent checkGates() call is blocked by _inFlight guard
      // Therefore, callCount should be ≤ 2.
      expect(
        callCount,
        lessThanOrEqualTo(2),
        reason: '_inFlight guard should prevent parallel execution; '
            'max 2 calls from initial + internal retry',
      );
    });

    test('checkGates() nach SplashResolved ist no-op', () async {
      int callCount = 0;

      final container = createTestContainer(
        prefs: prefs,
        profileFetcher: () async {
          callCount++;
          return <String, dynamic>{
            'accepted_consent_version': ConsentConfig.currentVersionInt,
            'has_completed_onboarding': true,
          };
        },
      );
      addTearDown(container.dispose);

      final controller = container.read(splashControllerProvider.notifier);

      // First call resolves
      await controller.checkGates();
      expect(container.read(splashControllerProvider), isA<SplashResolved>());
      final callCountAfterFirst = callCount;

      // Second call should be no-op
      await controller.checkGates();

      // State unchanged, no new fetches
      expect(container.read(splashControllerProvider), isA<SplashResolved>());
      expect(callCount, equals(callCountAfterFirst));
    });
  });

  group('SplashController Race-Retry', () {
    test('race-retry success: remote false→true → SplashResolved(heute)',
        () async {
      int fetchCount = 0;

      final container = createTestContainer(
        prefs: prefs,
        userHasCompletedOnboarding: true, // local = true
        profileFetcher: () async {
          fetchCount++;
          return <String, dynamic>{
            'accepted_consent_version': ConsentConfig.currentVersionInt,
            // First fetch (consent gate): remote false (race condition)
            // Second fetch (race-retry): remote true (server synced)
            'has_completed_onboarding': fetchCount > 1,
          };
        },
      );

      // Keep provider alive during async operations (required for autoDispose)
      final subscription = container.listen(
        splashControllerProvider,
        (prev, next) {},
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });

      final controller = container.read(splashControllerProvider.notifier);
      controller.setRaceRetryDelay(const Duration(milliseconds: 1));

      await controller.checkGates();

      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashResolved>());
      expect(
        (state as SplashResolved).targetRoute,
        equals(RoutePaths.heute),
      );

      // Verify: consent fetch + race-retry fetch = exactly 2 calls
      expect(fetchCount, equals(2));
    });

    test('race-retry failure: remote stays false → SplashResolved(onboardingIntro)',
        () async {
      final container = createTestContainer(
        prefs: prefs,
        userHasCompletedOnboarding: true, // local = true
        profileFetcher: () async => <String, dynamic>{
          'accepted_consent_version': ConsentConfig.currentVersionInt,
          'has_completed_onboarding': false, // Always false
        },
      );

      // Keep provider alive during async operations (required for autoDispose)
      final subscription = container.listen(
        splashControllerProvider,
        (prev, next) {},
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });

      final controller = container.read(splashControllerProvider.notifier);
      controller.setRaceRetryDelay(const Duration(milliseconds: 1));

      await controller.checkGates();

      final state = container.read(splashControllerProvider);
      expect(state, isA<SplashResolved>());
      expect(
        (state as SplashResolved).targetRoute,
        equals(RoutePaths.onboardingIntro),
        reason: 'After race-retry still false → fallback to onboarding',
      );
    });
  });
}
