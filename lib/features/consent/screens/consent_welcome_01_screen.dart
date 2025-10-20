import 'package:flutter/material.dart';
import 'welcome_metrics.dart';
import 'package:luvi_app/core/assets.dart';
import 'package:go_router/go_router.dart';
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
    return WelcomeShell(
      // RichTitle: normal + Accent getrennt (wie Figma)
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          // use theme-provided H1 (Playfair Display via Theme)
          style: t.headlineMedium,
          children: [
            const TextSpan(text: 'Dein Zyklus ist deine\n'),
            TextSpan(
              text: 'Superkraft.',
              style: t.headlineMedium?.copyWith(color: c.secondary),
            ),
          ],
        ),
      ),
      subtitle:
          'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
      onNext: () => context.go(ConsentWelcome02Screen.routeName),
      hero: Image.asset(Assets.consentWelcome01, fit: BoxFit.cover),
      heroAspect: _kHeroAspect,
      waveHeightPx: _kWaveHeight,
      waveAsset: Assets.consentWave,
      activeIndex: 0,
    );
  }
}
