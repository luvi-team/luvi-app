import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';
import '../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  testWidgets('W3 → W4 navigation (asset-free)', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding/w3',
      routes: [
        GoRoute(
          path: '/onboarding/w3',
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            return WelcomeShell(
              hero: const SizedBox(), // asset-free hero
              title: Text(
                l10n.welcome03Title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              subtitle: l10n.welcome03Subtitle,
              onNext: () => context.go('/onboarding/w4'),
              heroAspect: kWelcomeHeroAspect,
              waveHeightPx: kWelcomeWaveHeight,
            );
          },
        ),
        GoRoute(
          path: '/onboarding/w4',
          builder: (context, state) => const Scaffold(body: Text('Welcome 04')),
        ),
      ],
    );

    await tester.pumpWidget(
      buildTestApp(
        theme: AppTheme.buildAppTheme(),
        router: router,
      ),
    );

    // Get L10n from widget tree context
    final context = tester.element(find.byType(WelcomeShell));
    final l10n = AppLocalizations.of(context)!;

    expect(find.widgetWithText(ElevatedButton, l10n.commonContinue), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, l10n.commonContinue));
    await tester.pumpAndSettle();

    expect(find.text('Welcome 04'), findsOneWidget);
  });
}
