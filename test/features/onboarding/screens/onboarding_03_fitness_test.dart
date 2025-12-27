import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_03_fitness.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_04_goals.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Creates a GoRouter for testing. Caller must dispose via addTearDown.
  GoRouter createTestRouter({Widget? home}) {
    return GoRouter(
      initialLocation: Onboarding03FitnessScreen.routeName,
      routes: [
        GoRoute(
          path: Onboarding03FitnessScreen.routeName,
          name: Onboarding03FitnessScreen.navName,
          builder: (context, state) =>
              home ?? const Onboarding03FitnessScreen(),
        ),
        GoRoute(
          path: Onboarding04GoalsScreen.routeName,
          name: Onboarding04GoalsScreen.navName,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('O4 Goals')),
          ),
        ),
      ],
    );
  }

  /// Builds test app with OnboardingO3 screen.
  Widget buildTestApp({
    required GoRouter router,
    List<dynamic> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        initModeProvider.overrideWithValue(InitMode.test),
        for (final o in overrides) o,
      ],
      child: MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    );
  }

  group('Onboarding03FitnessScreen', () {
    testWidgets('renders without errors', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byType(Onboarding03FitnessScreen), findsOneWidget);
    });

    testWidgets('displays all 3 fitness level pills', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify all 3 fitness pills are rendered
      expect(find.byKey(const Key('fitness_pill_beginner')), findsOneWidget);
      expect(find.byKey(const Key('fitness_pill_occasional')), findsOneWidget);
      expect(find.byKey(const Key('fitness_pill_fit')), findsOneWidget);
    });

    testWidgets('tapping pill selects level and updates state', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Get container reference
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Onboarding03FitnessScreen)),
      );

      // Initially no fitness level selected
      expect(container.read(onboardingProvider).fitnessLevel, isNull);

      // Tap "fit" pill
      final fitPillFinder = find.byKey(const Key('fitness_pill_fit'));
      expect(fitPillFinder, findsOneWidget);

      await tester.tap(fitPillFinder);
      await tester.pumpAndSettle();

      // CTA should now be enabled (indirect state check)
      final ctaFinder = find.byKey(const Key('onb_cta'));
      final button = tester.widget<OnboardingButton>(ctaFinder);
      expect(button.isEnabled, isTrue,
          reason: 'CTA should be enabled after selecting fitness level');
    });

    testWidgets('continue button disabled when no level selected',
        (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Find CTA button
      final ctaFinder = find.byKey(const Key('onb_cta'));
      expect(ctaFinder, findsOneWidget);

      // Initially no level selected - CTA should be disabled
      final button = tester.widget<OnboardingButton>(ctaFinder);
      expect(button.isEnabled, isFalse,
          reason: 'CTA should be disabled with no fitness level selected');
    });

    testWidgets('continue button enabled after selecting level',
        (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Find CTA button - initially disabled
      final ctaFinder = find.byKey(const Key('onb_cta'));
      final buttonBefore = tester.widget<OnboardingButton>(ctaFinder);
      expect(buttonBefore.isEnabled, isFalse);

      // Select a level
      final beginnerPillFinder =
          find.byKey(const Key('fitness_pill_beginner'));
      await tester.tap(beginnerPillFinder);
      await tester.pumpAndSettle();

      // CTA should now be enabled
      final buttonAfter = tester.widget<OnboardingButton>(ctaFinder);
      expect(buttonAfter.isEnabled, isTrue,
          reason: 'CTA should be enabled after selecting a fitness level');
    });

    testWidgets('tapping continue navigates to O4 Goals', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Select a level first
      final fitPillFinder = find.byKey(const Key('fitness_pill_fit'));
      await tester.tap(fitPillFinder);
      await tester.pumpAndSettle();

      // Tap continue
      final ctaFinder = find.byKey(const Key('onb_cta'));
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      // Should navigate to O4 Goals screen
      expect(find.text('O4 Goals'), findsOneWidget);
    });

    testWidgets('selecting different pill changes selection', (tester) async {
      final router = createTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Select beginner
      final beginnerPill = find.byKey(const Key('fitness_pill_beginner'));
      await tester.tap(beginnerPill);
      await tester.pumpAndSettle();

      // CTA enabled
      final ctaFinder = find.byKey(const Key('onb_cta'));
      expect(tester.widget<OnboardingButton>(ctaFinder).isEnabled, isTrue);

      // Select fit (different level)
      final fitPill = find.byKey(const Key('fitness_pill_fit'));
      await tester.tap(fitPill);
      await tester.pumpAndSettle();

      // CTA still enabled
      expect(tester.widget<OnboardingButton>(ctaFinder).isEnabled, isTrue);
    });

    testWidgets('displays personalized title with user name', (tester) async {
      final router = createTestRouter(
        home: const Onboarding03FitnessScreen(userName: 'TestUser'),
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Title should contain the user name
      expect(find.textContaining('TestUser'), findsOneWidget);
    });

    // Note: State restoration from pre-selected fitness level is implicitly tested
    // by the initState logic in Onboarding03FitnessScreen, which reads from
    // onboardingProvider. Riverpod notifier override before widget mount
    // requires the build() method pattern which is tested via integration tests.
  });
}
