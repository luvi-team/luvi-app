import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  testWidgets('W5 content renders headline and "Jetzt loslegen" CTA', (
    tester,
  ) async {
    final theme = AppTheme.buildAppTheme();
    await tester.pumpWidget(
      buildLocalizedApp(
        theme: theme,
        home: WelcomeShell(
          hero: const SizedBox(),
          title: Text(
            'Kleine Schritte heute. Große Wirkung morgen.',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          subtitle: 'Für jetzt – und dein zukünftiges Ich.',
          primaryButtonLabel: 'Jetzt loslegen', // Screen 5 uses custom CTA
          onNext: () {},
          heroAspect: kWelcomeHeroAspect,
          waveHeightPx: kWelcomeWaveHeight,
        ),
      ),
    );

    // Assert headline contains simplified title
    expect(
      find.text('Kleine Schritte heute. Große Wirkung morgen.'),
      findsOneWidget,
    );

    // Assert subtitle is present
    expect(
      find.text('Für jetzt – und dein zukünftiges Ich.'),
      findsOneWidget,
    );

    // Assert custom "Jetzt loslegen" CTA button (not "Weiter")
    expect(
      find.widgetWithText(ElevatedButton, 'Jetzt loslegen'),
      findsOneWidget,
    );
  });

  testWidgets('W5 semantics header is present', (tester) async {
    final theme = AppTheme.buildAppTheme();
    await tester.pumpWidget(
      buildLocalizedApp(
        theme: theme,
        home: WelcomeShell(
          hero: const SizedBox(),
          title: Text(
            'Kleine Schritte heute. Große Wirkung morgen.',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          subtitle: 'Für jetzt – und dein zukünftiges Ich.',
          primaryButtonLabel: 'Jetzt loslegen',
          onNext: () {},
          heroAspect: kWelcomeHeroAspect,
          waveHeightPx: kWelcomeWaveHeight,
        ),
      ),
    );

    // Semantics header present for accessibility
    final handle = tester.ensureSemantics();
    try {
      final headerFinder = find.byWidgetPredicate(
        (w) => w is Semantics && (w.properties.header == true),
      );
      expect(headerFinder, findsWidgets);
    } finally {
      handle.dispose();
    }
  });
}
