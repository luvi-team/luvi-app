import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

/// Recommendation card for Dashboard (image + gradient overlay + tag + title).
/// from DASHBOARD_spec.json $.recommendations.card (155×180, radius 20, gradient overlay)
class RecommendationCard extends StatelessWidget {
  final String imagePath;
  final String tag;
  final String title;
  final bool showTag;

  const RecommendationCard({
    required this.imagePath,
    required this.tag,
    required this.title,
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
    final shadowTokens = Theme.of(context).extension<ShadowTokens>();
    final tileShadow =
        shadowTokens?.tileDrop ??
        const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 4,
          offset: Offset(0, 4),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [tileShadow],
      ),
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: borderRadius,
        child: SizedBox(
          width:
              155, // from DASHBOARD_spec.json $.recommendations.list.itemSize.w
          height:
              180, // from DASHBOARD_spec.json $.recommendations.list.itemSize.h
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit:
                    BoxFit.cover, // from DASHBOARD_spec_deltas.json $.deltas[7]
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
                    colors: [Color(0xFF1E1F24), Color(0x001E1F24)],
                  ),
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
      ),
    );
  }
}
