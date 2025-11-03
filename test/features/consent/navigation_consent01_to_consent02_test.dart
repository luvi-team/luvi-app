import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_01_screen.dart';
import 'package:luvi_app/features/consent/routes.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('Consent01 → push Consent02 and pop back', (tester) async {
    final router = GoRouter(
      initialLocation: ConsentRoutes.consent01,
      routes: [
        GoRoute(
          path: ConsentRoutes.consent01,
          builder: (context, state) => const Consent01Screen(),
        ),
        GoRoute(
          path: ConsentRoutes.consent02,
          builder: (context, state) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Consent 02'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Zurück'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.buildAppTheme(), routerConfig: router),
    );

    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Weiter'));
    await tester.pumpAndSettle();

    expect(find.text('Consent 02'), findsOneWidget);
    // pop back
    await tester.tap(find.widgetWithText(TextButton, 'Zurück'));
    await tester.pumpAndSettle();
    // back on Consent01
    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
  });
}
