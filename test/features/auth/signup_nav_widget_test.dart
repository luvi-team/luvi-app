import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/routes.dart' as features;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tapping signup link navigates to signup screen', (tester) async {
    final router = GoRouter(
      routes: features.featureRoutes,
      initialLocation: LoginScreen.routeName,
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

    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('login_signup_link')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth_signup_screen')), findsOneWidget);
  });
}
