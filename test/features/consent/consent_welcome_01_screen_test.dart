import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';
import 'package:luvi_app/features/consent/widgets/button_primary.dart';
import 'package:luvi_app/features/consent/widgets/dots_pager.dart';

void main() {
  testWidgets('Welcome_01 shows title and primary CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ConsentWelcome01Screen()));
    // Find RichText widget that contains 'Superkraft' in its text span
    expect(find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final textSpan = widget.text;
        if (textSpan is TextSpan) {
          return textSpan.toPlainText().contains('Superkraft');
        }
      }
      return false;
    }), findsOneWidget);
    // Button existiert (Custom-Widget)
    expect(find.byType(LuviPrimaryButton), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
    // Dots existieren
    expect(find.byType(LuviPagerDots), findsOneWidget);
  });
}
