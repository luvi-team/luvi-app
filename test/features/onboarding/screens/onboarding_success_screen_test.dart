import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_app/features/onboarding/data/onboarding_backend_writer.dart';
import 'package:luvi_app/features/onboarding/model/fitness_level.dart' as app;
import 'package:luvi_app/features/onboarding/model/goal.dart';
import 'package:luvi_app/features/onboarding/model/interest.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../support/test_config.dart';

// Test screen dimensions (must match setTestScreenSize)
const _testWidth = 430.0;
const _testHeight = 932.0;

/// Test notifier with complete OnboardingData for Backend-SSOT validation.
class _CompleteOnboardingNotifier extends OnboardingNotifier {
  @override
  OnboardingData build() => OnboardingData(
        name: 'Test User',
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: app.FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
        ],
        // Deterministic date: Fixed date (early December 2025) for stable test
        periodStart: DateTime(2025, 12, 8),
      );
}

/// Test notifier with INCOMPLETE OnboardingData (missing name).
class _IncompleteOnboardingNotifier extends OnboardingNotifier {
  @override
  OnboardingData build() => OnboardingData(
        name: null, // Missing required field
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: app.FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
        ],
        // Deterministic date: Fixed date (early December 2025) for stable test
        periodStart: DateTime(2025, 12, 8),
      );
}

/// Fake backend writer that always fails on first attempt.
class _FailingBackendWriter implements OnboardingBackendWriter {
  int _callCount = 0;
  final bool failOnce;
  int _markCompleteCallCount = 0;

  _FailingBackendWriter({this.failOnce = true});

  int get callCount => _callCount;
  int get markCompleteCallCount => _markCompleteCallCount;

  @override
  bool get isAuthenticated => true;

  @override
  Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  }) async {
    _callCount++;
    if (failOnce && _callCount == 1) {
      throw Exception('Simulated backend failure');
    }
    // Second attempt succeeds
    return {'user_id': 'test-user'};
  }

  @override
  Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  }) async {
    // Always succeed for cycle data
    return {'user_id': 'test-user'};
  }

  @override
  Future<Map<String, dynamic>?> markOnboardingComplete() async {
    _markCompleteCallCount++;
    return {'user_id': 'test-user', 'has_completed_onboarding': true};
  }
}

/// Fake backend writer that always fails.
class _AlwaysFailingBackendWriter implements OnboardingBackendWriter {
  int _callCount = 0;
  int _markCompleteCallCount = 0;

  int get callCount => _callCount;
  int get markCompleteCallCount => _markCompleteCallCount;

  @override
  bool get isAuthenticated => true;

  @override
  Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  }) async {
    _callCount++;
    throw Exception('Simulated permanent backend failure');
  }

  @override
  Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  }) async {
    throw Exception('Simulated permanent backend failure');
  }

  @override
  Future<Map<String, dynamic>?> markOnboardingComplete() async {
    _markCompleteCallCount++;
    throw Exception('Simulated permanent backend failure');
  }
}

/// Backend writer where profile succeeds but cycle_data fails.
class _ProfileOkCycleFailWriter implements OnboardingBackendWriter {
  int _profileCalls = 0;
  int _cycleCalls = 0;
  int _markCompleteCalls = 0;

  int get profileCalls => _profileCalls;
  int get cycleCalls => _cycleCalls;
  int get markCompleteCalls => _markCompleteCalls;

  @override
  bool get isAuthenticated => true;

  @override
  Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  }) async {
    _profileCalls++;
    return {'user_id': 'test-user'};
  }

  @override
  Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  }) async {
    _cycleCalls++;
    throw Exception('Simulated cycle_data failure');
  }

  @override
  Future<Map<String, dynamic>?> markOnboardingComplete() async {
    _markCompleteCalls++;
    return {'user_id': 'test-user', 'has_completed_onboarding': true};
  }
}

/// Backend writer where profile fails (cycle would succeed).
class _ProfileFailCycleOkWriter implements OnboardingBackendWriter {
  int _profileCalls = 0;
  int _cycleCalls = 0;
  int _markCompleteCalls = 0;

  int get profileCalls => _profileCalls;
  int get cycleCalls => _cycleCalls;
  int get markCompleteCalls => _markCompleteCalls;

  @override
  bool get isAuthenticated => true;

  @override
  Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  }) async {
    _profileCalls++;
    throw Exception('Simulated profile failure');
  }

  @override
  Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  }) async {
    _cycleCalls++;
    return {'user_id': 'test-user'};
  }

  @override
  Future<Map<String, dynamic>?> markOnboardingComplete() async {
    _markCompleteCalls++;
    return {'user_id': 'test-user', 'has_completed_onboarding': true};
  }
}

/// Fake backend writer that is not authenticated.
class _UnauthenticatedBackendWriter implements OnboardingBackendWriter {
  @override
  bool get isAuthenticated => false;

