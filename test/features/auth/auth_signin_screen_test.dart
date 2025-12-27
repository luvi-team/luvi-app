import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/widgets/auth_glass_card.dart';
import 'package:luvi_app/features/auth/widgets/auth_outline_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: AuthSignInScreen.routeName,
    routes: [
      GoRoute(
        path: AuthSignInScreen.routeName,
        builder: (context, state) => const AuthSignInScreen(),
      ),
      GoRoute(
        path: LoginScreen.routeName,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LOGIN'))),
      ),
    ],
  );
}

Widget _buildRouterHarness(GoRouter router, {Locale locale = const Locale('de')}) {
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    ),
  );
}

void main() {
  TestConfig.ensureInitialized();

  testWidgets('AuthSignInScreen shows glass card with headline', (
    tester,
  ) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router));
    await tester.pumpAndSettle();

    // Glass card should be present
    expect(find.byType(AuthGlassCard), findsOneWidget);
    expect(find.byKey(const ValueKey('auth_glass_card')), findsOneWidget);

    final l10nOrNull = AppLocalizations.of(tester.element(find.byType(AuthSignInScreen)));
    expect(l10nOrNull, isNotNull, reason: 'AppLocalizations should be available in context');
    final l10n = l10nOrNull!;
    expect(find.text(l10n.authSignInHeadline), findsOneWidget);
  });

  testWidgets('AuthSignInScreen shows email login button', (tester) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router));
    await tester.pumpAndSettle();

    // Email button should always be visible (AuthOutlineButton is used for all social buttons now)
    expect(find.byType(AuthOutlineButton), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('signin_email_button')), findsOneWidget);
  });

  testWidgets('Email button navigates to /auth/login', (tester) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router));
    await tester.pumpAndSettle();

    final emailButton = find.byKey(const ValueKey('signin_email_button'));
    expect(emailButton, findsOneWidget);

    await tester.tap(emailButton);
    await tester.pumpAndSettle();
    // Navigation verified via UI - 'LOGIN' text only appears on LoginScreen route
    // Note: Router uses push(), so UI verification is more reliable than state checks
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('AuthSignInScreen shows headline in English', (tester) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router, locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.byType(AuthGlassCard), findsOneWidget);

    final l10n = AppLocalizations.of(tester.element(find.byType(AuthSignInScreen)))!;
    expect(l10n.localeName, 'en');
    expect(find.text(l10n.authSignInHeadline), findsOneWidget);
  });
}
