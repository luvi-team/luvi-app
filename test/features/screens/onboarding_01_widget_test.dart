import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding01Screen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: Onboarding01Screen.routeName,
        routes: [
          GoRoute(
            path: Onboarding01Screen.routeName,
            builder: (context, state) => const Onboarding01Screen(),
          ),
          GoRoute(
            path: '/onboarding/02',
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 02')),
          ),
        ],
      );
      addTearDown(router.dispose);
    });

    Widget createTestApp() {
      return MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.buildAppTheme(),
      );
    }

    testWidgets('collects name and navigates forward', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('Erzähl mir von dir'), findsOneWidget);

      final nameField = find.byType(TextField);
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Claire');

      final continueButton = find.widgetWithText(ElevatedButton, 'Weiter');
      expect(continueButton, findsOneWidget);

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Onboarding 02'), findsOneWidget);
    });
  });
}
