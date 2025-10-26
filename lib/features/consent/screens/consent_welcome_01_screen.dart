import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'welcome_metrics.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_02_screen.dart';

class ConsentWelcome01Screen extends StatelessWidget {
  const ConsentWelcome01Screen({super.key});

  static const routeName = '/onboarding/w1';

  // Documented constants (formerly magic numbers)
  static const double _kHeroAspect = kWelcomeHeroAspect; // Figma aspect ratio
  static const double _kWaveHeight =
      kWelcomeWaveHeight; // tuned height from visual QA

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final titleStyle = t.headlineMedium?.copyWith(
      fontSize: TypographyTokens.size28,
      height: TypographyTokens.lineHeightRatio36on28,
    );
    return WelcomeShell(
      // RichTitle: normal + Accent getrennt (wie Figma)
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          // use theme-provided H1 (Playfair Display via Theme)
          style: titleStyle,
          children: [
            const TextSpan(text: 'Im '),
            TextSpan(
              text: 'Einklang',
              style: titleStyle?.copyWith(color: c.secondary),
            ),
            const TextSpan(text: ' mit deinem\n'),
            const TextSpan(text: 'Körper'),
          ],
        ),
      ),
      subtitle:
          'Verwandle deinen Zyklus in deine Stärke. Training, Ernährung, Biohacking – alles perfekt auf deine Hormone abgestimmt.',
      onNext: () => context.go(ConsentWelcome02Screen.routeName),
      hero: Image.asset(Assets.welcomeHero01, fit: BoxFit.cover),
      heroAspect: _kHeroAspect,
      waveHeightPx: _kWaveHeight,
      waveAsset: Assets.welcomeWave,
      headerSpacing: 0,
      activeIndex: 0,
    );
  }
}
