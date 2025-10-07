import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

/// Recommendation card for Dashboard (image + gradient overlay + tag + title).
/// from DASHBOARD_spec.json $.recommendations.card (155×180, radius 20, gradient overlay)
class RecommendationCard extends StatelessWidget {
  final String imagePath;
  final String tag;
  final String title;
  final bool showSyncBadge;
  final String? badgeAssetPath;
  final double? badgeSize;
  final bool showTag;

  const RecommendationCard({
    required this.imagePath,
    required this.tag,
    required this.title,
    this.showSyncBadge = false,
    this.badgeAssetPath,
    this.badgeSize,
    this.showTag = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(
      Radius.circular(20), // from DASHBOARD_spec.json $.recommendations.card.radius.all
    );

    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: borderRadius,
      child: SizedBox(
        width: 155, // from DASHBOARD_spec.json $.recommendations.list.itemSize.w
        height: 180, // from DASHBOARD_spec.json $.recommendations.list.itemSize.h
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover, // from DASHBOARD_spec_deltas.json $.deltas[7]
              errorBuilder: (context, error, stackTrace) {
                // TODO(audit: dashboard image assets missing in widget test bundle)
                return const ColoredBox(color: Colors.black12);
              },
            ),
            Container(
              decoration: const BoxDecoration(
                // from DASHBOARD_spec.json $.recommendations.card.imageOverlay.gradient
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.15, 0.95],
                  colors: [
                    Color(0xFF1E1F24),
                    Color(0x001E1F24),
                  ],
                ),
              ),
            ),
            if (showSyncBadge && badgeAssetPath != null)
              Positioned(
                left: 17,
                bottom: 48,
                child: _Badge(
                  assetPath: badgeAssetPath!,
                  size: badgeSize ?? 32,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTag) ...[
                    Text(
                      tag,
                      style: const TextStyle(
                        fontFamily: FontFamilies.figtree,
                        fontSize: 12,
                        height: 18 / 12,
                        letterSpacing: 0.12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6d6d6d),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
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
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          child: SvgPicture.asset(assetPath),
        ),
      );
    }
    return Image.asset(assetPath, width: size, height: size);
  }
}
