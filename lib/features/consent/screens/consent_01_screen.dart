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
          title: Text(
            'Lass uns LUVI\nauf dich abstimmen 💜',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          subtitle: 'Du entscheidest, was du teilen möchtest. Je mehr wir über dich wissen, desto besser können wir dich unterstützen.',
          onNext: () => context.go('/consent/02'),
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
        children: const [
          _Tile('assets/images/consent/consent_02_01_hero_01.png'),
          _Tile('assets/images/consent/consent_02_01_hero_02.png'),
          _Tile('assets/images/consent/consent_02_01_hero_03.png'),
          _Tile('assets/images/consent/consent_02_01_hero_04.png'),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String asset;
  const _Tile(this.asset);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.asset(asset, fit: BoxFit.cover),
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
          color: Theme.of(context).colorScheme.primaryContainer, // Primary/100
          borderRadius: BorderRadius.circular(Sizes.radiusM),
          child: InkWell(
            onTap: () => context.go('/onboarding/w3'),
            borderRadius: BorderRadius.circular(Sizes.radiusM),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
