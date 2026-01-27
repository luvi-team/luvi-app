import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/router.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('tapping forgot link navigates to reset password screen', (
    tester,
  ) async {
    final router = GoRouter(
      routes: testAppRoutes,
      initialLocation: LoginScreen.routeName,
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
    await tester.pumpAndSettle();

    // Verify login screen is displayed
    expect(find.byType(LoginScreen), findsOneWidget);

    // Key matches login_screen.dart: ValueKey(TestKeys.loginForgotLink)
    await tester.tap(find.byKey(const ValueKey(TestKeys.loginForgotLink)));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey(TestKeys.authResetScreen)),
      findsOneWidget,
      reason: 'Reset password screen should be displayed after tapping forgot link',
    );
  });
}
