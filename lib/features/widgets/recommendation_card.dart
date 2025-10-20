import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

/// Recommendation card for Dashboard (image + gradient overlay + tag + title).
/// from DASHBOARD_spec.json $.recommendations.card (155×180, radius 20, gradient overlay)
class RecommendationCard extends StatelessWidget {
  final String imagePath;
  final String tag;
  final String title;
  final bool showTag;
  final String? subtitle;
  final double width;
  final double height;

  const RecommendationCard({
    required this.imagePath,
    required this.tag,
    required this.title,
    this.subtitle,
    this.width = 155,
    this.height = 180,
    this.showTag = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(
      Radius.circular(
        Sizes.radiusL,
      ), // from DASHBOARD_spec.json $.recommendations.card.radius.all
    );
    final theme = Theme.of(context);
    final shadowTokens = theme.extension<ShadowTokens>();
    final typographyTokens = theme.extension<WorkoutCardTypographyTokens>();
    final recommendationOverlayTokens = theme
        .extension<RecommendationCardOverlayTokens>();
    final tileShadow =
        shadowTokens?.tileDrop ??
        const BoxShadow(
          color: Color(
            0x20000000,
          ), // 12.5% alpha (consistent with ShadowTokens.light)
          blurRadius: 4,
          offset: Offset(0, 4),
        );
    final gradient =
        recommendationOverlayTokens?.gradient ??
        RecommendationCardOverlayTokens.light.gradient;
    final semanticsLabel = subtitle != null ? '$title, $subtitle' : title;
    final titleStyle =
        (typographyTokens?.titleStyle ??
                const TextStyle(
                  fontFamily: FontFamilies.playfairDisplay,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 32 / 24,
                ))
            .copyWith(color: const Color(0xFFFFFFFF));

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [tileShadow],
      ),
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: borderRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: Semantics(
            label: semanticsLabel,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit
                      .cover, // from DASHBOARD_spec_deltas.json $.deltas[7]
                  errorBuilder: Assets.defaultImageErrorBuilder,
                ),
                Container(
                  decoration: BoxDecoration(
                    // from DASHBOARD_spec.json $.recommendations.card.imageOverlay.gradient
                    gradient: gradient,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: titleStyle,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: FontFamilies.figtree,
                            fontSize: 12,
                            height: 24 / 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                      if (showTag) ...[
                        const SizedBox(height: 4),
                        Text(
                          tag,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: FontFamilies.figtree,
                            fontSize: 12,
                            height: 18 / 12,
                            letterSpacing: 0.12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6d6d6d),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
