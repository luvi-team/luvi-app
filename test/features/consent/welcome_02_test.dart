// test/features/consent/welcome_02_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/welcome_02.dart';

void main() {
  testWidgets('Welcome2 zeigt CTA Weiter', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Welcome02Screen()));
    expect(find.text('Weiter'), findsOneWidget);
    expect(find.byKey(const Key('welcome2_cta')), findsOneWidget);
  });
}
