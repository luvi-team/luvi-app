import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

Future<void> _pumpSignupWidget(
  WidgetTester tester,
  GoRouter router, {
  Locale locale = const Locale('de'),
}) async {
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
  await tester.pumpAndSettle();
}

void main() {
  TestConfig.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AuthSignupScreen renders expected UI elements', (tester) async {
    final router = GoRouter(
      routes: features.featureRoutes,
      initialLocation: AuthSignupScreen.routeName,
    );
    addTearDown(router.dispose);

    await _pumpSignupWidget(tester, router);

    // Screen renders
    expect(find.byKey(const ValueKey('auth_signup_screen')), findsOneWidget);

    // Per Auth v2 refactoring: Signup has only 2 fields (Email + Password)
    // The old test expected 5 fields (FirstName, LastName, Phone, Email, Password)
    expect(find.byKey(const ValueKey('signup_email_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('signup_password_field')), findsOneWidget);

    // CTA button is present and enabled
    final ctaFinder = find.byKey(const ValueKey('signup_cta_button'));
    expect(ctaFinder, findsOneWidget);

    // Verify button is enabled (onPressed is not null)
    final elevatedButton = find.descendant(
      of: ctaFinder,
      matching: find.byType(ElevatedButton),
    );
    expect(elevatedButton, findsOneWidget);
    final button = tester.widget<ElevatedButton>(elevatedButton);
    expect(button.onPressed, isNotNull, reason: 'CTA button should be enabled');

    // Login link is present
    expect(find.byKey(const ValueKey('signup_login_link')), findsOneWidget);
  });

  testWidgets('AuthSignupScreen renders correctly in English', (tester) async {
    final router = GoRouter(
      routes: features.featureRoutes,
      initialLocation: AuthSignupScreen.routeName,
    );
    addTearDown(router.dispose);

    await _pumpSignupWidget(tester, router, locale: const Locale('en'));

    expect(find.byKey(const ValueKey('auth_signup_screen')), findsOneWidget);

    // Verify English L10n is active
    final context = tester.element(find.byType(AuthSignupScreen));
    final l10n = AppLocalizations.of(context)!;
    expect(l10n.localeName, 'en');
  });
}
