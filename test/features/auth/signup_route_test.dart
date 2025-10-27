import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/routes.dart' as features;

void main() {
    test('featureRoutes contains signup route path', () {
    final route = features.featureRoutes.firstWhere(
      (route) => route.path == AuthSignupScreen.routeName,
    );
    expect(route.name, 'signup');
  });

  testWidgets('navigating to /auth/signup renders AuthSignupScreen', (
    tester,
  ) async {
    final router = GoRouter(
      routes: features.featureRoutes,
      initialLocation: AuthSignupScreen.routeName,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.buildAppTheme(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth_signup_screen')), findsOneWidget);
  });
}
