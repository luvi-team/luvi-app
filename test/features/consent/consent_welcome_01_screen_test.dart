import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';

void main() {
  testWidgets('Welcome01 shows title and primary CTA (robust, Text/RichText)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildAppTheme(),
        home: WelcomeShell(
          heroAsset: 'assets/images/consent/welcome_01.png',
          title: Text.rich(
            TextSpan(
              text: 'Dein Zyklus ist deine\n',
              children: [TextSpan(text: 'Superkraft.')],
            ),
            textAlign: TextAlign.center,
          ),
          subtitle:
              'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
          onNext: () {}, // we only check presence, not navigation here
          heroAspect: 438 / 619,
          waveHeightPx: 413,
          waveAsset: 'assets/images/consent/welcome_wave.svg',
        ),
      ),
    );

    // Robust headline finder: funktioniert für Text ODER RichText/TextSpan
    final headlineFinder = find.byWidgetPredicate((w) {
      if (w is RichText) return w.text.toPlainText().contains('Dein Zyklus');
      if (w is Text) return (w.data?.contains('Dein Zyklus') ?? false);
      return false;
    });
    expect(headlineFinder, findsOneWidget);

    // CTA vorhanden
    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);

    // Subtitle vorhanden (vereinfachte Prüfung)
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.data ?? '').contains('Training, Ernährung und Schlaf'),
      ),
      findsOneWidget,
    );
  });
}
