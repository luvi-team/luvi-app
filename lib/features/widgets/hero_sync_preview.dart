import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

/// Luvi‑Sync Preview hero section: background image, top‑right badge, bottom
/// info card with title/teaser and CTA "Mehr".
class HeroSyncPreview extends StatelessWidget {
  final String imagePath;
  final String badgeAssetPath;

  const HeroSyncPreview({
    super.key,
    required this.imagePath,
    required this.badgeAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    const double containerRadius = 24.0;
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
              right: 16,
              child: _Badge(assetPath: badgeAssetPath, size: 32),
            ),
            // Bottom info card (white, r=24, border 1px #696969)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(containerRadius),
                  border: Border.all(color: const Color(0xFF696969), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000), // 12% black
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Heute, 28. Sept',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FontFamilies.figtree,
                              fontSize: 16,
                              height: 24 / 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF030401),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Wir starten heute ruhig und strukturiert - eine lockere Cardio Einheit hilft dir fokussiert zu bleiben...',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FontFamilies.figtree,
                              fontSize: 14,
                              height: 24 / 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF030401),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // CTA "Mehr" (67×32, r=12, BG gold #D9B18E, label bold 16, color #1C1411)
                    _MehrButton(onTap: () {
                      // TODO(route): navigate to Luvi‑Sync/Journal
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        constraints: const BoxConstraints(minWidth: 67),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD9B18E),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Mehr',
          style: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1411),
          ),
        ),
      ),
    );
  }
}
