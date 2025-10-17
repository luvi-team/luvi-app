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
          color: Color(0x20000000), // 12.5% alpha (consistent with ShadowTokens.light)
          blurRadius: 4,
          offset: Offset(0, 4),
        );
    final gradient = overlayTokens?.gradient ?? _fallbackGradient;
    final semanticsLabel = subtitle != null ? '$title, $subtitle' : title;

    // Phase 8 (Verification): TextPainter-based fallback cascade
    // Cascade: 16px/1 line → 14px/1 line → 2 lines@14px → ellipsis
    // Available width: 155px (card width) - 28px (padding) = 127px
    const maxWidth = 155.0 - 28.0;
    final titleConfig = _TitleStyleConfig.compute(title, maxWidth);

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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: titleConfig.maxLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // Phase 8 (Verification): TextPainter-based fallback cascade
                          // Cascade: 16px/1 line → 14px/1 line → 2 lines@14px → ellipsis
                          // See _TitleStyleConfig.compute() for measurement logic
                          fontFamily: FontFamilies.figtree,
                          fontSize: titleConfig.fontSize,
                          height: titleConfig.lineHeightRatio,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                        ),
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
                            fontSize: 14,
                            height: 20 / 14,
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

/// Helper class for computing title text style with fallback cascade.
/// Phase 8 (Verification): Implements strict MVP spec:
/// - Try 16px @ 1 line → if fits, use it
/// - Else try 14px @ 1 line → if fits, use it
/// - Else try 14px @ 2 lines → if fits, use it
/// - Else use 14px @ 2 lines + ellipsis (final fallback)
class _TitleStyleConfig {
  final double fontSize;
  final double lineHeightRatio;
  final int maxLines;

  const _TitleStyleConfig({
    required this.fontSize,
    required this.lineHeightRatio,
    required this.maxLines,
  });

  /// Compute the appropriate text style for the given title and max width.
  /// Uses TextPainter to measure text layout at each fallback step.
  static _TitleStyleConfig compute(String text, double maxWidth) {
    const baseStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w600,
    );

    // Step 1: Try 16px @ 1 line
    final painter16 = TextPainter(
      text: TextSpan(
        text: text,
        style: baseStyle.copyWith(
          fontSize: 16,
          height: TypographyTokens.lineHeightRatio24on16,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);

    if (!painter16.didExceedMaxLines) {
      return const _TitleStyleConfig(
        fontSize: 16,
        lineHeightRatio: TypographyTokens.lineHeightRatio24on16,
        maxLines: 1,
      );
    }

    // Step 2: Try 14px @ 1 line
    final painter14_1line = TextPainter(
      text: TextSpan(
        text: text,
        style: baseStyle.copyWith(
          fontSize: 14,
          height: TypographyTokens.lineHeightRatio24on14,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);

    if (!painter14_1line.didExceedMaxLines) {
      return const _TitleStyleConfig(
        fontSize: 14,
        lineHeightRatio: TypographyTokens.lineHeightRatio24on14,
        maxLines: 1,
      );
    }

    // Step 3: Try 14px @ 2 lines (final fallback, ellipsis if still exceeds)
    // Note: We don't check didExceedMaxLines here, as 2 lines is the final fallback.
    // If text still doesn't fit, ellipsis will be applied by Text widget.
    return const _TitleStyleConfig(
      fontSize: 14,
      lineHeightRatio: TypographyTokens.lineHeightRatio24on14,
      maxLines: 2,
    );
  }
}
