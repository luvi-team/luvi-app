import 'package:flutter/material.dart';
import 'welcome_metrics.dart';
import 'package:luvi_app/core/assets.dart';
import 'package:go_router/go_router.dart';
import '../widgets/welcome_shell.dart';
import 'consent_welcome_03_screen.dart';

class ConsentWelcome02Screen extends StatelessWidget {
  const ConsentWelcome02Screen({super.key});

  static const routeName = '/onboarding/w2';

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
      onNext: () => context.go(ConsentWelcome03Screen.routeName),
      hero: Image.asset(Assets.consentWelcome02, fit: BoxFit.cover),
      heroAspect: kWelcomeHeroAspect,
      waveHeightPx: kWelcomeWaveHeight,
      activeIndex: 1,
    );
  }
}
