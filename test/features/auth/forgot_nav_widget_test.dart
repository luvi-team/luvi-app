import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('tapping forgot link navigates to reset password screen', (
    tester,
  ) async {
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

    await tester.tap(find.byKey(const ValueKey('login_forgot_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('auth_forgot_screen')), findsOneWidget);
  });
}
