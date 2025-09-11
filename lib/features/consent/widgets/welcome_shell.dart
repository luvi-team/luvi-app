import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/assets.dart';
import '../../../core/design_tokens/spacing.dart';
import '../../../core/design_tokens/sizes.dart';
import 'dots_indicator.dart';

class WelcomeShell extends StatelessWidget {
  const WelcomeShell({
    super.key,
    required this.hero,
    required this.title,
    required this.subtitle,
    required this.onNext,
    required this.heroAspect, // z.B. 438/619
    required this.waveHeightPx, // z.B. 427
    required this.activeIndex,
    this.waveAsset = Assets.consentWave,
  });

  final Widget hero;
  final Widget title;
  final String subtitle;
  final VoidCallback onNext;
  final double heroAspect;
  final double waveHeightPx;
  final String waveAsset;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        top: false, // Hero darf bis ganz oben (Full-bleed hinter StatusBar)
        bottom: false, // Wave darf full-bleed bis zum unteren Rand
        child: Stack(
          children: [
            // Hero oben, vollständig sichtbar
            Align(
              alignment: Alignment.topCenter,
              child: AspectRatio(
                aspectRatio: heroAspect,
                child: hero,
              ),
            ),
            // Wave exakt unten
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: waveHeightPx,
                child: SvgPicture.asset(waveAsset, fit: BoxFit.fill),
              ),
            ),
            // Text + CTAs auf der Wave
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.l,
                  0,
                  Spacing.l,
                  Spacing.l,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(header: true, child: title),
                    const SizedBox(height: Spacing.s), // title -> subtitle
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: t.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: Spacing.l), // subtitle -> dots
                    // Dots (über dem Button), now reusable
                    DotsIndicator(count: Sizes.dotsCount, activeIndex: activeIndex),
                    const SizedBox(height: Spacing.l), // dots -> button
                    ElevatedButton(
                      onPressed: onNext,
                      child: const Text('Weiter'),
                    ),
                    const SizedBox(height: Spacing.m), // button -> skip
                    TextButton(
                      onPressed: () {
                        /* später: skip */
                      },
                      child: const Text('Überspringen'),
                    ),
                    const SizedBox(
                      height: Spacing.xs,
                    ), // breathing space above home indicator
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
