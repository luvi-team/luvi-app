import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/router.dart';

import '../../support/test_config.dart';

/// Tests SuccessScreen rendering (Auth Rebrand v3).
///
/// NOTE: Auto-redirect navigation cannot be verified in widget tests because
/// GoRouter doesn't actually navigate in test environments. Redirect behavior
/// should be verified in integration tests.
void main() {
  TestConfig.ensureInitialized();

  testWidgets(
    'Auth SuccessScreen renders correctly',
    (tester) async {
      // Use testAppRoutes for proper route configuration
      final router = GoRouter(
        routes: testAppRoutes,
        initialLocation: SuccessScreen.passwordSavedRoutePath,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );

      // Wait for initial screen to render
      await tester.pumpAndSettle();

      // Verify SuccessScreen is shown
      expect(find.byKey(const ValueKey('auth_success_screen')), findsOneWidget);
    },
  );
}
