import 'package:flutter/material.dart';
import '../widgets/welcome_shell.dart';

class ConsentWelcome01Screen extends StatelessWidget {
  const ConsentWelcome01Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return WelcomeShell(
      heroAsset: 'assets/images/consent/welcome_01.png',
      title: 'Dein Zyklus ist deine\nSuperkraft.',
      subtitle: 'Training, Ernährung und Schlaf – endlich im Einklang mit dem, was dein Körper dir sagt.',
      onNext: () {
        // später: context.go('/consent/w2');
      },
      heroAspect: 438/619,
      waveHeightPx: 427,
    );
  }
}
