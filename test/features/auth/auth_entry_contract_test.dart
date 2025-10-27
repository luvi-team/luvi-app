import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
// ignore: unused_import
import '../../support/test_config.dart';

Widget _buildRouterHarness() {
  final router = GoRouter(
    initialLocation: AuthEntryScreen.routeName,
    routes: [
      GoRoute(
        path: AuthEntryScreen.routeName,
        builder: (context, state) => const AuthEntryScreen(),
      ),
      GoRoute(
        path: LoginScreen.routeName,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LOGIN'))),
      ),
      GoRoute(
        path: AuthSignupScreen.routeName,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('SIGNUP'))),
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
    testWidgets(
    'Primary minHeight == 50 and Secondary is text-only (padding zero)',
    (tester) async {
      await tester.pumpWidget(_buildRouterHarness());

      final primary = find.byKey(const ValueKey('auth_entry_register_cta'));
      expect(primary, findsOneWidget);
      final primarySize = tester.getSize(primary);
      expect(primarySize.height, 50);

      final secondary = find.byKey(const ValueKey('auth_entry_login_cta'));
      final textButton = tester.widget<TextButton>(secondary);
      final paddingGeometry = textButton.style?.padding?.resolve(
        const <WidgetState>{},
      );
      final resolvedPadding = paddingGeometry?.resolve(
        Directionality.of(tester.element(secondary)),
      );
      expect(resolvedPadding, EdgeInsets.zero);
    },
  );

  testWidgets('Navigation smoke: taps push to /auth/signup and /auth/login', (
    tester,
  ) async {
    await tester.pumpWidget(_buildRouterHarness());

    await tester.tap(find.byKey(const ValueKey('auth_entry_register_cta')));
    await tester.pumpAndSettle();
    expect(find.text('SIGNUP'), findsOneWidget);

    await tester.pumpWidget(_buildRouterHarness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('auth_entry_login_cta')));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
