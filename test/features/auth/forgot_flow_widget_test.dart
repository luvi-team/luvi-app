import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/routes.dart' as features;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reset password flow', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: features.featureRoutes,
        initialLocation: '/auth/forgot',
      );
    });

    tearDown(() {
      router.dispose();
    });

    testWidgets('button enables only for valid email and navigates on submit', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final emailField = find.byKey(const ValueKey('reset_email_field'));
      final ctaButton = find.byKey(const ValueKey('reset_cta'));

      ElevatedButton buttonWidget() => tester.widget<ElevatedButton>(ctaButton);

      // Initially invalid -> disabled CTA and no spinner.
      expect(buttonWidget().onPressed, isNull);

      await tester.enterText(emailField, 'invalid');
      await tester.pump();
      expect(buttonWidget().onPressed, isNull);

      await tester.enterText(emailField, 'user@example.com');
      await tester.pump();
      expect(buttonWidget().onPressed, isNotNull);

      await tester.tap(ctaButton);
      await tester.pump(); // start loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(buttonWidget().onPressed, isNull);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('auth_success_screen')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('success_title_forgot')),
        findsOneWidget,
      );
    });
  });
}
