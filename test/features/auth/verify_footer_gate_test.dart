import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/routes.dart' as features;

void main() {
  testWidgets('verify confirm button enables only after 6 digits', (tester) async {
    final router = GoRouter(
      routes: features.featureRoutes,
      initialLocation: '/auth/verify',
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

    final ctaFinder = find.byKey(const ValueKey('verify_confirm_button'));
    var button = tester.widget<ElevatedButton>(ctaFinder);
    expect(button.onPressed, isNull);

    final firstField = find.byType(TextField).first;
    await tester.tap(firstField);
    await tester.pump();
    await tester.enterText(firstField, '12345');
    await tester.pump();

    button = tester.widget<ElevatedButton>(ctaFinder);
    expect(button.onPressed, isNull);

    final lastField = find.byType(TextField).last;
    await tester.tap(lastField);
    await tester.pump();
    await tester.enterText(lastField, '6');
    await tester.pump();

    button = tester.widget<ElevatedButton>(ctaFinder);
    expect(button.onPressed, isNotNull);
  });
}
