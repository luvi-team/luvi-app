import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

const double _cardHeight = 280;
const double _cardMaxWidth = 340;
const double _horizontalMargin = 48; // 24px padding on both sides
const double _contentPadding = 14;
const double _metadataGap = 12;
const double _checkmarkPadding = 12;
const double _checkmarkSize = 24;

class WeeklyTrainingCard extends StatelessWidget {
  const WeeklyTrainingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.dayLabel,
    this.duration,
    this.isCompleted = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String? dayLabel;
  final String? duration;
  final bool isCompleted;
  final VoidCallback? onTap;

  double _resolveWidth(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    return math.min(_cardMaxWidth, viewportWidth - _horizontalMargin);
  }

  BorderRadius _resolveRadius(BuildContext context) {
    final radiusTokens = Theme.of(context).extension<CalendarRadiusTokens>();
    final radius = radiusTokens?.cardWorkout ?? 20.0;
    return BorderRadius.circular(radius);
  }

  BoxShadow _resolveShadow(BuildContext context) {
    final shadowTokens = Theme.of(context).extension<ShadowTokens>();
    return shadowTokens?.tileDrop ??
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 4,
          color: DsColors.borderSubtle,
        );
  }

  TextStyle _titleStyle(BuildContext context) {
    final tokens = Theme.of(context).extension<WorkoutCardTypographyTokens>();
    const fallback = TextStyle(
      fontFamily: FontFamilies.playfairDisplay,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 32 / 24,
    );
    return (tokens?.titleStyle ?? fallback).copyWith(color: DsColors.white);
  }

  TextStyle _subtitleStyle(BuildContext context) {
    final tokens = Theme.of(context).extension<WorkoutCardTypographyTokens>();
    const fallback = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
    );
    return (tokens?.subtitleStyle ?? fallback).copyWith(color: DsColors.white);
  }

  TextStyle _detailStyle(BuildContext context) {
    final tokens = Theme.of(context).extension<WorkoutCardTypographyTokens>();
    const fallback = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 24 / 12,
    );
    return (tokens?.durationStyle ?? fallback).copyWith(
      color: DsColors.white.withValues(alpha: 0.8),
    );
  }

  LinearGradient _overlayGradient(BuildContext context) {
    final tokens =
        Theme.of(context).extension<WorkoutCardOverlayTokens>() ??
        WorkoutCardOverlayTokens.light;
    return tokens.gradient;
  }

  Color _resolveCheckmarkColor(BuildContext context) {
    final dsTokens = Theme.of(context).extension<DsTokens>();
    // successColor from DsTokens (fallback to light theme token)
    return dsTokens?.successColor ?? DsTokens.light.successColor;
  }

  String _buildSemanticsLabel(AppLocalizations l10n) {
    final buffer = StringBuffer()
      ..write(title)
      ..write(', ')
      ..write(subtitle);
    if (dayLabel != null && dayLabel!.isNotEmpty) {
      buffer
        ..write(', ')
        ..write(dayLabel);
    }
    if (duration != null && duration!.isNotEmpty) {
      buffer
        ..write(', ')
        ..write(duration);
    }
    if (isCompleted) {
      buffer
        ..write(', ')
        ..write(l10n.trainingCompleted);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final borderRadius = _resolveRadius(context);
    final shadow = _resolveShadow(context);
    final checkmarkColor = _resolveCheckmarkColor(context);
    final titleStyle = _titleStyle(context);
    final subtitleStyle = _subtitleStyle(context);
    final detailStyle = _detailStyle(context);
    final width = _resolveWidth(context);
    final overlayGradient = _overlayGradient(context);

    return Semantics(
      container: true,
      button: onTap != null,
      label: _buildSemanticsLabel(l10n),
      child: Material(
        color: DsColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            width: width,
            height: _cardHeight,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [shadow],
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: Assets.defaultImageErrorBuilder,
                  ),
                  Container(
                    decoration: BoxDecoration(gradient: overlayGradient),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(_contentPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: Sizes.trainingCardTitleHeight,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                style: titleStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.xs),
                          SizedBox(
                            height: Spacing.l,
                            child: dayLabel != null && dayLabel!.isNotEmpty
                                ? Center(
                                    child: Text(
                                      dayLabel!,
                                      style: detailStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (duration != null && duration!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: _metadataGap),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color:
                                          detailStyle.color ??
                                          DsColors.white.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: Spacing.xxs),
                                    Text(duration!, style: detailStyle),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      top: _checkmarkPadding,
                      left: _checkmarkPadding,
                      child: Container(
                        width: _checkmarkSize,
                        height: _checkmarkSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: checkmarkColor,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: DsColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
