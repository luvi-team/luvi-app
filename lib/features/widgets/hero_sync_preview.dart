import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/screens/luvi_sync_journal_stub.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Luvi‑Sync Preview hero section: background image, top‑right badge, bottom
/// info card with title/teaser and CTA "Mehr".
class HeroSyncPreview extends StatelessWidget {
  final String imagePath;
  final String badgeAssetPath;
  final String dateText;
  final String subtitle;

  const HeroSyncPreview({
    super.key,
    required this.imagePath,
    required this.badgeAssetPath,
    required this.dateText,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final radiusTokens = Theme.of(context).extension<CalendarRadiusTokens>();
    final surfaceTokens = Theme.of(context).extension<SurfaceColorTokens>();
    final shadowTokens = Theme.of(context).extension<ShadowTokens>();
    final dsTokens = Theme.of(context).extension<DsTokens>();
    final colorScheme = Theme.of(context).colorScheme;

    final double containerRadius = radiusTokens?.cardLarge ?? 24.0;
    const double containerWidth = double.infinity; // fill parent
    const double containerHeight = 249.0; // from spec

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
            ),
            // Top‑right Yin‑Yang badge (32×32, offsets: top 14, right 16)
            Positioned(
              top: 14,
              right: Spacing.m,
              child: _Badge(assetPath: badgeAssetPath, size: 32),
            ),
            // Bottom info card (white, r=24, border 1px #696969)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 112,
                decoration: BoxDecoration(
                  color: surfaceTokens?.white ?? const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(containerRadius),
                  border: Border.all(color: dsTokens?.grayscale500 ?? const Color(0xFF696969), width: 1),
                  boxShadow: [
                    shadowTokens?.heroDrop ?? const BoxShadow(
                      color: Color(0x1F000000), // 12% black
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: Spacing.m, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texts
                    Expanded(
                      child: Column(
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
                              color: colorScheme.onSurface,
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
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // CTA "Mehr" (67×32, r=12, BG gold #D9B18E, label bold 16, color #1C1411)
                    _MehrButton(onTap: () {
                      context.go(LuviSyncJournalStubScreen.route);
                    }),
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

class _Badge extends StatelessWidget {
  final String assetPath;
  final double size;
  const _Badge({required this.assetPath, required this.size});

  @override
  Widget build(BuildContext context) {
    // Render SVG if path ends with .svg, otherwise fall back to PNG asset
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(assetPath, width: size, height: size);
    }
    return Image.asset(assetPath, width: size, height: size);
  }
}

class _MehrButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MehrButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        constraints: const BoxConstraints(minWidth: 67),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.m, vertical: 10),
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
    );
  }
}
