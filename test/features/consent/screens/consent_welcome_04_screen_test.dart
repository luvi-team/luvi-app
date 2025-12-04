import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  testWidgets('W4 content renders headline and Weiter button (asset-free)', (
    tester,
  ) async {
    final theme = AppTheme.buildAppTheme();
    await tester.pumpWidget(
      buildLocalizedApp(
        theme: theme,
        home: WelcomeShell(
          hero: const SizedBox(),
          title: Text(
            'Von Expert:innen erstellt.',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          subtitle: 'Kein Algorithmus, sondern echte Menschen.',
          onNext: () {},
          heroAspect: kWelcomeHeroAspect,
          waveHeightPx: kWelcomeWaveHeight,
        ),
      ),
    );

    // Assert headline contains simplified title
    expect(find.text('Von Expert:innen erstellt.'), findsOneWidget);

    // Assert subtitle is present
    expect(
      find.text('Kein Algorithmus, sondern echte Menschen.'),
      findsOneWidget,
    );

    // Assert "Weiter" ElevatedButton is present
    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
  });

  testWidgets('W4 semantics header is present', (tester) async {
    final theme = AppTheme.buildAppTheme();
    await tester.pumpWidget(
      buildLocalizedApp(
        theme: theme,
        home: WelcomeShell(
          hero: const SizedBox(),
          title: Text(
            'Von Expert:innen erstellt.',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          subtitle: 'Kein Algorithmus, sondern echte Menschen.',
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
