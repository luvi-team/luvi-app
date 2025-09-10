import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_welcome_01_screen.dart';

void main() {
  testWidgets('App boots and shows Consent Welcome title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        home: const ConsentWelcome01Screen(),
      ),
    );
    final headlineFinder = find.byWidgetPredicate((w) {
      if (w is RichText) return w.text.toPlainText().contains('Dein Zyklus');
      if (w is Text) return (w.data?.contains('Dein Zyklus') ?? false);
      return false;
    });
    expect(headlineFinder, findsOneWidget);
  });
}
