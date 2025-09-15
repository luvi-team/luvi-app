import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen shows headline and button', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: LoginScreen()),
    ));

    expect(find.text('Willkommen zurück 💜'), findsOneWidget);
    expect(find.text('Anmelden'), findsOneWidget);
  });
}
