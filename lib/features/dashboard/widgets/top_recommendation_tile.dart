import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_tokens/assets.dart';
import '../../../core/design_tokens/typography.dart';
import '../../../core/theme/app_theme.dart';

const double _tileHeight = 150.0; // Figma: 150px
const double _badgeSize = 32.0; // Figma: 32px
const double _badgeOffsetTop = 7.0;
const double _badgeOffsetRight = 12.0;
const BorderRadius _tileRadius = BorderRadius.all(Radius.circular(20));
const double _durationIconSize = 14.0; // Figma: 14×14
const double _durationIconTextGap = 4.0; // Figma: 4px gap
const Color _duration60White = Color(0x99FFFFFF); // 60% white (0x99 = 153 / 255 ≈ 60%)

/// Prominent recommendation tile that surfaces one featured workout.
class TopRecommendationTile extends StatelessWidget {
  const TopRecommendationTile({
    super.key,
    required this.workoutId,
    required this.tag,
    required this.title,
    required this.imagePath,
    required this.badgeAssetPath,
    this.fromLuviSync = true,
    this.duration,
  });

  final String workoutId;
  final String tag;
  final String title;
  final String imagePath;
  final String badgeAssetPath;
  final bool fromLuviSync;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final shadowTokens = Theme.of(context).extension<ShadowTokens>();
    final tileShadow =
        shadowTokens?.tileDrop ??
        const BoxShadow(
          color: Color(0x33000000),
          blurRadius: 4,
          offset: Offset(0, 4),
        );

    final semanticsBuffer = StringBuffer()
      ..write('Top-Empfehlung $title. ')
      ..write('Kategorie $tag.');
    if (fromLuviSync) {
      semanticsBuffer.write(' Von LUVI Sync.');
    }

    return Semantics(
      container: true,
      button: true,
      label: semanticsBuffer.toString(),
      hint: 'Tippe, um das Workout zu öffnen.',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/workout/$workoutId'),
            borderRadius: _tileRadius,
            child: Container(
              constraints: const BoxConstraints.tightFor(height: _tileHeight),
              width: double
                  .infinity, // Spec width ≈385px; expand to viewport width within padding.
              decoration: BoxDecoration(
                borderRadius: _tileRadius,
                boxShadow: [tileShadow],
              ),
              child: ClipRRect(
                borderRadius: _tileRadius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: Colors.black12),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: [0.1, 0.9],
                          colors: [Color(0xFF1E1F24), Color(0x001E1F24)],
                        ),
                      ),
                    ),
                    if (fromLuviSync)
                      Positioned(
                        top: _badgeOffsetTop,
                        right: _badgeOffsetRight,
                        child: ExcludeSemantics(
                          child: SizedBox(
                            key: const Key('top_recommendation_badge'),
                            width: _badgeSize,
                            height: _badgeSize,
                            child: Image.asset(
                              badgeAssetPath,
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                              errorBuilder: (context, error, stackTrace) =>
                                  const ColoredBox(color: Colors.transparent),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            tag.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: FontFamilies.figtree,
                              fontSize: 12,
                              height: 18 / 12,
                              letterSpacing: 0.12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFB9BAC1),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: FontFamilies.figtree,
                              fontSize: 20,
                              height: TypographyTokens.lineHeightRatio24on20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (duration != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  Assets.icons.dashboard.time,
                                  width: _durationIconSize,
                                  height: _durationIconSize,
                                  colorFilter: const ColorFilter.mode(
                                    _duration60White,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: _durationIconTextGap),
                                Text(
                                  duration!,
                                  style: const TextStyle(
                                    fontFamily: FontFamilies.figtree,
                                    fontSize: 12,
                                    height: 24 / 12,
                                    fontWeight: FontWeight.w400,
                                    color: _duration60White,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
