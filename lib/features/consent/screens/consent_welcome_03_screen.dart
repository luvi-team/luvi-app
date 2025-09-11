import 'package:flutter/material.dart';
import 'package:luvi_app/core/assets.dart';
// no routing target yet for W3 → keep clean TODO
import '../widgets/welcome_shell.dart';

class ConsentWelcome03Screen extends StatelessWidget {
  const ConsentWelcome03Screen({super.key});

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
            const TextSpan(text: 'Endlich verstehen, was dein '),
            TextSpan(
              text: 'Körper',
              style: t.headlineMedium?.copyWith(color: c.primary),
            ),
            const TextSpan(text: ' dir sagt.'),
          ],
        ),
      ),
      subtitle: 'LUVI zeigt dir deine ganz persönlichen Zusammenhänge.',
      onNext: () {
        // TODO(next): define target route (e.g., '/consent/1') when available
      },
      hero: Image.asset(Assets.consentWelcome03, fit: BoxFit.cover),
      heroAspect: 438 / 619,
      waveHeightPx: 427,
      activeIndex: 2,
    );
  }
}