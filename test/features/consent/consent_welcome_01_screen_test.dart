import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';

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
    
    // ElevatedButton with 'Weiter' text exists
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
    
    // TextButton with 'Überspringen' text exists
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('Überspringen'), findsOneWidget);
    
    // Check that dots are rendered (3 Container widgets in a Row for the dots)
    expect(find.byWidgetPredicate((widget) {
      return widget is Container &&
             widget.decoration is BoxDecoration &&
             (widget.decoration as BoxDecoration).shape == BoxShape.circle;
    }), findsNWidgets(3));
    
    // Check subtitle text exists
    expect(find.textContaining('Training, Ernährung und Schlaf'), findsOneWidget);
  });
}
