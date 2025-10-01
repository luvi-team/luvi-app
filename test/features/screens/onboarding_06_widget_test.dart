import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_06.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('option tap enables CTA and navigates', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: Onboarding06Screen.routeName, builder: (context, state) => const Onboarding06Screen()),
        GoRoute(path: '/onboarding/07', builder: (context, state) => const Scaffold(body: Text('Onboarding 07 (Stub)'))),
      ],
      initialLocation: Onboarding06Screen.routeName,
    );

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.buildAppTheme(), routerConfig: router));
    await tester.pumpAndSettle();

    // CTA initially disabled
    final cta = find.widgetWithText(ElevatedButton, 'Weiter');
    expect(cta, findsOneWidget);
    expect(tester.widget<ElevatedButton>(cta).onPressed, isNull);

    // Tap first option (text aus Figma – ggf. anpassen)
    final firstOption = find.textContaining('Kurz'); // z.B. 'Kurz (alle 21-23 Tage)'
    expect(firstOption, findsOneWidget);
    await tester.tap(firstOption);
    await tester.pumpAndSettle();

    // CTA enabled & navigates
    expect(tester.widget<ElevatedButton>(cta).onPressed, isNotNull);
    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(find.text('Onboarding 07 (Stub)'), findsOneWidget);
  });
}
