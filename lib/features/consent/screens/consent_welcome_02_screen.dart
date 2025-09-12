import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/assets.dart';
import '../widgets/welcome_shell.dart';
import 'welcome_metrics.dart';

class ConsentWelcome02Screen extends StatelessWidget {
  const ConsentWelcome02Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return WelcomeShell(
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: t.headlineMedium,
          children: [
            const TextSpan(text: 'Dein Körper spricht zu dir – lerne seine '),
            TextSpan(
              text: 'Sprache.',
              style: t.headlineMedium?.copyWith(color: c.primary),
            ),
          ],
        ),
      ),
      subtitle: 'LUVI übersetzt, was dein Zyklus dir sagen möchte.',
      onNext: () => context.go('/onboarding/w3'),
      hero: Image.asset(Assets.consentWelcome02, fit: BoxFit.cover),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      activeIndex: 1,
    );
  }
}
