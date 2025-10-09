import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Auth SuccessScreen navigates to Dashboard on CTA tap', (
    WidgetTester tester,
  ) async {
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
    expect(find.text('Kategorien'), findsOneWidget);
    expect(find.text('Weitere Trainings'), findsOneWidget);
  });
}
