import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_screen.dart';

void main() {
  group('ConsentWelcomeScreen', () {
    testWidgets('displays welcome headline from Figma', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsentWelcomeScreen(),
        ),
      );

      expect(find.textContaining('Lass uns LUVI'), findsOneWidget);
      expect(find.textContaining('auf dich abstimmen 💜'), findsOneWidget);
    });

    testWidgets('displays subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsentWelcomeScreen(),
        ),
      );

      expect(
        find.text('Du entscheidest, was du teilen möchtest. Je mehr wir über dich wissen, desto besser können wir dich unterstützen.'),
        findsOneWidget,
      );
    });

    testWidgets('displays Weiter button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsentWelcomeScreen(),
        ),
      );

      expect(find.text('Weiter'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('has back arrow button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsentWelcomeScreen(),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Weiter button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConsentWelcomeScreen(),
        ),
      );

      final weiterButton = find.text('Weiter');
      expect(weiterButton, findsOneWidget);
      
      await tester.tap(weiterButton);
      await tester.pump();
    });
  });
}