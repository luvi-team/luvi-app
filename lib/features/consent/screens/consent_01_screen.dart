import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Intro header (back button + copy)
          Positioned.fill(
            child: _ConsentIntroHeader(
              paddingTop: paddingTop,
              l10n: l10n,
            ),
          ),
          // Collage tiles (absolute/staggered)
          Positioned.fill(
            child: _ConsentCollage(paddingTop: paddingTop),
          ),
          // CTA button (height 50, bottom 44, horizontal 20)
          _ConsentFooterCta(l10n: l10n),
        ],
      ),
    );
  }
}

class _ConsentIntroHeader extends StatelessWidget {
  const _ConsentIntroHeader({
    required this.paddingTop,
    required this.l10n,
  });

  final double paddingTop;
  final AppLocalizations l10n;

  double _y(double figmaY) => paddingTop + (figmaY - 47);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Stack(
      children: [
        Positioned(
          left: ConsentSpacing.pageHorizontal,
          top: paddingTop + ConsentSpacing.topBarSafeAreaOffset,
          child: BackButtonCircle(
            onPressed: () => context.go(ConsentWelcome03Screen.routeName),
            semanticLabel: l10n.authBackSemantic,
          ),
        ),
        Positioned(
          left: 52,
          right: 51, // 428 - 52 - 325 ≈ 51
          top: _y(110),
          child: Text(
            'Lass uns LUVI\nauf dich abstimmen',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Positioned(
          left: 22,
          top: _y(218),
          width: 384,
          child: Text(
            'Du entscheidest, was du teilen möchtest. Je mehr wir über dich wissen, desto besser können wir dich unterstützen.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsentCollage extends StatelessWidget {
  const _ConsentCollage({required this.paddingTop});
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

class _ConsentFooterCta extends StatelessWidget {
  const _ConsentFooterCta({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: ConsentSpacing.pageHorizontal,
      right: ConsentSpacing.pageHorizontal,
      bottom: ConsentSpacing.ctaBottomInset,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        onPressed: () => context.push(Consent02Screen.routeName),
        child: Text(l10n.commonContinue),
      ),
    );
  }
}
