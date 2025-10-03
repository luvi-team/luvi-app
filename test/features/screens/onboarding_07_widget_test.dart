import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_06.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding07Screen', () {
    testWidgets('option tap enables CTA and navigates to done', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding07Screen.routeName,
            builder: (context, state) => const Onboarding07Screen(),
          ),
          GoRoute(
            path: '/onboarding/done',
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding abgeschlossen')),
          ),
        ],
        initialLocation: Onboarding07Screen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      final cta = find.byKey(const Key('onb_cta'));
      expect(cta, findsOneWidget);
      // initially disabled
      expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNull);

      // tap first option
      final firstOption = find.byKey(const Key('onb_option_0'));
      expect(firstOption, findsOneWidget);
      await tester.tap(firstOption);
      await tester.pumpAndSettle();

      // enabled & navigates
      expect(tester.widget<ButtonStyleButton>(cta).onPressed, isNotNull);
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();
      expect(find.text('Onboarding abgeschlossen'), findsOneWidget);
    });

    testWidgets('back button navigates to 06 when canPop is false', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding06Screen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 06')),
          ),
          GoRoute(
            path: Onboarding07Screen.routeName,
            builder: (context, state) => const Onboarding07Screen(),
          ),
        ],
        initialLocation: Onboarding07Screen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      // Verify 07 rendered
      expect(find.textContaining('Wie ist dein Zyklus so?'), findsOneWidget);
      expect(find.text('7/7'), findsOneWidget);

      // Tap back button
      final backButton = find.byType(BackButtonCircle);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should navigate to 06 (fallback when canPop=false)
      expect(find.text('Onboarding 06'), findsOneWidget);
    });
  });
}
