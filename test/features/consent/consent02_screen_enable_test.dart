import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/consent/screens/consent_02_screen.dart';

void main() {
  testWidgets('Consent02Screen enables Weiter after required, and disables Alle akzeptieren after selection', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Consent02Screen()),
      ),
    );

    // Weiter disabled initially
    final weiterFinder = find.widgetWithText(ElevatedButton, 'Weiter');
    expect(weiterFinder, findsOneWidget);
    expect(tester.widget<ElevatedButton>(weiterFinder).onPressed, isNull);

    // Tap required cards by a unique substring in their titles
    await tester.tap(find.text('Gesundheitsdaten'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Datenschutzerklärung & Nutzungsbedingungen'));
    await tester.pumpAndSettle();

    // Weiter should now be enabled
    expect(tester.widget<ElevatedButton>(weiterFinder).onPressed, isNotNull);

    // Tap "Alle akzeptieren" to select all optional scopes
    final allAcceptFinder = find.widgetWithText(OutlinedButton, 'Alle akzeptieren');
    expect(allAcceptFinder, findsOneWidget);
    expect(tester.widget<OutlinedButton>(allAcceptFinder).onPressed, isNotNull);
    await tester.tap(allAcceptFinder);
    await tester.pumpAndSettle();

    // Button becomes disabled once all optionals are selected
    expect(tester.widget<OutlinedButton>(allAcceptFinder).onPressed, isNull);
  });
}
