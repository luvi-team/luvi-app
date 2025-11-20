import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/domain/training_stat_props.dart';
import 'package:luvi_app/features/dashboard/widgets/wearable_connect_card.dart';

/// Layout constants pulled from the dashboard stats Figma spec.
class StatsScrollerLayout {
  const StatsScrollerLayout._();

  static const double cardGap = Spacing.m;
  static const double cardPaddingValue = 16;
  static const EdgeInsets cardPadding = EdgeInsets.all(cardPaddingValue);
  static const double iconCircleDiameter = 29.5;
  static const double iconSize = 18;
  static const double hrGlyphLeft = 50;
  static const double hrGlyphBottom = 36;
  static const double hrGlyphWidth = 101;
  static const double hrGlyphHeight = 35;
  static const double valueAreaHeight = 58;
  static const double labelToValueGap = 10;
  static const int labelWrapThreshold = 12;
  static const double stepsValueAlignmentX = 0.25;
}

const TextHeightBehavior _valueHeightBehavior = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);
const TextHeightBehavior _unitHeightBehavior = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
);

/// Ensures multi-word stat labels (e.g. "Verbrannte Energie") wrap like the Figma spec.
final RegExp _whitespacePattern = RegExp(r'\s+');

String _formatStatLabel(String rawLabel) {
  final trimmed = rawLabel.trim();
  final words = trimmed.split(_whitespacePattern);
  if (words.length == 2 &&
      trimmed.length > StatsScrollerLayout.labelWrapThreshold) {
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
        child: const WearableConnectCard(
          key: Key('dashboard_wearable_connect_card'),
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
        separatorBuilder: (context, index) =>
            const SizedBox(width: StatsScrollerLayout.cardGap),
        itemBuilder: (context, index) =>
            _TrainingStatCard(data: trainingStats[index]),
      ),
    );
  }
}

class _TrainingStatCard extends StatelessWidget {
  const _TrainingStatCard({required this.data});

  final TrainingStatProps data;

  NumberFormat _numberFormatter(BuildContext context) {
    final locale =
        Localizations.maybeLocaleOf(context) ??
        WidgetsBinding.instance.platformDispatcher.locale;
    return NumberFormat.decimalPattern(locale.toLanguageTag());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTokens = theme.extension<TextColorTokens>();
    final dsTokens = theme.extension<DsTokens>();
    final surfaceTokens = theme.extension<SurfaceColorTokens>();
    final titleColor = textTokens?.secondary ?? const Color(0xFF6D6D6D);
    final valueColor = textTokens?.primary ?? const Color(0xFF030401);
    final badgeFill =
        dsTokens?.color.icon.badge.goldCircle ?? const Color(0xFFD9B18E);
    final formattedLabel = _formatStatLabel(data.label);
    final labelMaxLines = formattedLabel.contains('\n') ? 2 : 1;
    final cardSurface =
        surfaceTokens?.cardBackgroundNeutral ??
        dsTokens?.cardSurface ??
        DsColors.cardBackgroundNeutral;
    final formattedValue = _numberFormatter(context).format(data.value);
    final valueGroup = _TrainingStatValueGroup(
      data: data,
      formattedValue: formattedValue,
      valueColor: valueColor,
      titleColor: titleColor,
    );

    return RepaintBoundary(
      child: _TrainingCardSurface(
        cardSurface: cardSurface,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _TrainingCardHeader(
                  label: formattedLabel,
                  labelMaxLines: labelMaxLines,
                  iconAssetPath: data.iconAssetPath,
                  titleColor: titleColor,
                  badgeFill: badgeFill,
                ),
                const SizedBox(height: StatsScrollerLayout.labelToValueGap),
                _TrainingCardValueArea(child: valueGroup),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingStatValueGroup extends StatelessWidget {
  const _TrainingStatValueGroup({
    required this.data,
    required this.formattedValue,
    required this.valueColor,
    required this.titleColor,
  });

  final TrainingStatProps data;
  final String formattedValue;
  final Color valueColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
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
      return _buildCenteredValue(valueStyle);
    }

    return _buildInlineValue(data.unit!, valueStyle, unitStyle);
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
    String unit,
    TextStyle valueStyle,
    TextStyle unitStyle,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: RichText(
        textHeightBehavior: _valueHeightBehavior,
        text: TextSpan(
          text: formattedValue,
          style: valueStyle,
          children: [TextSpan(text: ' $unit', style: unitStyle)],
        ),
      ),
    );
  }

  Widget _buildCenteredValue(TextStyle valueStyle) {
    return Align(
      alignment: Alignment(StatsScrollerLayout.stepsValueAlignmentX, -1),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          formattedValue,
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
      left: StatsScrollerLayout.hrGlyphLeft,
      bottom:
          StatsScrollerLayout.hrGlyphBottom - StatsScrollerLayout.cardPaddingValue,
      child: SvgPicture.asset(
        asset,
        width: StatsScrollerLayout.hrGlyphWidth,
        height: StatsScrollerLayout.hrGlyphHeight,
        excludeFromSemantics: true,
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
      width: StatsScrollerLayout.iconCircleDiameter,
      height: StatsScrollerLayout.iconCircleDiameter,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        assetPath,
        width: StatsScrollerLayout.iconSize,
        height: StatsScrollerLayout.iconSize,
        excludeFromSemantics: true,
        colorFilter: const ColorFilter.mode(Color(0xFF1C1411), BlendMode.srcIn),
      ),
    );
  }
}

class _TrainingCardSurface extends StatelessWidget {
  const _TrainingCardSurface({
    required this.cardSurface,
    required this.child,
  });

  final Color cardSurface;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: StatsScrollerLayout.cardPadding,
      child: child,
    );
  }
}

class _TrainingCardHeader extends StatelessWidget {
  const _TrainingCardHeader({
    required this.label,
    required this.labelMaxLines,
    required this.iconAssetPath,
    required this.titleColor,
    required this.badgeFill,
  });

  final String label;
  final int labelMaxLines;
  final String iconAssetPath;
  final Color titleColor;
  final Color badgeFill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TypographyTokens.size14 *
          TypographyTokens.lineHeightRatio24on14 *
          2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
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
            assetPath: iconAssetPath,
            backgroundColor: badgeFill,
          ),
        ],
      ),
    );
  }
}

class _TrainingCardValueArea extends StatelessWidget {
  const _TrainingCardValueArea({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: StatsScrollerLayout.valueAreaHeight,
      child: child,
    );
  }
}
