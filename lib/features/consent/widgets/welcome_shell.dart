import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeShell extends StatelessWidget {
  const WelcomeShell({
    super.key,
    required this.heroAsset,
    required this.title,
    required this.subtitle,
    required this.onNext,
    required this.heroAspect,    // z.B. 438/619
    required this.waveHeightPx,  // z.B. 427
  });

  final String heroAsset;
  final String title;
  final String subtitle;
  final VoidCallback onNext;
  final double heroAspect;
  final double waveHeightPx;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Hero oben, vollständig sichtbar
            Align(
              alignment: Alignment.topCenter,
              child: AspectRatio(
                aspectRatio: heroAspect,
                child: Image.asset(
                  heroAsset,
                  fit: BoxFit.contain,
                  semanticLabel: 'Welcome Hero',
                ),
              ),
            ),
            // Wave exakt unten
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // Schatten aus Figma-Filter als BoxShadow nachgebildet
                decoration: const BoxDecoration(
                  boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, 4), color: Color.fromRGBO(0,0,0,0.25))],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: waveHeightPx,
                  child: SvgPicture.asset(
                    'assets/images/consent/welcome_wave.svg',
                    fit: BoxFit.fill, // füllt die Breite exakt
                  ),
                ),
              ),
            ),
            // Text + CTAs auf der Wave
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                // spacing/24 etc. – bis Tokens gemappt sind, konstant dokumentiert
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, textAlign: TextAlign.center, style: t.textTheme.headlineMedium),
                    ),
                    const SizedBox(height: 12),
                    Text(subtitle, textAlign: TextAlign.center, style: t.textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: onNext, child: const Text('Weiter')),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () {/* später: skip */}, child: const Text('Überspringen')),
                    const SizedBox(height: 12),
                    // Simple Dots (statisch für Welcome_01)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Dot(active: true),
                        const SizedBox(width: 8),
                        const _Dot(active: false),
                        const SizedBox(width: 8),
                        const _Dot(active: false),
                      ],
                    ),
                    const SizedBox(height: 8),
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

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? c.primary : c.outlineVariant,
      ),
    );
  }
}
