import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/screens/luvi_sync_journal_stub.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

const double _infoCardHeight = 112;

/// Luvi‑Sync Preview hero section: background image, configurable top‑right
/// badge (defaults to 64×64), bottom info card with title/teaser and CTA "Mehr".
class HeroSyncPreview extends StatelessWidget {
  static const double kContainerHeight = 249.0;

  final String imagePath;
  final String badgeAssetPath;
  final String dateText;
  final String subtitle;
  final Widget? overlay;
  final double badgeSize;

  const HeroSyncPreview({
    super.key,
    required this.imagePath,
    required this.badgeAssetPath,
    required this.dateText,
    required this.subtitle,
    this.overlay,
    this.badgeSize = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final radiusTokens = Theme.of(context).extension<CalendarRadiusTokens>();

    final double containerRadius = radiusTokens?.cardLarge ?? 24.0;
    const double containerWidth = double.infinity; // fill parent
    const double containerHeight = kContainerHeight; // from spec

    return ClipRRect(
      borderRadius: BorderRadius.circular(containerRadius),
      child: SizedBox(
        width: containerWidth,
        height: containerHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
            if (overlay != null)
              _OverlayWidget(
                overlay: overlay!,
                containerRadius: containerRadius,
                infoCardHeight: _infoCardHeight,
              ),
            // Top‑right Yin‑Yang badge (64×64, offsets: top 14, right 16)
            Positioned(
              top: 14,
              right: Spacing.m,
              child: _Badge(assetPath: badgeAssetPath, size: badgeSize),
            ),
            // Bottom info card (white, r=24, border 1px #696969)
            _InfoCard(
              dateText: dateText,
              subtitle: subtitle,
              containerRadius: containerRadius,
              onMoreTap: () {
                context.go(LuviSyncJournalStubScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String assetPath;
  final double size;
  const _Badge({required this.assetPath, required this.size});

  @override
  Widget build(BuildContext context) {
    // Render SVG if path ends with .svg, otherwise fall back to PNG asset
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        excludeFromSemantics: true,
      );
    }
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}

class _OverlayWidget extends StatelessWidget {
  final Widget overlay;
  final double containerRadius;
  final double infoCardHeight;

  const _OverlayWidget({
    required this.overlay,
    required this.containerRadius,
    required this.infoCardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (_, constraints) {
          const double revealExtra = Spacing.l * 2;
          final double overlayHeight = (infoCardHeight + revealExtra)
              .clamp(0.0, constraints.maxHeight)
              .toDouble();
          return Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: overlayHeight,
              child: _OverlayClipContent(
                constraints: constraints,
                containerRadius: containerRadius,
                overlay: overlay,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverlayClipContent extends StatelessWidget {
  final BoxConstraints constraints;
  final double containerRadius;
  final Widget overlay;

  const _OverlayClipContent({
    required this.constraints,
    required this.containerRadius,
    required this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(containerRadius),
        bottomRight: Radius.circular(containerRadius),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: IgnorePointer(ignoring: true, child: overlay),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String dateText;
  final String subtitle;
  final VoidCallback onMoreTap;
  final double containerRadius;

  const _InfoCard({
    required this.dateText,
    required this.subtitle,
    required this.onMoreTap,
    required this.containerRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceTokens = theme.extension<SurfaceColorTokens>();
    final shadowTokens = theme.extension<ShadowTokens>();
    final dsTokens = theme.extension<DsTokens>();

    final isMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    final backgroundColor = surfaceTokens?.white ?? const Color(0xFFFFFFFF);
    final borderSide = BorderSide(
      color: dsTokens?.grayscale500 ?? const Color(0xFF696969),
      width: 1,
    );
    final shadowColor =
        shadowTokens?.heroCardDrop.color ?? const Color(0x40000000);
    final borderRadius = BorderRadius.circular(containerRadius);

    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.heroInfoCardPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texts
          Expanded(
            child: _InfoTexts(
              dateText: dateText,
              subtitle: subtitle,
              shadowTokens: shadowTokens,
            ),
          ),
          const SizedBox(width: 12),
          // CTA "Mehr" (67×32, r=12, BG gold #D9B18E, label bold 16, color #1C1411)
          _MehrButton(onTap: onMoreTap),
        ],
      ),
    );

    final Widget platformAwareCard = isMobile
        ? Material(
            color: backgroundColor,
            elevation: 4, // Matches heroCardDrop blur → Material elevation 4.
            shadowColor: shadowColor,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: borderSide,
            ),
            child: cardContent,
          )
        : Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              // Figma-compliant: 1px solid #696969, radius 24px ✓
              border: Border.all(
                color: borderSide.color,
                width: borderSide.width,
              ),
              boxShadow: [
                shadowTokens?.heroCardDrop ??
                    const BoxShadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      spreadRadius: 0,
                      color: Color(0x40000000), // 25% black
                    ),
              ],
            ),
            child: cardContent,
          );

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: _infoCardHeight,
        width: double.infinity,
        child: platformAwareCard,
      ),
    );
  }
}

class _InfoTexts extends StatelessWidget {
  final String dateText;
  final String subtitle;
  final ShadowTokens? shadowTokens;

  const _InfoTexts({
    required this.dateText,
    required this.subtitle,
    required this.shadowTokens,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dateText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: TypographyTokens.size16,
            height: TypographyTokens.lineHeightRatio24on16,
            fontWeight: FontWeight.w700,
            color: onSurface,
            shadows: [
              shadowTokens?.heroCalloutTextShadow ??
                  const Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    color: Color(0x20000000),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: TypographyTokens.size14,
            height: TypographyTokens.lineHeightRatio24on14,
            fontWeight: FontWeight.w400,
            color: onSurface,
            shadows: [
              shadowTokens?.heroCalloutTextShadow ??
                  const Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    color: Color(0x20000000),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MehrButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MehrButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 44,
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(Sizes.radiusM),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Sizes.radiusM),
            child: Container(
              height: 32,
              constraints: const BoxConstraints(minWidth: 67),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(Sizes.radiusM),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n?.dashboardHeroCtaMore ?? 'Mehr',
                style: TextStyle(
                  fontFamily: FontFamilies.figtree,
                  fontSize: TypographyTokens.size16,
                  height: TypographyTokens.lineHeightRatio24on16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
