import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/features/onboarding/model/fitness_level.dart' as app;
import 'package:luvi_app/features/onboarding/model/goal.dart';
import 'package:luvi_app/features/onboarding/model/interest.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_01.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_services/user_state_service.dart' as services;
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

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(Onboarding06PeriodScreen), findsOneWidget);
    });

    testWidgets(
        'unknown toggle navigates to success with services.FitnessLevel',
        (tester) async {
      // Router with success route expecting services.FitnessLevel
      // Redirect to O1 as in routes.dart:237
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding01Screen.routeName,
            builder: (context, state) => const Scaffold(
              key: Key('o1_fallback'),
              body: Text('O1 Fallback'),
            ),
          ),
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
            redirect: (ctx, st) {
              // PROD-LIKE: Checks if extra is services.FitnessLevel (like routes.dart:237)
              if (st.extra is services.FitnessLevel) return null;
              return Onboarding01Screen.routeName; // Redirect to O1 on invalid type
            },
            builder: (_, st) {
              // Fix 4: Null-safe cast with fallback
              final fitness = st.extra as services.FitnessLevel?;
              return Scaffold(
                key: const Key('success_screen'),
                body: Text('Success: ${fitness?.name ?? 'unknown'}'),
              );
            },
          ),
        ],
        initialLocation: Onboarding06PeriodScreen.routeName,
      );

      // buildLocalizedApp statt MaterialApp.router direkt (Theme/Tokens)
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

      // ASSERTION: Success-Screen wird angezeigt mit korrektem FitnessLevel
      // Bei falschem Typ (app.FitnessLevel) → Redirect zu O1 → Test schlägt fehl
      expect(find.byKey(const Key('success_screen')), findsOneWidget);
      expect(find.text('Success: fit'), findsOneWidget);
      expect(find.byKey(const Key('o1_fallback')), findsNothing);
    });
  });
}
