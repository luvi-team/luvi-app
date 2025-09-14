import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_01_screen.dart';

void main() {
  testWidgets('Consent01 → Consent02', (tester) async {
    final router = GoRouter(
      initialLocation: '/consent/01',
      routes: [
        GoRoute(
          path: '/consent/01',
          builder: (context, state) => const Consent01Screen(),
        ),
        GoRoute(
          path: '/consent/02',
          builder: (context, state) => const Scaffold(body: Text('Consent 02')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
      ),
    );

    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Weiter'));
    await tester.pumpAndSettle();

    expect(find.text('Consent 02'), findsOneWidget);
  });
}

