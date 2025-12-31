import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/dashboard/domain/top_recommendation_props.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../../core/design_tokens/assets.dart';
import '../../../core/design_tokens/colors.dart';
import '../../../core/design_tokens/sizes.dart';
import '../../../core/design_tokens/spacing.dart';
import '../../../core/design_tokens/typography.dart';
import '../../../core/navigation/route_paths.dart';
import '../../../core/theme/app_theme.dart';

const double _tileHeight = 150.0; // Figma: 150px
const double _badgeSize = 32.0; // Figma: 32px
const double _badgeOffsetTop = 7.0;
const double _badgeOffsetRight = 12.0;
const double _durationIconSize = 14.0; // Figma: 14×14
const double _durationIconTextGap = 4.0; // Figma: 4px gap

/// Prominent recommendation tile that surfaces one featured workout.
///
/// Use [TopRecommendationProps] to populate this widget from dashboard fixtures.
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

  Widget _buildBadge(BuildContext context) {
    return Positioned(
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
                ColoredBox(color: DsColors.transparent),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayGradient(BuildContext context) {
    final overlayTokens = Theme.of(
      context,
    ).extension<WorkoutCardOverlayTokens>();
    final gradient =
        overlayTokens?.gradient ?? WorkoutCardOverlayTokens.light.gradient;
    return Container(decoration: BoxDecoration(gradient: gradient));
  }

  Widget _buildTitleAndDuration(
    BuildContext context, {
    required String title,
    String? duration,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: 20,
            height: TypographyTokens.lineHeightRatio24on20,
            fontWeight: FontWeight.w600,
            color: DsColors.white,
          ),
        ),
        if (duration != null) ...[
          const SizedBox(height: Spacing.xxs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                Assets.icons.dashboard.time,
                width: _durationIconSize,
                height: _durationIconSize,
                colorFilter: ColorFilter.mode(
                  DsColors.white.withValues(alpha: 0.6),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: _durationIconTextGap),
              Text(
                duration,
                style: TextStyle(
                  fontFamily: FontFamilies.figtree,
                  fontSize: 12,
                  height: 24 / 12,
                  fontWeight: FontWeight.w400,
                  color: DsColors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _buildSemanticsLabel(AppLocalizations l10n) {
    final buffer = StringBuffer()..write('${l10n.topRecommendation} $title. ');
    if (tag.isNotEmpty) {
      buffer.write('${l10n.category} $tag.');
    }
    if (fromLuviSync) {
      buffer.write(' ${l10n.fromLuviSync}.');
    }
    return buffer.toString();
  }

  Widget _buildInkWell(
    BuildContext context,
    BoxShadow tileShadow,
    TextColorTokens? textTokens,
  ) {
    final borderRadius = BorderRadius.circular(Sizes.radiusL);
    return InkWell(
      onTap: () => context.go(RoutePaths.workoutDetail.replaceFirst(':id', workoutId)),
      borderRadius: borderRadius,
      child: Container(
        constraints: const BoxConstraints.tightFor(height: _tileHeight),
        width: double
            .infinity, // Spec width ≈385px; expand to viewport width within padding.
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [tileShadow],
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
              _buildOverlayGradient(context),
              if (fromLuviSync) _buildBadge(context),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.topRecommendationPadH,
                  vertical: Spacing.goalCardVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (tag.isNotEmpty) ...[
                      Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          fontFamily: FontFamilies.figtree,
                          fontSize: 12,
                          height: 18 / 12,
                          letterSpacing: 0.12,
                          fontWeight: FontWeight.w500,
                          color: (textTokens?.muted ?? DsColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: Spacing.xxxs),
                    ],
                    _buildTitleAndDuration(
                      context,
                      title: title,
                      duration: duration,
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

  @override
  Widget build(BuildContext context) {
    final shadowTokens = Theme.of(context).extension<ShadowTokens>();
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    final tileShadow =
        shadowTokens?.tileDrop ??
        BoxShadow(
          color: DsColors.shadowMedium,
          blurRadius: 4,
          offset: const Offset(0, 4),
        );
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      button: true,
      label: _buildSemanticsLabel(l10n),
      hint: l10n.tapToOpenWorkout,
      child: ExcludeSemantics(
        child: Material(
          color: DsColors.transparent,
          child: _buildInkWell(context, tileShadow, textTokens),
        ),
      ),
    );
  }
}
