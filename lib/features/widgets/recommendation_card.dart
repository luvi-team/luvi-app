import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

/// Recommendation card for Dashboard (image + gradient overlay + tag + title).
/// from DASHBOARD_spec.json $.recommendations.card (155×180, radius 20, gradient overlay)
class RecommendationCard extends StatelessWidget {
  final String imagePath;
  final String tag;
  final String title;

  const RecommendationCard({
    required this.imagePath,
    required this.tag,
    required this.title,
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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.14609, 0.95], // from DASHBOARD_spec.json $.recommendations.card.imageOverlay.gradient.stops
                  colors: [
                    Color(0x001E1F24), // from DASHBOARD_spec.json $.recommendations.card.imageOverlay.gradient.stops[0]
                    Color(0xFF1E1F24), // from DASHBOARD_spec.json $.recommendations.card.imageOverlay.gradient.stops[1]
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14), // from DASHBOARD_spec.json $.recommendations.card.content.padding.left
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO(a11y): Tag contrast 2.6:1 fails WCAG AA (DASHBOARD_spec_deltas.json $.deltas[8])
                  // Recommendation: use #A0A0A0 (4.5:1) or #B8B8B8 (7:1) instead of #6D6D6D
                  // from DASHBOARD_spec.json $.recommendations.card.tag.typography
                  Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: 12,
                      height: 18 / 12,
                      letterSpacing: 0.12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6d6d6d), // Figma value (low contrast)
                    ),
                  ),
                  // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[2].value (4px)
                  const SizedBox(height: 4),
                  // from DASHBOARD_spec.json $.recommendations.card.title.typography
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
