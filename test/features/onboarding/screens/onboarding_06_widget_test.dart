import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding06Screen', () {
    testWidgets('option tap enables CTA and navigates forward', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding06Screen.routeName,
            builder: (context, state) => const Onboarding06Screen(),
          ),
          GoRoute(
            path: Onboarding07Screen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 07 (Stub)')),
          ),
        ],
        initialLocation: Onboarding06Screen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
        ),
      );
      await tester.pumpAndSettle();

      // CTA initially disabled
      final cta = find.byKey(const Key('onb_cta'));
      expect(cta, findsOneWidget);
      expect(tester.widget<ElevatedButton>(cta).onPressed, isNull);

      // Tap first option
      final firstOption = find.byKey(const Key('onb_option_0'));
      expect(firstOption, findsOneWidget);
      await tester.tap(firstOption);
      await tester.pumpAndSettle();

      // CTA enabled & navigates
      expect(tester.widget<ElevatedButton>(cta).onPressed, isNotNull);
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();
      expect(find.text('Onboarding 07 (Stub)'), findsOneWidget);
    });

    testWidgets('back button navigates to 05 when canPop is false', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding05Screen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 05')),
          ),
          GoRoute(
            path: Onboarding06Screen.routeName,
            builder: (context, state) => const Onboarding06Screen(),
          ),
        ],
        initialLocation: Onboarding06Screen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 06 rendered
      expect(find.textContaining('Wie lange dauert dein'), findsOneWidget);
      final screenContext = tester.element(find.byType(Onboarding06Screen));
      final l10n = AppLocalizations.of(screenContext)!;
      expect(
        find.text(l10n.onboardingStepFraction(6, kOnboardingTotalSteps)),
        findsOneWidget,
      );

      // Tap back button
      final backButton = find.byType(BackButtonCircle);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should navigate to 05 (fallback when canPop=false)
      expect(find.text('Onboarding 05'), findsOneWidget);
    });
  });
}
