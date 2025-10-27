import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/routes.dart' as features;
// ignore: unused_import
import '../../support/test_config.dart';

void main() {
    testWidgets(
    'navigating to /auth/password/new renders CreateNewPasswordScreen',
    (tester) async {
      final router = GoRouter(
        routes: features.featureRoutes,
        initialLocation: '/auth/password/new',
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

      expect(
        find.byKey(const ValueKey('auth_create_new_screen')),
        findsOneWidget,
      );
    },
  );
}
