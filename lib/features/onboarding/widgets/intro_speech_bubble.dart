import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

/// Speech bubble widget with typewriter text reveal effect.
///
/// Displays Luvienne's introduction text with a grapheme-aware
/// typewriter animation driven by [progress] (0..1).
///
/// Line timing distribution:
/// - line1: 0.00 - 0.35 (35%)
/// - line2: 0.35 - 0.70 (35%)
/// - line3: 0.70 - 0.85 (15%)
/// - line4: 0.85 - 1.00 (15%)
class IntroSpeechBubble extends StatelessWidget {
  const IntroSpeechBubble({
    super.key,
    required this.progress,
    required this.line1,
    required this.line2,
    required this.line3,
    required this.line4,
  });

  /// Animation progress from 0.0 to 1.0.
  final double progress;

  /// First line of speech: "Bonjour, ich bin Luvienne."
  final String line1;

  /// Second line: "Nenne mich aber gerne Luvi."
  final String line2;

  /// Third line: "Lass mich dich kennenlernen,"
  final String line3;

  /// Fourth line: "damit ich dich bestmoeglich begleiten kann."
  final String line4;

  /// Border width for the speech bubble (Figma: 2px).
  static const double _borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    // Build full text for semantics (a11y)
    final fullText = '$line1\n$line2\n$line3\n$line4';

    // Calculate revealed text for each line based on progress
    final revealedLine1 = _revealText(line1, progress, 0.0, 0.35);
    final revealedLine2 = _revealText(line2, progress, 0.35, 0.70);
    final revealedLine3 = _revealText(line3, progress, 0.70, 0.85);
    final revealedLine4 = _revealText(line4, progress, 0.85, 1.0);

    return Semantics(
      label: fullText,
      child: ExcludeSemantics(
        child: Container(
          width: Sizes.speechBubbleWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          decoration: BoxDecoration(
            color: DsColors.grayscaleWhite.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(Sizes.radiusCard),
            border: Border.all(
              color: DsColors.authRebrandRainbowTeal,
              width: _borderWidth,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line 1 with bold styling
              _TypewriterLine(text: revealedLine1, isBold: true),
              if (revealedLine2.isNotEmpty) ...[
                const SizedBox(height: Spacing.xxs),
                _TypewriterLine(text: revealedLine2, isBold: false),
              ],
              if (revealedLine3.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                _TypewriterLine(text: revealedLine3, isBold: false),
              ],
              if (revealedLine4.isNotEmpty)
                _TypewriterLine(text: revealedLine4, isBold: false),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculates the revealed portion of text based on progress within a range.
  ///
  /// Uses [Characters] for grapheme-aware text slicing (handles emojis correctly).
  String _revealText(
    String fullText,
    double progress,
    double startProgress,
    double endProgress,
  ) {
    if (progress < startProgress) return '';
    if (progress >= endProgress) return fullText;

    // Calculate relative progress within this line's range
    final rangeProgress = (progress - startProgress) / (endProgress - startProgress);
    final clampedProgress = rangeProgress.clamp(0.0, 1.0);

    // Use Characters for grapheme-aware text slicing
    final characters = fullText.characters;
    final totalChars = characters.length;
    final revealedCount = (totalChars * clampedProgress).floor();

    return characters.take(revealedCount).toString();
  }
}

/// Single line of typewriter text with consistent styling.
class _TypewriterLine extends StatelessWidget {
  const _TypewriterLine({
    required this.text,
    required this.isBold,
  });

  final String text;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: TextStyle(
        fontFamily: FontFamilies.figtree,
        fontSize: TypographyTokens.size14,
        fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
        height: TypographyTokens.lineHeightRatio24on14,
        color: DsColors.introTextPrimary,
      ),
    );
  }
}
