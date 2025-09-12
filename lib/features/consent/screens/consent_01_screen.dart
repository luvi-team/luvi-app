import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_tokens/sizes.dart';
import '../../../core/design_tokens/spacing.dart';
import '../widgets/welcome_shell.dart';

class Consent01Screen extends StatelessWidget {
  const Consent01Screen({super.key});

  static const String routeName = '/consent_01';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WelcomeShell(
          heroAspect: 1.0, // Square aspect for 2x2 grid
          waveHeightPx: 427,
          activeIndex: 0,
          hero: const _HeroGrid(),
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineMedium,
              children: [
                const TextSpan(text: 'Entfessle deine '),
                TextSpan(
                  text: 'Superkraft.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          subtitle: 'Mit LUVI verstehst du deinen Körper wie nie zuvor.',
          onNext: () => context.go('/consent_02'),
        ),
        const _BackButton(),
      ],
    );
  }
}

class _HeroGrid extends StatelessWidget {
  const _HeroGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: Spacing.s,
        crossAxisSpacing: Spacing.s,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          4,
          (index) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[300],
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + Spacing.m,
      left: Spacing.m,
      child: Semantics(
        button: true,
        label: 'Zurück',
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(Sizes.radiusM),
          child: InkWell(
            onTap: () => context.go('/welcome_04'),
            borderRadius: BorderRadius.circular(Sizes.radiusM),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
