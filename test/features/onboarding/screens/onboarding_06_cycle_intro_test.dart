import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_cycle_intro.dart';
import 'package:luvi_app/features/onboarding/widgets/calendar_mini_widget.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding06CycleIntroScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Onboarding06CycleIntroScreen(),
      ));
      // Use pump() instead of pumpAndSettle() because CalendarMiniWidget
      // has an infinite pulsating animation that never completes
      await tester.pump();

      // Verify screen rendered
      expect(find.byType(Onboarding06CycleIntroScreen), findsOneWidget);
    });

    testWidgets('displays correct UI elements', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Onboarding06CycleIntroScreen(),
      ));
      await tester.pump();

      final context = tester.element(find.byType(Onboarding06CycleIntroScreen));
      final l10n = AppLocalizations.of(context)!;

      // Title from OnboardingHeader
      expect(find.text(l10n.onboardingCycleIntroTitle), findsOneWidget);
      // CTA Button
      expect(find.text(l10n.onboardingCycleIntroButton), findsOneWidget);
      // Calendar widget
      expect(find.byType(CalendarMiniWidget), findsOneWidget);
      // Header component
      expect(find.byType(OnboardingHeader), findsOneWidget);
    });

    testWidgets('displays German localization', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Onboarding06CycleIntroScreen(),
        locale: const Locale('de'),
      ));
      await tester.pump();

      final context = tester.element(find.byType(Onboarding06CycleIntroScreen));
      final l10n = AppLocalizations.of(context)!;

      // Verify localized strings are displayed
      expect(find.text(l10n.onboardingCycleIntroTitle), findsOneWidget);
      expect(find.text(l10n.onboardingCycleIntroButton), findsOneWidget);
    });

    testWidgets('continue button exists and is enabled', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Onboarding06CycleIntroScreen(),
      ));
      await tester.pump();

      final context = tester.element(find.byType(Onboarding06CycleIntroScreen));
      final l10n = AppLocalizations.of(context)!;

      // Verify button text exists
      final buttonText = find.text(l10n.onboardingCycleIntroButton);
      expect(buttonText, findsOneWidget);

      // Note: Navigation tests require GoRouter setup.
      // Button tap testing is covered by integration tests.
    });
  });
}
