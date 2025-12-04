import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
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
          builder: (context, state) => WelcomeShell(
            hero: const SizedBox(), // asset-free hero
            title: Text(
              'Passt sich deinem Zyklus an.',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            subtitle: 'Damit du mit deinem Körper arbeitest, nicht gegen ihn.',
            onNext: () => context.go('/onboarding/w4'),
            heroAspect: kWelcomeHeroAspect,
            waveHeightPx: kWelcomeWaveHeight,
          ),
        ),
        GoRoute(
          path: '/onboarding/w4',
          builder: (context, state) => const Scaffold(body: Text('Welcome 04')),
        ),
      ],
    );

    await tester.pumpWidget(
      buildLocalizedApp(
        theme: AppTheme.buildAppTheme(),
        router: router,
      ),
    );

    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Weiter'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome 04'), findsOneWidget);
  });
}
