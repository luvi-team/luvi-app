import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../support/test_config.dart';

/// Per Auth v2 refactoring: SuccessScreen now navigates to AuthSignInScreen
/// instead of Dashboard. This test verifies the new flow.
void main() {
  TestConfig.ensureInitialized();

  testWidgets(
    'Auth SuccessScreen navigates to SignIn on CTA tap',
    (tester) async {
      // Create router with auth routes
      final router = GoRouter(
        initialLocation: SuccessScreen.passwordSavedRoutePath,
        routes: [
          GoRoute(
            path: SuccessScreen.passwordSavedRoutePath,
            name: SuccessScreen.passwordSavedRouteName,
            builder: (context, state) => const SuccessScreen(),
          ),
          GoRoute(
            path: AuthSignInScreen.routeName,
            name: RouteNames.authSignIn,
            builder: (context, state) => const AuthSignInScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

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

      // Verify SuccessScreen is shown
      expect(find.byKey(const ValueKey('auth_success_screen')), findsOneWidget);

      // Find and tap success CTA button
      final ctaButton = find.byKey(const ValueKey('success_cta_button'));
      expect(ctaButton, findsOneWidget);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // Verify navigation to AuthSignInScreen
      expect(
          find.byKey(const ValueKey('auth_signin_screen')), findsOneWidget);
    },
  );
}
