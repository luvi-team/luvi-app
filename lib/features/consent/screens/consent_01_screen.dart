import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_tokens/sizes.dart';

class Consent01Screen extends StatelessWidget {
  const Consent01Screen({super.key});

  static const String routeName = '/consent_01';

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;

    // Helper to convert Figma absolute Y (relative to frame 0..926) to Flutter
    // using the device safe area top as reference. Figma safe area top is 47.
    double y(double figmaY) => paddingTop + (figmaY - 47);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Back button (44pt hitbox, 40px visual circle)
          Positioned(
            left: 20,
            top: y(59), // 59 from top, equals safeAreaTop(47) + 12
            child: _BackButton(onPressed: () => context.go('/onboarding/w3')),
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
            left: 20,
            right: 20,
            bottom: 44,
            height: Sizes.buttonHeight,
            child: ElevatedButton(
              onPressed: () => context.go('/consent/02'),
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
    (x: 55.0, y: 341.0, asset: 'assets/images/consent/consent_02_01_hero_01.png'),
    (x: 220.0, y: 404.0, asset: 'assets/images/consent/consent_02_01_hero_02.png'),
    (x: 55.0, y: 514.0, asset: 'assets/images/consent/consent_02_01_hero_03.png'),
    (x: 220.0, y: 577.0, asset: 'assets/images/consent/consent_02_01_hero_04.png'),
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
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  t.asset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  static const _chevronSvg = '''<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M12.5007 14.1666L8.33398 9.99992L12.5007 5.83325" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>''';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Zurück',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary, // Primary/100
                ),
                alignment: Alignment.center,
                child: SvgPicture.string(
                  _chevronSvg,
                  // 'color' is deprecated in flutter_svg ≥2.x. Use colorFilter instead.
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
