import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/dashboard_layout_constants.dart';
import 'package:luvi_app/core/design_tokens/divider_tokens.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/domain/models/recommendation.dart';
import 'package:luvi_app/features/dashboard/widgets/painters/wave_painter.dart';
import 'package:luvi_app/features/dashboard/widgets/recommendation_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class PhaseRecommendationsSection extends StatelessWidget {
  const PhaseRecommendationsSection({
    super.key,
    required this.nutritionRecommendations,
    required this.regenerationRecommendations,
  });

  final List<Recommendation> nutritionRecommendations;
  final List<Recommendation> regenerationRecommendations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dsTokens = theme.extension<DsTokens>();
    final dividerTokens = theme.extension<DividerTokens>();
    final waveColor = _phaseWaveBackgroundColor(context);
    final dividerColor =
        dividerTokens?.sectionDividerColor ?? DsColors.divider;
    final dividerThickness = dividerTokens?.sectionDividerThickness ?? 1.0;
    final sectionHeight = _calculatePhaseRecoSectionHeight(dividerThickness);

    return RepaintBoundary(
      child: SizedBox(
        height: sectionHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: WavePainter(
                  color: waveColor,
                  amplitude:
                      DashboardLayoutConstants.phaseRecommendationsWaveAmplitude,
                  background: theme.scaffoldBackgroundColor,
                  flipVertical: true,
                ),
              ),
            ),
            Positioned(
              left: Spacing.l,
              right: Spacing.l,
              top:
                  DashboardLayoutConstants.phaseRecommendationsWaveHeight -
                      DashboardLayoutConstants
                          .phaseRecommendationsWaveAmplitude -
                      Spacing.l,
              child: Container(
                decoration: BoxDecoration(
                  color: dsTokens?.cardSurface ?? DsTokens.light.cardSurface,
                  borderRadius: BorderRadius.circular(Sizes.radiusL),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.s,
                    Spacing.xs,
                    Spacing.s,
                    Spacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardRecommendationsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FontFamilies.figtree,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 24 / 20,
                          color: DsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Divider(
                        color: dividerColor,
                        thickness: dividerThickness,
                        height: dividerThickness,
                      ),
                      const SizedBox(height: Spacing.xs),
                      _buildRecommendationSubsection(
                        context: context,
                        title: l10n.dashboardNutritionTitle,
                        recommendations: nutritionRecommendations,
                        cardWidth: DashboardLayoutConstants
                            .phaseRecommendationsNutritionCardWidth,
                        cardHeight: DashboardLayoutConstants
                            .phaseRecommendationsNutritionCardHeight,
                        semanticPrefix: l10n.nutritionRecommendation,
                      ),
                      const SizedBox(height: Spacing.xs),
                      _buildRecommendationSubsection(
                        context: context,
                        title: l10n.dashboardRegenerationTitle,
                        recommendations: regenerationRecommendations,
                        cardWidth: DashboardLayoutConstants
                            .phaseRecommendationsRegenerationCardWidth,
                        cardHeight: DashboardLayoutConstants
                            .phaseRecommendationsRegenerationCardHeight,
                        semanticPrefix: l10n.regenerationRecommendation,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSubsection({
    required BuildContext context,
    required String title,
    required List<Recommendation> recommendations,
    required double cardWidth,
    required double cardHeight,
    required String semanticPrefix,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const headerTextStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: 20,
      height: 24 / 20,
      fontWeight: FontWeight.w400,
    );

    if (recommendations.isEmpty) {
      final placeholderColor =
          theme.extension<TextColorTokens>()?.secondary ??
          ColorTokens.recommendationTag;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: headerTextStyle),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.dashboardRecommendationsEmpty,
            style: TextStyle(
              fontFamily: FontFamilies.figtree,
              fontSize: 16,
              height: 24 / 16,
              color: placeholderColor,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: headerTextStyle),
        const SizedBox(height: Spacing.xs),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => SizedBox(
              width:
                  DashboardLayoutConstants.phaseRecommendationsCardGap,
            ),
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Semantics(
                label:
                    '$semanticPrefix: ${recommendation.title}${recommendation.subtitle != null ? ', ${recommendation.subtitle}' : ''}',
                child: RecommendationCard(
                  imagePath: recommendation.imagePath,
                  tag: recommendation.tag,
                  title: recommendation.title,
                  subtitle: recommendation.subtitle,
                  showTag: false,
                  width: cardWidth,
                  height: cardHeight,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double _calculatePhaseRecoSectionHeight(double dividerVisualHeight) {
    const framePaddingTop = Spacing.xs;
    const framePaddingBottom = Spacing.xs;
    const headerToDividerGap = Spacing.xs;
    const dividerToFirstSectionGap = Spacing.xs;
    const interSectionGap = Spacing.xs;

    return DashboardLayoutConstants.phaseRecommendationsWaveHeight +
        framePaddingTop +
        framePaddingBottom +
        DashboardLayoutConstants.phaseRecommendationsHeaderHeight +
        headerToDividerGap +
        dividerVisualHeight +
        dividerToFirstSectionGap +
        DashboardLayoutConstants.phaseRecommendationsSubsectionHeaderHeight +
        DashboardLayoutConstants.phaseRecommendationsNutritionCardHeight +
        interSectionGap +
        DashboardLayoutConstants.phaseRecommendationsSubsectionHeaderHeight +
        DashboardLayoutConstants.phaseRecommendationsRegenerationCardHeight;
  }

  Color _phaseWaveBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceTokens = theme.extension<SurfaceColorTokens>();
    if (surfaceTokens != null) {
      return surfaceTokens.waveOverlayBeige;
    }
    return theme.extension<DsTokens>()?.cardSurface ??
        SurfaceColorTokens.light.waveOverlayBeige;
  }
}