  @override
  Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  }) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  }) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>?> markOnboardingComplete() async {
    return null;
  }
}

/// Complete onboarding data but without cycle data (periodStart=null),
/// to keep backend writes deterministic in tests.
class _CompleteOnboardingNoCycleNotifier extends OnboardingNotifier {
  @override
  OnboardingData build() => OnboardingData(
        name: 'Test User',
        birthDate: DateTime(2000, 1, 15),
        fitnessLevel: app.FitnessLevel.beginner,
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
        ],
        periodStart: null,
      );
}

/// Backend writer that captures args and fails at markComplete to avoid navigation.
class _CapturingBackendWriter implements OnboardingBackendWriter {
  String? lastFitnessLevel;
  List<String>? lastGoals;
  List<String>? lastInterests;

  @override
  bool get isAuthenticated => true;

  @override
  Future<Map<String, dynamic>?> upsertProfile({
    required String displayName,
    required DateTime birthDate,
    required String fitnessLevel,
    required List<String> goals,
    required List<String> interests,
  }) async {
    lastFitnessLevel = fitnessLevel;
    lastGoals = List<String>.from(goals);
    lastInterests = List<String>.from(interests);
    return {'user_id': 'test-user'};
  }

  @override
  Future<Map<String, dynamic>?> upsertCycleData({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriod,
    required int age,
  }) async {
    throw Exception('Cycle data should be skipped in this test');
  }

  @override
  Future<Map<String, dynamic>?> markOnboardingComplete() async {
    throw Exception('Stop before navigation');
  }
}

