import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

void main() {
  testWidgets('LoginScreen shows headline and button', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.buildAppTheme(),
        home: const LoginScreen(),
      ),
    ));

    expect(find.text('Willkommen zurück 💜'), findsOneWidget);
    expect(find.text('Anmelden'), findsOneWidget);
  });

  testWidgets('Button enabled only when fields filled', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.buildAppTheme(),
        home: const LoginScreen(),
      ),
    ));

    final email = find.byType(TextField).first;
    final password = find.byType(TextField).last;
    final button = find.widgetWithText(ElevatedButton, 'Anmelden');

    // Initially disabled
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

    await tester.enterText(email, 'test@luvi.app');
    await tester.enterText(password, 'secret');
    await tester.pump();

    // Now enabled
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
  });
}
