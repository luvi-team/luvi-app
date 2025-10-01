import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selects a goal and navigates', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Onboarding03Screen.routeName,
          builder: (context, state) => const Onboarding03Screen(),
        ),
        GoRoute(
          path: '/onboarding/04',
          builder: (context, state) => const Scaffold(
            body: Text('Onboarding 04 (Stub)'),
          ),
        ),
      ],
      initialLocation: Onboarding03Screen.routeName,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    // tippe erstes Item
    await tester.tap(find.textContaining('Zyklus & Körper').first);
    await tester.pumpAndSettle();

    // CTA aktiv?
    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.onPressed, isNotNull);

    final continueButton = find.widgetWithText(ElevatedButton, 'Weiter');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Onboarding 04 (Stub)'), findsOneWidget);
  });
}
