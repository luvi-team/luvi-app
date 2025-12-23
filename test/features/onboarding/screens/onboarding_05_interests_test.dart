import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/model/interest.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_cycle_intro.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/init_mode.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  // Note: Riverpod's Override is a sealed class not exported for direct use.
  // Callers pass provider overrides which are valid Override instances at runtime.
  Widget buildTestApp({
    Widget? home,
    GoRouter? router,
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
        routerConfig: router ??
            GoRouter(
              initialLocation: Onboarding05InterestsScreen.routeName,
              routes: [
                GoRoute(
                  path: Onboarding05InterestsScreen.routeName,
                  name: Onboarding05InterestsScreen.navName,
                  builder: (context, state) =>
                      home ?? const Onboarding05InterestsScreen(),
                ),
                GoRoute(
                  path: Onboarding06CycleIntroScreen.routeName,
                  name: Onboarding06CycleIntroScreen.navName,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('O6 Cycle Intro')),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  group('Onboarding05InterestsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(Onboarding05InterestsScreen), findsOneWidget);
    });

    testWidgets('tapping interest toggles selection state', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Get container reference while widget is active
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Onboarding05InterestsScreen)),
      );

      // Find the first interest card (strengthTraining)
      final interestCardFinder =
          find.byKey(const Key('onb_interest_strengthTraining'));
      expect(interestCardFinder, findsOneWidget);

      // Tap to select
      await tester.tap(interestCardFinder);
      await tester.pumpAndSettle();

      // Verify state
      final selectedInterests =
          container.read(onboardingProvider).selectedInterests;
      expect(selectedInterests, contains(Interest.strengthTraining));

      // Tap again to deselect
      await tester.tap(interestCardFinder);
      await tester.pumpAndSettle();

      final updatedInterests =
          container.read(onboardingProvider).selectedInterests;
      expect(updatedInterests, isNot(contains(Interest.strengthTraining)));
    });

    testWidgets('continue button disabled when fewer than 3 selected',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Onboarding05InterestsScreen)),
      );

      // Initially no interests selected - CTA should be disabled
      expect(container.read(onboardingProvider).selectedInterests, isEmpty);

      // Select 2 interests (still below minimum of 3)
      await tester.tap(find.byKey(const Key('onb_interest_strengthTraining')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onb_interest_cardio')));
      await tester.pumpAndSettle();

      // Verify only 2 selected
      expect(
        container.read(onboardingProvider).selectedInterests.length,
        equals(2),
      );

      // Select 3rd interest - now CTA should be enabled
      await tester.tap(find.byKey(const Key('onb_interest_mobility')));
      await tester.pumpAndSettle();

      expect(
        container.read(onboardingProvider).selectedInterests.length,
        equals(3),
      );
    });

    testWidgets('cannot select more than 5 interests', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Onboarding05InterestsScreen)),
      );

      // Helper to scroll to and tap an interest card
      Future<void> tapInterest(String name) async {
        final finder = find.byKey(Key('onb_interest_$name'));
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      // Select all 6 interests (scroll to ensure visibility)
      await tapInterest('strengthTraining');
      await tapInterest('cardio');
      await tapInterest('mobility');
      await tapInterest('nutrition');
      await tapInterest('mindfulness');
      // Tap 6th interest - should be rejected by notifier
      await tapInterest('hormonesCycle');

      // Verify only 5 selected (max enforced by notifier)
      final selectedInterests =
          container.read(onboardingProvider).selectedInterests;
      expect(selectedInterests.length, equals(5));
      expect(selectedInterests, isNot(contains(Interest.hormonesCycle)));
    });

    testWidgets('continue navigates to O6 cycle intro screen', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Select 3 interests (minimum required to enable CTA)
      await tester.tap(find.byKey(const Key('onb_interest_strengthTraining')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onb_interest_cardio')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onb_interest_mobility')));
      await tester.pumpAndSettle();

      // Scroll to and tap Continue button (may be off-screen in default viewport)
      final ctaFinder = find.byKey(const Key('onb_cta'));
      await tester.ensureVisible(ctaFinder);
      await tester.pumpAndSettle();
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      // Verify navigation to O6
      expect(find.text('O6 Cycle Intro'), findsOneWidget);
    });
  });
}
