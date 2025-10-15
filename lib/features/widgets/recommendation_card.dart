import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

/// Recommendation card for Dashboard (image + gradient overlay + tag + title).
/// from DASHBOARD_spec.json $.recommendations.card (155×180, radius 20, gradient overlay)
class RecommendationCard extends StatelessWidget {
  static const LinearGradient _fallbackGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.146, 0.95],
    colors: [Color(0xFF1A1A1A), Color(0x001A1A1A)],
  );

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
        20,
      ), // from DASHBOARD_spec.json $.recommendations.card.radius.all
    );
    final theme = Theme.of(context);
    final shadowTokens = theme.extension<ShadowTokens>();
    final overlayTokens = theme.extension<WorkoutCardOverlayTokens>();
    final tileShadow =
        shadowTokens?.tileDrop ??
        const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 4,
          offset: Offset(0, 4),
        );
    final gradient = overlayTokens?.gradient ?? _fallbackGradient;
    final semanticsLabel = subtitle != null ? '$title, $subtitle' : title;

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
                  errorBuilder: (context, error, stackTrace) {
                    // TODO(audit: dashboard image assets missing in widget test bundle)
                    return const ColoredBox(color: Colors.black12);
                  },
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
                      if (subtitle != null) ...[
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: FontFamilies.figtree,
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
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
        ),
      ),
    );
  }
}
