import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/consent_screen.dart';
// ignore: unused_import
import '../../../support/test_config.dart';

void main() {
    testWidgets('ConsentScreen shows Consent title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ConsentScreen()));

    expect(find.text('Consent'), findsOneWidget);
  });
}
