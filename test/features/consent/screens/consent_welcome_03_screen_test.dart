import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';

void main() {
  testWidgets('W3 content renders headline and Weiter button (asset-free)', (
    tester,
  ) async {
    final theme = AppTheme.buildAppTheme();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: WelcomeShell(
          hero: const SizedBox(), // << no real image
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.headlineMedium,
              children: [
                const TextSpan(text: 'Endlich verstehen, was dein '),
                TextSpan(
                  text: 'Körper',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const TextSpan(text: ' dir sagt.'),
              ],
            ),
          ),
          subtitle: 'LUVI zeigt dir deine ganz persönlichen Zusammenhänge.',
          onNext: () {},
          heroAspect: kWelcomeHeroAspect,
          waveHeightPx: kWelcomeWaveHeight,
          activeIndex: 2,
        ),
      ),
    );
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Endlich verstehen, was dein'),
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
  });
}
