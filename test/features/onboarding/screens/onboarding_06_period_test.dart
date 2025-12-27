import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/features/onboarding/domain/fitness_level.dart' as app;
import 'package:luvi_app/features/onboarding/domain/goal.dart';
import 'package:luvi_app/features/onboarding/domain/interest.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/init_mode.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

/// Test notifier with fitnessLevel set (simulates user completed O3)
class _OnboardingNotifierWithFitness extends OnboardingNotifier {
  @override
  OnboardingData build() => OnboardingData(
        name: 'Test',
        birthDate: DateTime(1990, 1, 1),
        fitnessLevel: app.FitnessLevel.fit, // User selected "Sehr fit"
        selectedGoals: const [Goal.fitter],
        selectedInterests: const [
          Interest.strengthTraining,
          Interest.cardio,
          Interest.nutrition,
        ],
      );
}

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding06PeriodScreen', () {
    testWidgets('renders without errors', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding05InterestsScreen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 05')),
          ),
          GoRoute(
            path: Onboarding06PeriodScreen.routeName,
            builder: (context, state) => const Onboarding06PeriodScreen(),
          ),
          GoRoute(
            path: Onboarding07DurationScreen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 07')),
          ),
        ],
        initialLocation: Onboarding06PeriodScreen.routeName,
      );
      addTearDown(router.dispose);

      // Use ProviderScope with deterministic onboarding state
      // (consistent with second test pattern, lines 112-125)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initModeProvider.overrideWithValue(InitMode.test),
            onboardingProvider
                .overrideWith(() => _OnboardingNotifierWithFitness()),
          ],
          child: buildLocalizedApp(router: router),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(Onboarding06PeriodScreen), findsOneWidget);
    });

    testWidgets(
        'tapping unknown toggle and CTA button navigates to success screen',
        (tester) async {
      // Router with success route - fitnessLevel is read from Riverpod state
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding05InterestsScreen.routeName,
            builder: (context, state) => const Scaffold(body: Text('O5')),
          ),
          GoRoute(
            path: Onboarding06PeriodScreen.routeName,
            builder: (context, state) => const Onboarding06PeriodScreen(),
          ),
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            name: 'onboarding_success',
            // No redirect needed - OnboardingSuccessScreen reads fitnessLevel
            // from onboardingProvider state, not from route extra
            builder: (_, st) => const Scaffold(
              key: Key('success_screen'),
              body: Text('Success Screen'),
            ),
          ),
        ],
        initialLocation: Onboarding06PeriodScreen.routeName,
      );
      addTearDown(router.dispose);

      // Use buildLocalizedApp instead of MaterialApp.router directly (Theme/Tokens)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initModeProvider.overrideWithValue(InitMode.test),
            onboardingProvider
                .overrideWith(() => _OnboardingNotifierWithFitness()),
          ],
          child: buildLocalizedApp(
            router: router,
            locale: const Locale('de'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // L10n instead of hardcoded string
      final l10n = AppLocalizations.of(
        tester.element(find.byType(Onboarding06PeriodScreen)),
      )!;
      await tester.tap(find.text(l10n.onboarding06PeriodUnknown));
      await tester.pumpAndSettle();

      // Tap CTA button to trigger navigation (toggle only shows button, doesn't navigate)
      await tester.tap(find.byKey(const Key('o6_cta')));
      await tester.pumpAndSettle();

      // ASSERTION: Success screen is shown after unknown toggle
      // FitnessLevel comes from Riverpod state (_OnboardingNotifierWithFitness)
      expect(find.byKey(const Key('success_screen')), findsOneWidget);
    });
  });
}
