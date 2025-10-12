import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Onboarding07 navigates to Dashboard on CTA tap', (
    WidgetTester tester,
  ) async {
    // Track navigation
    String? navigatedPath;

    // Create router with both routes
    final router = GoRouter(
      initialLocation: Onboarding07Screen.routeName,
      routes: [
        GoRoute(
          path: Onboarding07Screen.routeName,
          builder: (context, state) => const Onboarding07Screen(),
        ),
        GoRoute(
          path: HeuteScreen.routeName,
          builder: (context, state) {
            navigatedPath = HeuteScreen.routeName;
            return const HeuteScreen();
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.buildAppTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('de')],
        locale: const Locale('de'),
      ),
    );

    // Wait for initial screen to render
    await tester.pumpAndSettle();

    // Find and tap first option to enable CTA
    final firstOption = find.byKey(const Key('onb_option_0'));
    expect(firstOption, findsOneWidget);
    await tester.tap(firstOption);
    await tester.pumpAndSettle();

    // Scroll to CTA button and tap
    final ctaButton = find.byKey(const Key('onb_cta'));
    expect(ctaButton, findsOneWidget);
    await tester.ensureVisible(ctaButton);
    await tester.pumpAndSettle();
    await tester.tap(ctaButton);
    await tester.pumpAndSettle();

    // Verify navigation to dashboard
    expect(navigatedPath, HeuteScreen.routeName);

    // Verify dashboard content is visible
    final heuteContext = tester.element(find.byType(HeuteScreen));
    final loc = AppLocalizations.of(heuteContext)!;
    expect(find.text(loc.dashboardCategoriesTitle), findsOneWidget);
    expect(find.text(loc.dashboardMoreTrainingsTitle), findsOneWidget);
  });
}
