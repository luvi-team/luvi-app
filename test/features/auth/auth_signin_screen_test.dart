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

Widget _buildRouterHarness() {
  final router = GoRouter(
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
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('de'),
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
    await tester.pumpWidget(_buildRouterHarness());
    await tester.pumpAndSettle();

    // Glass card should be present
    expect(find.byType(AuthGlassCard), findsOneWidget);
    expect(find.byKey(const ValueKey('auth_glass_card')), findsOneWidget);
  });

  testWidgets('AuthSignInScreen shows email login button', (tester) async {
    await tester.pumpWidget(_buildRouterHarness());
    await tester.pumpAndSettle();

    // Email button should always be visible
    expect(find.byType(AuthOutlineButton), findsOneWidget);
    expect(find.byKey(const ValueKey('signin_email_button')), findsOneWidget);
  });

  testWidgets('Email button navigates to /auth/login', (tester) async {
    await tester.pumpWidget(_buildRouterHarness());
    await tester.pumpAndSettle();

    final emailButton = find.byKey(const ValueKey('signin_email_button'));
    expect(emailButton, findsOneWidget);

    await tester.tap(emailButton);
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
