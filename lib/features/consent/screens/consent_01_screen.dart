import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../core/design_tokens/sizes.dart';
import 'consent_02_screen.dart';
import 'consent_welcome_03_screen.dart';

class Consent01Screen extends StatelessWidget {
  const Consent01Screen({super.key});

  static const String routeName = '/consent/01';

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;

    // Helper to convert Figma absolute Y (relative to frame 0..926) to Flutter
    // using the device safe area top as reference. Figma safe area top is 47.
    double y(double figmaY) => paddingTop + (figmaY - 47);

    return Scaffold(
      body: Stack(
        children: [
          // Back button (44pt hitbox, 40px visual circle)
          Positioned(
            left: ConsentSpacing.pageHorizontal,
            top: y(47 + ConsentSpacing.topBarSafeAreaOffset),
            child: BackButtonCircle(
              onPressed: () => context.go(ConsentWelcome03Screen.routeName),
              semanticLabel:
                  (AppLocalizations.of(context)?.authBackSemantic) ?? 'Back',
            ),
          ),

          // Title
          Positioned(
            left: 52,
            right: 51, // 428 - 52 - 325 ≈ 51
            top: y(110),
            child: Text(
              'Lass uns LUVI\nauf dich abstimmen',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          // Body text (max width 384 centered)
          Positioned(
            left: 22,
            top: y(218),
            width: 384,
            child: Text(
              'Du entscheidest, was du teilen möchtest. Je mehr wir über dich wissen, desto besser können wir dich unterstützen.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          // Collage tiles (absolute/staggered)
          _Collage(paddingTop: paddingTop),

          // CTA button (height 50, bottom 44, horizontal 20)
          Positioned(
            left: ConsentSpacing.pageHorizontal,
            right: ConsentSpacing.pageHorizontal,
            bottom: ConsentSpacing.ctaBottomInset,
            height: Sizes.buttonHeight,
            child: ElevatedButton(
              onPressed: () => context.push(Consent02Screen.routeName),
              child: const Text('Weiter'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Collage extends StatelessWidget {
  const _Collage({required this.paddingTop});
  final double paddingTop;

  // Figma absolute positions for tiles
  static const _tiles = <({double x, double y, String asset})>[
    (
      x: 55.0,
      y: 341.0,
      asset: 'assets/images/consent/consent_02_01_hero_01.png',
    ),
    (
      x: 220.0,
      y: 404.0,
      asset: 'assets/images/consent/consent_02_01_hero_02.png',
    ),
    (
      x: 55.0,
      y: 514.0,
      asset: 'assets/images/consent/consent_02_01_hero_03.png',
    ),
    (
      x: 220.0,
      y: 577.0,
      asset: 'assets/images/consent/consent_02_01_hero_04.png',
    ),
  ];

  double _y(double figmaY) => paddingTop + (figmaY - 47);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final t in _tiles)
          Positioned(
            left: t.x,
            top: _y(t.y),
            width: 153,
            height: 153,
            child: ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.radiusL),
                child: Image.asset(t.asset, fit: BoxFit.cover),
              ),
            ),
          ),
      ],
    );
  }
}

// BackButtonCircle moved to lib/features/widgets/back_button.dart
