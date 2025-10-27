import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  tearDown(FeatureFlags.resetOverrides);

  Future<void> runNavigationFlow(WidgetTester tester) async {
    // Track navigation
    String? navigatedPath;

    // Create router with both routes
    final router = GoRouter(
      initialLocation: '/auth/password/success',
      routes: [
        GoRoute(
          path: '/auth/password/success',
          builder: (context, state) => const SuccessScreen(),
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

    // Find and tap success CTA button
    final ctaButton = find.byKey(const ValueKey('success_cta_button'));
    expect(ctaButton, findsOneWidget);
    await tester.tap(ctaButton);
    await tester.pumpAndSettle();

    // Verify navigation to dashboard
    expect(navigatedPath, HeuteScreen.routeName);

    // Verify dashboard content is visible
    final heuteContext = tester.element(find.byType(HeuteScreen));
    final loc = AppLocalizations.of(heuteContext)!;
    if (TestConfig.featureDashboardV2) {
      // In V2, verify landing by robust keys visible without scrolling
      expect(find.byKey(const Key('dashboard_header')), findsOneWidget);
      expect(
        find.byKey(const Key('dashboard_hero_sync_preview')),
        findsOneWidget,
      );
    } else {
      expect(find.text(loc.dashboardCategoriesTitle), findsOneWidget);
      expect(find.text(loc.dashboardMoreTrainingsTitle), findsOneWidget);
    }
  }

  testWidgets(
    'Auth SuccessScreen navigates to Dashboard on CTA tap (Dashboard V2)',
    (tester) async {
      FeatureFlags.setDashboardV2Override(true);
      await runNavigationFlow(tester);
    },
  );

  testWidgets(
    'Auth SuccessScreen navigates to Dashboard on CTA tap (Dashboard V1)',
    (tester) async {
      FeatureFlags.setDashboardV2Override(false);
      await runNavigationFlow(tester);
    },
  );
}
