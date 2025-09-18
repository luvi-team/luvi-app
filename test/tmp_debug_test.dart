import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/routes.dart' as features;

void main() {
  testWidgets('count login forgot button default skip', (tester) async {
    final router = GoRouter(
      routes: features.featureRoutes,
      initialLocation: '/auth/login',
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

    final defaultCount =
        find.byKey(const ValueKey('login_forgot_button')).evaluate().length;
    debugPrint('Default skipOffstage count: $defaultCount');
  });
}
