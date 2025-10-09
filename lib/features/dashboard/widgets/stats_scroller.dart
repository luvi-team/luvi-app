import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/widgets/wearable_connect_card.dart';
import 'package:luvi_app/features/screens/heute_fixtures.dart';

const double _cardGap = Spacing.m; // 16px between stat cards
const double _cardPadding = 20;
const double _iconCircleDiameter = 29.5;
const double _iconSize = 18;
const double _chartHeight = 44;

/// Horizontally scrollable training stats with glass cards.
class StatsScroller extends StatelessWidget {
  const StatsScroller({
    super.key = const Key('dashboard_training_stats_scroller'),
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
          children: const [WearableConnectCard()],
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

  @override
  Widget build(BuildContext context) {
    final glassTokens = Theme.of(context).extension<GlassTokens>();
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    final dsTokens = Theme.of(context).extension<DsTokens>();

    final backgroundColor = glassTokens?.background ?? const Color(0x8CFFFFFF);
    final borderSide =
        glassTokens?.border ?? const BorderSide(color: Color(0x14000000));
    final blur = glassTokens?.blur ?? 16.0;
    final titleColor = textTokens?.secondary ?? const Color(0xFF6D6D6D);
    final valueColor = textTokens?.primary ?? const Color(0xFF030401);
    final badgeFill =
        dsTokens?.color.icon.badge.goldCircle ?? const Color(0xFFD9B18E);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kStatsCardRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: kStatsCardWidth,
            height: kStatsCardHeight,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(kStatsCardRadius),
              border: Border.fromBorderSide(borderSide),
            ),
            padding: const EdgeInsets.all(_cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data.label,
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
                const SizedBox(height: 16),
                Text(
                  _formatter.format(data.value),
                  style: TextStyle(
                    fontFamily: FontFamilies.playfairDisplay,
                    fontSize: TypographyTokens.size32,
                    height: TypographyTokens.lineHeightRatio40on32,
                    fontWeight: FontWeight.w400,
                    color: valueColor,
                  ),
                ),
                if (data.unit != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.unit!,
                    style: TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: TypographyTokens.size14,
                      height: TypographyTokens.lineHeightRatio24on14,
                      fontWeight: FontWeight.w400,
                      color: titleColor,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(child: _SparklineStub(values: data.trend)),
              ],
            ),
          ),
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

class _SparklineStub extends StatelessWidget {
  const _SparklineStub({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return const SizedBox.shrink();
    }

    final dsTokens = Theme.of(context).extension<DsTokens>();
    final accent = dsTokens?.accentPurple ?? const Color(0xFFCCB2F4);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : _chartHeight;
        final double height =
            maxHeight.clamp(0.0, _chartHeight).toDouble();

        return Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(painter: _SparklineStubPainter(values, accent)),
          ),
        );
      },
    );
  }
}

class _SparklineStubPainter extends CustomPainter {
  _SparklineStubPainter(this.values, this.accent);

  final List<double> values;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final clamped = values.map((v) => v.clamp(0.0, 1.0)).toList();
    final step = size.width / (clamped.length - 1);

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < clamped.length; i++) {
      final x = step * i;
      final y = size.height * (1 - clamped[i]);
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.35),
          accent.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final strokePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklineStubPainter oldDelegate) {
    if (identical(oldDelegate.values, values)) return false;
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) {
        return true;
      }
    }
    return false;
  }
}
