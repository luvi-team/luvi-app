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

    // Tap required cards via first two InkWell cards to avoid text ambiguity
    final listView = find.byType(ListView);
    final cardInkwells = find.descendant(of: listView, matching: find.byType(InkWell));
    expect(cardInkwells, findsWidgets);
    await tester.tap(cardInkwells.at(0));
    await tester.pumpAndSettle();
    await tester.tap(cardInkwells.at(1));
    await tester.pumpAndSettle();

    // Weiter should now be enabled
    expect(tester.widget<ElevatedButton>(weiterFinder).onPressed, isNotNull);

    // Tap "Alle akzeptieren" to select all optional scopes
    final allAcceptFinder = find.widgetWithText(ElevatedButton, 'Alle akzeptieren');
    expect(allAcceptFinder, findsOneWidget);
    expect(tester.widget<ElevatedButton>(allAcceptFinder).onPressed, isNotNull);
    await tester.tap(allAcceptFinder);
    await tester.pumpAndSettle();

    // Button becomes disabled once all optionals are selected
    expect(tester.widget<ElevatedButton>(allAcceptFinder).onPressed, isNull);

    // Ensure no explicit card titles are present
    expect(find.text('Gesundheitsdaten'), findsNothing);
    expect(find.text('Datenschutzerklärung & Nutzungsbedingungen'), findsNothing);
  });
}
