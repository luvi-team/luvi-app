import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';

void main() {
  testWidgets('Welcome_01 shows title and primary CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ConsentWelcome01Screen()));
    expect(find.textContaining('Superkraft'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
  });
}
