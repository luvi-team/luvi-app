// test/features/consent/consent_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/widgets/consent_button.dart';

void main() {
  testWidgets('ConsentButton shows Accept Terms', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ConsentButton(),
        ),
      ),
    );

    expect(find.text('Accept Terms'), findsOneWidget);
  });
}