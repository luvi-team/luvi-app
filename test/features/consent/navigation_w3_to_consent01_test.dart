import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';
import 'package:luvi_app/features/consent/screens/welcome_metrics.dart';
import 'package:luvi_app/features/consent/routes.dart';

void main() {
  testWidgets('W3 → Consent01 (asset-free)', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding/w3',
      routes: [
        GoRoute(
          path: '/onboarding/w3',
          builder: (context, state) => WelcomeShell(
            hero: const SizedBox(), // asset-free hero
            title: Text(
              'Endlich verstehen, was dein Körper dir sagt.',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            subtitle: 'Stub subtitle',
            onNext: () => context.go(ConsentRoutes.consent01),
            heroAspect: kWelcomeHeroAspect,
            waveHeightPx: kWelcomeWaveHeight,
            activeIndex: 2,
          ),
        ),
        GoRoute(
          path: ConsentRoutes.consent01,
          builder: (context, state) => const Scaffold(body: Text('Consent 01')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.buildAppTheme(), routerConfig: router),
    );

    expect(find.widgetWithText(ElevatedButton, 'Weiter'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Weiter'));
    await tester.pumpAndSettle();

    expect(find.text('Consent 01'), findsOneWidget);
  });
}
