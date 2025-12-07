import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('W1 content renders headline and Weiter button (asset-free)', (
    tester,
  ) async {
    final theme = AppTheme.buildAppTheme();
    await tester.pumpWidget(
      buildTestApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return WelcomeShell(
              hero: const SizedBox(),
              title: Text(
                l10n.welcome01Title,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              subtitle: l10n.welcome01Subtitle,
              onNext: () {},
              heroAspect: kWelcomeHeroAspect,
              waveHeightPx: kWelcomeWaveHeight,
            );
          },
        ),
      ),
    );

    // Get L10n from widget tree context
    final context = tester.element(find.byType(WelcomeShell));
    final l10n = AppLocalizations.of(context)!;

    // Assert headline contains localized title
    expect(find.text(l10n.welcome01Title), findsOneWidget);

    // Assert localized CTA button is present
    expect(find.widgetWithText(ElevatedButton, l10n.commonContinue), findsOneWidget);
  });
}
