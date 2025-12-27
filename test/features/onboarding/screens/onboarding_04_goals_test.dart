import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/domain/goal.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_04_goals.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/init_mode.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  // Note: Riverpod's Override is a sealed class not exported for direct use.
  // Callers pass provider overrides (e.g., provider.overrideWith()) which are
  // valid Override instances at runtime. Using List<dynamic> is required because
  // Dart cannot express "any valid Override subtype" in the public API.
  // Runtime type safety is enforced by ProviderScope which rejects invalid entries.
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
              initialLocation: Onboarding04GoalsScreen.routeName,
              routes: [
                GoRoute(
                  path: Onboarding04GoalsScreen.routeName,
                  name: Onboarding04GoalsScreen.navName,
                  builder: (context, state) =>
                      home ?? const Onboarding04GoalsScreen(),
                ),
                GoRoute(
                  path: Onboarding05InterestsScreen.routeName,
                  name: Onboarding05InterestsScreen.navName,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('O5 Interests')),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  group('Onboarding04GoalsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(Onboarding04GoalsScreen), findsOneWidget);
    });

    testWidgets('tapping goal toggles selection state', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Get container reference while widget is active
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Onboarding04GoalsScreen)),
      );

      // Find the first goal card (fitter)
      final goalCardFinder = find.byKey(const Key('onb_goal_fitter'));
      expect(goalCardFinder, findsOneWidget);

      // Tap to select
      await tester.tap(goalCardFinder);
      await tester.pumpAndSettle();

      // Verify state
      final selectedGoals = container.read(onboardingProvider).selectedGoals;
      expect(selectedGoals, contains(Goal.fitter));

      // Tap again to deselect
      await tester.tap(goalCardFinder);
      await tester.pumpAndSettle();

      final updatedGoals = container.read(onboardingProvider).selectedGoals;
      expect(updatedGoals, isNot(contains(Goal.fitter)));
    });

    testWidgets('continue button enabled when goal selected', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Get container reference while widget is active
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Onboarding04GoalsScreen)),
      );

      // Find CTA button
      final ctaFinder = find.byKey(const Key('onb_cta'));
      expect(ctaFinder, findsOneWidget);

      // Initially no goals selected - CTA should be disabled
      expect(container.read(onboardingProvider).selectedGoals, isEmpty);

      // Verify button is actually disabled (OnboardingButton uses isEnabled)
      final buttonBefore = tester.widget<OnboardingButton>(ctaFinder);
      expect(buttonBefore.isEnabled, isFalse,
          reason: 'CTA should be disabled when no goal selected');

      // Select a goal
      await tester.tap(find.byKey(const Key('onb_goal_energy')));
      await tester.pumpAndSettle();

      // Verify goal is selected
      expect(
        container.read(onboardingProvider).selectedGoals,
        contains(Goal.energy),
      );

      // Verify button is now enabled
      final buttonAfter = tester.widget<OnboardingButton>(ctaFinder);
      expect(buttonAfter.isEnabled, isTrue,
          reason: 'CTA should be enabled after goal selection');
    });

    testWidgets('continue navigates to O5 interests screen', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Select a goal first (required to enable CTA)
      await tester.tap(find.byKey(const Key('onb_goal_fitter')));
      await tester.pumpAndSettle();

      // Scroll to and tap Continue button (may be off-screen in default viewport)
      final ctaFinder = find.byKey(const Key('onb_cta'));
      await tester.ensureVisible(ctaFinder);
      await tester.pumpAndSettle();
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      // Verify navigation to O5
      expect(find.text('O5 Interests'), findsOneWidget);
    });

    testWidgets(
      '_handleContinue does not navigate when no goals selected (defensive guard)',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Get container reference
        final container = ProviderScope.containerOf(
          tester.element(find.byType(Onboarding04GoalsScreen)),
        );

        // Verify no goals selected
        expect(container.read(onboardingProvider).selectedGoals, isEmpty);

        // Find CTA (even if disabled, test the defensive guard)
        final ctaFinder = find.byKey(const Key('onb_cta'));
        await tester.ensureVisible(ctaFinder);
        await tester.pumpAndSettle();

        // Verify button is disabled
        final button = tester.widget<OnboardingButton>(ctaFinder);
        expect(button.isEnabled, isFalse);

        // Try to tap - should not navigate due to defensive guard
        await tester.tap(ctaFinder, warnIfMissed: false);
        await tester.pumpAndSettle();

        // Verify still on O4 (did not navigate)
        expect(find.byType(Onboarding04GoalsScreen), findsOneWidget);
        expect(find.text('O5 Interests'), findsNothing);
      },
    );

    testWidgets(
      'subtitle uses ExcludeSemantics to prevent duplicate announcement',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Get l10n from context (pattern from codebase)
        final screenContext =
            tester.element(find.byType(Onboarding04GoalsScreen));
        final l10n = AppLocalizations.of(screenContext);
        expect(l10n, isNotNull, reason: 'AppLocalizations must be available');

        // Find Semantics widget with subtitle label
        final subtitleSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == l10n!.onboarding04GoalsSubtitle,
        );

        expect(subtitleSemantics, findsOneWidget,
            reason: 'Subtitle should have Semantics wrapper with label');

        // Find ExcludeSemantics widget that wraps the subtitle Text
        final excludeSemanticsInSubtitle = find.descendant(
          of: subtitleSemantics,
          matching: find.byType(ExcludeSemantics),
        );

        expect(excludeSemanticsInSubtitle, findsOneWidget,
            reason:
                'Subtitle should wrap Text in ExcludeSemantics to prevent duplicate announcement');
      },
    );
  });
}
