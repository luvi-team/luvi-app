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
          title: Text(
            'Dein Körper. Dein Rhythmus. Jeden Tag.',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          subtitle:
              'Dein täglicher Begleiter für Training, Ernährung, Schlaf & mehr.',
          onNext: () {},
          heroAspect: kWelcomeHeroAspect,
          waveHeightPx: kWelcomeWaveHeight,
        ),
      ),
    );

    // Assert headline contains simplified title
    expect(
      find.text('Dein Körper. Dein Rhythmus. Jeden Tag.'),
      findsOneWidget,
    );

    // Assert "Weiter" ElevatedButton is present
    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
  });
}
