import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:luvi_app/core/assets.dart';
import 'package:go_router/go_router.dart';
import '../widgets/welcome_shell.dart';

class ConsentWelcome01Screen extends StatelessWidget {
  const ConsentWelcome01Screen({super.key});

  // Documented constants (formerly magic numbers)
  static const double _kHeroAspect = 438 / 619; // Figma aspect ratio
  static const double _kWaveHeight = 413.0; // tuned height from visual QA

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    // Optional debug signal (only in debug builds)
    if (kDebugMode) {
      debugPrint('headlineMedium.fontFamily = ${t.headlineMedium?.fontFamily}');
    }
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
      onNext: () => context.go('/onboarding/w2'),
      hero: Image.asset(Assets.consentWelcome01, fit: BoxFit.cover),
      heroAspect: _kHeroAspect,
      waveHeightPx: _kWaveHeight,
      waveAsset: Assets.consentWave,
      activeIndex: 0,
    );
  }
}
