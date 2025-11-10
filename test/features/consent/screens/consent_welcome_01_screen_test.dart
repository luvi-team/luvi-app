import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('W1 content renders headline and Weiter button (asset-free)', (
    tester,
  ) async {
    final theme = AppTheme.buildAppTheme();
    await tester.pumpWidget(
      buildLocalizedApp(
        theme: theme,
        home: WelcomeShell(
          hero: const SizedBox(),
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.headlineMedium,
              children: [
                const TextSpan(text: 'Dein Zyklus ist deine\n'),
                TextSpan(
                  text: 'Superkraft.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          subtitle:
              'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
          onNext: () {},
          heroAspect: kWelcomeHeroAspect,
          waveHeightPx: kWelcomeWaveHeight,
          activeIndex: 0,
        ),
      ),
    );

    // Assert headline contains "Dein Zyklus ist deine"
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Dein Zyklus ist deine'),
      ),
      findsOneWidget,
    );

    // Assert "Weiter" ElevatedButton is present
    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
  });
}
