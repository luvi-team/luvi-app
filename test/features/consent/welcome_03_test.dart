// test/features/consent/welcome_03_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/welcome_03.dart';

void main() {
  testWidgets('Welcome3 zeigt CTA Los gehts', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Welcome03Screen()));
    expect(find.text("Los geht's"), findsOneWidget);
    expect(find.byKey(const Key('welcome3_cta')), findsOneWidget);
  });
}
