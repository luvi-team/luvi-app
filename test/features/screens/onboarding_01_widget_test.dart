import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding01Screen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: Onboarding01Screen.routeName,
        routes: [
          GoRoute(
            path: Onboarding01Screen.routeName,
            builder: (context, state) => const Onboarding01Screen(),
          ),
          GoRoute(
            path: '/onboarding/02',
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 02')),
          ),
        ],
      );
      addTearDown(router.dispose);
    });

    Widget createTestApp() {
      return MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.buildAppTheme(),
        locale: const Locale('de'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      );
    }

    testWidgets('collects name and navigates forward', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final screenContext = tester.element(find.byType(Onboarding01Screen));
      final l10n = AppLocalizations.of(screenContext)!;
      final stepText = l10n.onboardingStepFraction(1, kOnboardingTotalSteps);
      expect(find.text(stepText), findsOneWidget);
      expect(find.textContaining('Erzähl mir von dir'), findsOneWidget);

      final nameField = find.byType(TextField);
      expect(nameField, findsOneWidget);

      final cta = find.byKey(const Key('onb_cta'));
      expect(cta, findsOneWidget);
      expect(tester.widget<ElevatedButton>(cta).onPressed, isNull);

      // Enter text and wait for state update
      await tester.enterText(nameField, 'Claire');
      await tester.pumpAndSettle();

      expect(tester.widget<ElevatedButton>(cta).onPressed, isNotNull);

      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.text('Onboarding 02'), findsOneWidget);
    });
  });
}
