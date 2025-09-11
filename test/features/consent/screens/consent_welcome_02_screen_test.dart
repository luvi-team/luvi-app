import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

void main() {
  testWidgets(
    'WelcomeShell with W2 content renders headline and Weiter button',
    (WidgetTester tester) async {
      final theme = AppTheme.buildAppTheme();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 100), // Mock hero space
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.headlineMedium,
                      children: const [
                        TextSpan(
                          text: 'Dein Körper spricht zu dir – lerne seine ',
                        ),
                        TextSpan(text: 'Sprache.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'LUVI übersetzt, was dein Zyklus dir sagen möchte.',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: () {}, child: const Text('Weiter')),
                ],
              ),
            ),
          ),
        ),
      );

      final headlineFinder = find.byWidgetPredicate((w) {
        if (w is RichText) {
          return w.text.toPlainText().contains('Dein Körper spricht zu dir');
        }
        return false;
      });
      expect(headlineFinder, findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
    },
  );
}
