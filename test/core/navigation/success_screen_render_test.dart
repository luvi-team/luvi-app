import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/router.dart';

import '../../support/test_config.dart';
import '../../support/test_view.dart';

/// Tests SuccessScreen rendering (Auth Rebrand v3).
///
/// NOTE: Auto-redirect navigation cannot be verified in widget tests because
/// GoRouter doesn't actually navigate in test environments. Redirect behavior
/// should be verified in integration tests.
void main() {
  TestConfig.ensureInitialized();

  for (final locale in const [Locale('de'), Locale('en')]) {
    testWidgets(
      'Auth SuccessScreen renders correctly ($locale)',
      (tester) async {
        addTearDown(configureTestView(tester));

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
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
            ),
          ),
        );

        // Wait for initial screen to render
        await tester.pumpAndSettle();

        // Verify SuccessScreen is shown
        expect(
          find.byKey(const ValueKey(TestKeys.authSuccessScreen)),
          findsOneWidget,
        );

        // Verify locale-specific text is rendered
        final element = tester.element(
          find.byKey(const ValueKey(TestKeys.authSuccessScreen)),
        );
        final l10n = AppLocalizations.of(element);
        expect(
          l10n,
          isNotNull,
          reason: 'AppLocalizations should be available for locale $locale',
        );
        expect(find.text(l10n!.authSuccessPwdTitle), findsOneWidget);
      },
    );
  }
}
