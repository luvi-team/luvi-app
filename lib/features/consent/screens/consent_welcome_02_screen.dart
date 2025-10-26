import 'package:flutter/material.dart';
import 'welcome_metrics.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:go_router/go_router.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_03_screen.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

class ConsentWelcome02Screen extends StatelessWidget {
  const ConsentWelcome02Screen({super.key});

  static const routeName = '/onboarding/w2';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final titleStyle = t.headlineMedium?.copyWith(
      fontSize: TypographyTokens.size28,
      height: TypographyTokens.lineHeightRatio36on28,
    );

    return WelcomeShell(
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: titleStyle,
          children: [
            const TextSpan(text: 'Von Expert:innen für dich\n'),
            TextSpan(
              text: 'jeden Monat neu',
              style: titleStyle?.copyWith(color: c.primary),
            ),
          ],
        ),
      ),
      subtitle:
          'Echte Personalisierung statt Standard-Pläne. Automatisch angepasst an deine Fortschritte, Zyklusphase und individuelle Ziele.',
      onNext: () => context.go(ConsentWelcome03Screen.routeName),
      hero: Image.asset(Assets.welcomeHero02, fit: BoxFit.cover),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      headerSpacing: 0,
      activeIndex: 1,
    );
  }
}
