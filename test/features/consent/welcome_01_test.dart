// test/features/consent/welcome_01_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/welcome_01.dart';

void main() {
  testWidgets('Welcome1 zeigt CTA Weiter', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Welcome01Screen()));
    expect(find.text('Weiter'), findsOneWidget);
    expect(find.byKey(const Key('welcome1_cta')), findsOneWidget);
  });
}