void main() {
  TestConfig.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // Configure larger screen size for Figma O9 layout (280px cards container)
  void setTestScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(_testWidth * 3, _testHeight * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestApp({
    List<dynamic> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        initModeProvider.overrideWithValue(InitMode.test),
        ...overrides,
      ],
      // Use MediaQuery to set a larger surface for Figma O9 layout (280px cards)
      child: MediaQuery(
        data: const MediaQueryData(size: Size(_testWidth, _testHeight)),
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const OnboardingSuccessScreen(
            fitnessLevel: FitnessLevel.beginner,
          ),
        ),
      ),
    );
  }

  group('OnboardingSuccessScreen', () {
    testWidgets('renders initially in animating state', (tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            onboardingProvider.overrideWith(() => _CompleteOnboardingNotifier()),
            onboardingBackendWriterProvider
                .overrideWithValue(_UnauthenticatedBackendWriter()),
          ],
        ),
      );
      // Only pump once to see initial state, don't wait for animation
      await tester.pump();

      expect(find.byType(OnboardingSuccessScreen), findsOneWidget);
      // Should show loading text during animation
      expect(find.text("We're putting together your plans..."), findsOneWidget);
    });

    group('K10.1: isComplete validation', () {
      testWidgets('shows error state when onboarding data is incomplete',
          (tester) async {
        setTestScreenSize(tester);
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider
                  .overrideWith(() => _IncompleteOnboardingNotifier()),
              onboardingBackendWriterProvider
                  .overrideWithValue(_UnauthenticatedBackendWriter()),
            ],
          ),
        );

        // Pump through the animation (3 seconds) and save attempt
        await tester.pump(const Duration(seconds: 4));
        // Pump a few more frames for UI to update
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Should show error state - look for retry button
        expect(find.text('Try again'), findsOneWidget);
        // Should show error text
        expect(find.text('Save failed. Please try again.'), findsOneWidget);
      });
    });

    group('K10.2: Backend save failure', () {
      testWidgets('shows error state when backend save fails', (tester) async {
        setTestScreenSize(tester);
        final failingWriter = _AlwaysFailingBackendWriter();

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider.overrideWith(() => _CompleteOnboardingNotifier()),
              onboardingBackendWriterProvider.overrideWithValue(failingWriter),
            ],
          ),
        );

        // Pump through animation and save attempt
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Should show error state
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text('Save failed. Please try again.'), findsOneWidget);
        // Backend should have been called
        expect(failingWriter.callCount, 1);
        // Critical: must not mark onboarding complete when backend save fails.
        expect(failingWriter.markCompleteCallCount, 0);
      });

      testWidgets('does not show success when save fails', (tester) async {
        setTestScreenSize(tester);
        final failingWriter = _AlwaysFailingBackendWriter();

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider.overrideWith(() => _CompleteOnboardingNotifier()),
              onboardingBackendWriterProvider.overrideWithValue(failingWriter),
            ],
          ),
        );

        // Pump through animation and save attempt
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Should be in error state, not success
        expect(find.text('Done!'), findsNothing);
        // Critical: must not mark onboarding complete when backend save fails.
        expect(failingWriter.markCompleteCallCount, 0);
      });

      testWidgets('Profile OK, Cycle FAIL → does NOT call markOnboardingComplete',
          (tester) async {
        setTestScreenSize(tester);
        final failingWriter = _ProfileOkCycleFailWriter();

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider.overrideWith(() => _CompleteOnboardingNotifier()),
              onboardingBackendWriterProvider.overrideWithValue(failingWriter),
            ],
          ),
        );

        // Pump through animation and save attempt
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Try again'), findsOneWidget);
        expect(failingWriter.profileCalls, 1);
        expect(failingWriter.cycleCalls, 1);
        expect(failingWriter.markCompleteCalls, 0);
      });

      testWidgets('Profile FAIL, Cycle OK → does NOT call markOnboardingComplete',
          (tester) async {
        setTestScreenSize(tester);
        final failingWriter = _ProfileFailCycleOkWriter();

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider.overrideWith(() => _CompleteOnboardingNotifier()),
              onboardingBackendWriterProvider.overrideWithValue(failingWriter),
            ],
          ),
        );

        // Pump through animation and save attempt
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Try again'), findsOneWidget);
        expect(failingWriter.profileCalls, 1);
        // Cycle should not be called if profile fails first.
        expect(failingWriter.cycleCalls, 0);
        expect(failingWriter.markCompleteCalls, 0);
      });
    });

    group('K10.3: Retry functionality', () {
      testWidgets('retry button triggers new save attempt', (tester) async {
        setTestScreenSize(tester);
        final failingWriter = _FailingBackendWriter(failOnce: true);

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider.overrideWith(() => _CompleteOnboardingNotifier()),
              onboardingBackendWriterProvider.overrideWithValue(failingWriter),
              // Override userStateService to provide a working mock
              userStateServiceProvider.overrideWith((ref) async {
                SharedPreferences.setMockInitialValues({});
                final prefs = await SharedPreferences.getInstance();
                final service = UserStateService(prefs: prefs);
                await service.bindUser('test-user');
                return service;
              }),
            ],
          ),
        );

        // Wait for animation to complete and first save attempt to fail
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify error state and first call happened
        expect(find.text('Try again'), findsOneWidget);
        expect(failingWriter.callCount, 1);

        // Tap retry button
        await tester.tap(find.text('Try again'));
        // Allow setState to rebuild widget
        await tester.pump();
        // Animation restarts and runs for 3 seconds, drive animation with multiple pumps
        for (int i = 0; i < 35; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Second attempt should have been made (via animation completion)
        expect(failingWriter.callCount, 2);

        // Pump through any remaining timers to clean up
        // (the 500ms delay before navigation)
        await tester.pump(const Duration(seconds: 1));
      });

      testWidgets('retry button is not visible during animation',
          (tester) async {
        setTestScreenSize(tester);
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider.overrideWith(() => _CompleteOnboardingNotifier()),
              onboardingBackendWriterProvider
                  .overrideWithValue(_UnauthenticatedBackendWriter()),
            ],
          ),
        );

        // Initially during animation - no retry button
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Try again'), findsNothing);
      });
    });

    group('Stable IDs persistence', () {
      testWidgets('writes canonical IDs (never UI labels)', (tester) async {
        setTestScreenSize(tester);
        final writer = _CapturingBackendWriter();

        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider
                  .overrideWith(() => _CompleteOnboardingNoCycleNotifier()),
              onboardingBackendWriterProvider.overrideWithValue(writer),
            ],
          ),
        );

        // Pump through animation and backend save attempt.
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // markOnboardingComplete fails, so we end in error state.
        expect(find.text('Try again'), findsOneWidget);

        expect(writer.lastFitnessLevel, 'beginner');
        expect(writer.lastGoals, ['fitter']);
        expect(writer.lastInterests, ['strength_training', 'cardio', 'nutrition']);
      });
    });

    group('Authentication check', () {
      testWidgets('shows error state when user is not authenticated',
          (tester) async {
        setTestScreenSize(tester);
        await tester.pumpWidget(
          buildTestApp(
            overrides: [
              onboardingProvider.overrideWith(() => _CompleteOnboardingNotifier()),
              // User is NOT authenticated - should show error
              onboardingBackendWriterProvider
                  .overrideWithValue(_UnauthenticatedBackendWriter()),
            ],
          ),
        );

        // Pump through animation (3 seconds) and check for error state
        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Should show error state because user is not authenticated
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text('Save failed. Please try again.'), findsOneWidget);
      });
    });

    group('Enum safety', () {
      testWidgets('FitnessLevel.tryParse handles unknown values safely', (_) async {
        // This tests the tryParse function directly
        // Unknown values should return null (then fallback to beginner)
        expect(FitnessLevel.tryParse('unknown_value'), isNull);
        expect(FitnessLevel.tryParse('beginner'), FitnessLevel.beginner);
        expect(FitnessLevel.tryParse('occasional'), FitnessLevel.occasional);
        expect(FitnessLevel.tryParse('fit'), FitnessLevel.fit);
      });
    });
  });
}
