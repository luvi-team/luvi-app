import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/domain/training_stat_props.dart';
import 'package:luvi_app/features/widgets/dashboard/wearable_connect_card.dart';

const double _cardGap = Spacing.m; // 16px between stat cards
const double _cardPadding =
    16; // Reduced from 20 to fit content in 159px height
const double _iconCircleDiameter = 29.5;
const double _iconSize = 18;
// HR glyph positioning (Figma node 68589:7675, anchored to bottom for overflow-free layout)
const double _hrGlyphLeft = 50;
const double _hrGlyphBottom = 36;
const double _hrGlyphWidth = 101;
const double _hrGlyphHeight = 35;
const double _valueAreaHeight = 58;
const double _labelToValueGap = 10; // Space between label block and value block
const int _labelWrapThreshold = 12;
const double _stepsValueAlignmentX = 0.25;
const TextHeightBehavior _valueHeightBehavior = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);
const TextHeightBehavior _unitHeightBehavior = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);

/// Ensures multi-word stat labels (e.g. "Verbrannte Energie") wrap like the Figma spec.
String _formatStatLabel(String rawLabel) {
  final trimmed = rawLabel.trim();
  final words = trimmed.split(RegExp(r'\s+'));
  if (words.length == 2 && trimmed.length > _labelWrapThreshold) {
    return '${words.first}\n${words.last}';
  }
  return trimmed;
}

@visibleForTesting
String formatStatLabelForTest(String rawLabel) => _formatStatLabel(rawLabel);

/// Horizontally scrollable training stats with glass cards.
class StatsScroller extends StatelessWidget {
  const StatsScroller({
    super.key,
    required this.trainingStats,
    required this.isWearableConnected,
  });

  final List<TrainingStatProps> trainingStats;
  final bool isWearableConnected;

  bool get _shouldShowFallback => !isWearableConnected || trainingStats.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_shouldShowFallback) {
      return SizedBox(
        height: kStatsCardHeight,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: const [
            WearableConnectCard(key: Key('dashboard_wearable_connect_card')),
          ],
        ),
      );
    }

    return SizedBox(
      height: kStatsCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: trainingStats.length,
        separatorBuilder: (context, index) => const SizedBox(width: _cardGap),
        itemBuilder: (context, index) =>
            _TrainingStatCard(data: trainingStats[index]),
      ),
    );
  }
}

class _TrainingStatCard extends StatelessWidget {
  const _TrainingStatCard({required this.data});

  final TrainingStatProps data;

  static final NumberFormat _formatter = NumberFormat.decimalPattern('de_DE');

  Widget _buildValueGroup(Color valueColor, Color titleColor) {
    final formattedValue = _formatter.format(data.value);
    final valueStyle = TextStyle(
      fontFamily: FontFamilies.playfairDisplay,
      fontSize: TypographyTokens.size28,
      height: TypographyTokens.lineHeightRatio36on28,
      fontWeight: FontWeight.w400,
      color: valueColor,
    );
    final unitStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: TypographyTokens.size12,
      height: TypographyTokens.lineHeightRatio16on12,
      fontWeight: FontWeight.w500,
      color: titleColor,
    );

    if (data.heartRateGlyphAsset != null) {
      return _buildStackedValue(
        formattedValue,
        data.unit,
        valueStyle,
        unitStyle,
        glyph: _buildHeartGlyphIfAny(),
      );
    }

    if (data.unit == null) {
      return _buildCenteredValue(formattedValue, valueStyle);
    }

    return _buildInlineValue(formattedValue, data.unit!, valueStyle, unitStyle);
  }

  Widget _buildStackedValue(
    String value,
    String? unit,
    TextStyle valueStyle,
    TextStyle unitStyle, {
    Widget? glyph,
  }) {
    final content = Align(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: valueStyle,
            textHeightBehavior: _valueHeightBehavior,
          ),
          if (unit != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                unit,
                style: unitStyle,
                textHeightBehavior: _unitHeightBehavior,
              ),
            ),
        ],
      ),
    );

    if (glyph == null) {
      return content;
    }

    return Stack(clipBehavior: Clip.none, children: [content, glyph]);
  }

  Widget _buildInlineValue(
    String value,
    String unit,
    TextStyle valueStyle,
    TextStyle unitStyle,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: RichText(
        textHeightBehavior: _valueHeightBehavior,
        text: TextSpan(
          text: value,
          style: valueStyle,
          children: [TextSpan(text: ' $unit', style: unitStyle)],
        ),
      ),
    );
  }

  Widget _buildCenteredValue(String value, TextStyle valueStyle) {
    return Align(
      alignment: Alignment(_stepsValueAlignmentX, -1),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          value,
          style: valueStyle,
          textHeightBehavior: _valueHeightBehavior,
        ),
      ),
    );
  }

  Widget? _buildHeartGlyphIfAny() {
    final asset = data.heartRateGlyphAsset;
    if (asset == null) {
      return null;
    }
    return Positioned(
      left: _hrGlyphLeft,
      bottom: _hrGlyphBottom - _cardPadding,
      child: SvgPicture.asset(
        asset,
        width: _hrGlyphWidth,
        height: _hrGlyphHeight,
        excludeFromSemantics: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    final dsTokens = Theme.of(context).extension<DsTokens>();
    final surfaceTokens = Theme.of(context).extension<SurfaceColorTokens>();

    final titleColor = textTokens?.secondary ?? const Color(0xFF6D6D6D);
    final valueColor = textTokens?.primary ?? const Color(0xFF030401);
    final badgeFill =
        dsTokens?.color.icon.badge.goldCircle ?? const Color(0xFFD9B18E);
    final formattedLabel = _formatStatLabel(data.label);
    final labelMaxLines = formattedLabel.contains('\n') ? 2 : 1;
    final Color cardSurface =
        surfaceTokens?.cardBackgroundNeutral ??
        dsTokens?.cardSurface ??
        DsColors.cardBackgroundNeutral;

    return RepaintBoundary(
      child: Container(
        key: const Key('stats_card_container'),
        width: kStatsCardWidth,
        height: kStatsCardHeight,
        decoration: BoxDecoration(
          color: cardSurface,
          borderRadius: BorderRadius.circular(kStatsCardRadius),
          border: Border.all(
            color: const Color(0x1A000000), // Figma: 1dp @ 10% black
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(_cardPadding),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height:
                      TypographyTokens.size14 *
                      TypographyTokens.lineHeightRatio24on14 *
                      2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          formattedLabel,
                          maxLines: labelMaxLines,
                          overflow: labelMaxLines == 1
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible,
                          softWrap: labelMaxLines > 1,
                          style: TextStyle(
                            fontFamily: FontFamilies.figtree,
                            fontSize: TypographyTokens.size14,
                            height: TypographyTokens.lineHeightRatio24on14,
                            fontWeight: FontWeight.w500,
                            color: titleColor,
                          ),
                        ),
                      ),
                      _IconBadge(
                        assetPath: data.iconAssetPath,
                        backgroundColor: badgeFill,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: _labelToValueGap),
                SizedBox(
                  height: _valueAreaHeight,
                  child: _buildValueGroup(valueColor, titleColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.assetPath, required this.backgroundColor});

  final String assetPath;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _iconCircleDiameter,
      height: _iconCircleDiameter,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        assetPath,
        width: _iconSize,
        height: _iconSize,
        excludeFromSemantics: true,
        colorFilter: const ColorFilter.mode(Color(0xFF1C1411), BlendMode.srcIn),
      ),
    );
  }
}
