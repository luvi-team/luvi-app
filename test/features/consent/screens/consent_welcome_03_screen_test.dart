import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('W3 content renders headline and Weiter button (asset-free)', (
    tester,
  ) async {
    final theme = AppTheme.buildAppTheme();
    await tester.pumpWidget(
      buildLocalizedApp(
        theme: theme,
        home: WelcomeShell(
          hero: const SizedBox(), // << no real image
          title: Text(
            'Passt sich deinem Zyklus an.',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          subtitle: 'Damit du mit deinem Körper arbeitest, nicht gegen ihn.',
          onNext: () {},
          heroAspect: kWelcomeHeroAspect,
          waveHeightPx: kWelcomeWaveHeight,
        ),
      ),
    );
    expect(
      find.text('Passt sich deinem Zyklus an.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
  });
}
