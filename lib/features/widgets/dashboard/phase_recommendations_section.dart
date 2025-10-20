import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/divider_tokens.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/data/fixtures/heute_fixtures.dart';
import 'package:luvi_app/features/widgets/painters/wave_painter.dart';
import 'package:luvi_app/features/widgets/recommendation_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class PhaseRecommendationsSection extends StatelessWidget {
  const PhaseRecommendationsSection({
    super.key,
    required this.nutritionRecommendations,
    required this.regenerationRecommendations,
  });

  final List<RecommendationProps> nutritionRecommendations;
  final List<RecommendationProps> regenerationRecommendations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dsTokens = theme.extension<DsTokens>();
    final dividerTokens = theme.extension<DividerTokens>();
    final waveColor = _phaseWaveBackgroundColor(context);
    final dividerColor =
        dividerTokens?.sectionDividerColor ?? const Color(0xFFDCDCDC);
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
                  amplitude: _phaseRecoWaveAmplitude,
                  background: theme.scaffoldBackgroundColor,
                  flipVertical: true,
                ),
              ),
            ),
            Positioned(
              left: Spacing.l,
              right: Spacing.l,
              top: _phaseRecoWaveHeight - _phaseRecoWaveAmplitude - Spacing.l,
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
                        style: const TextStyle(
                          fontFamily: FontFamilies.figtree,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 24 / 20,
                          color: Color(0xFF030401),
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
                        cardWidth: _nutritionCardWidth,
                        cardHeight: _nutritionCardHeight,
                        semanticPrefix: l10n.nutritionRecommendation,
                      ),
                      const SizedBox(height: Spacing.xs),
                      _buildRecommendationSubsection(
                        context: context,
                        title: l10n.dashboardRegenerationTitle,
                        recommendations: regenerationRecommendations,
                        cardWidth: _regenerationCardWidth,
                        cardHeight: _regenerationCardHeight,
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
    required List<RecommendationProps> recommendations,
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
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) =>
                const SizedBox(width: _phaseRecoCardGap),
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

    return _phaseRecoWaveHeight +
        framePaddingTop +
        framePaddingBottom +
        _phaseRecoHeaderHeight +
        headerToDividerGap +
        dividerVisualHeight +
        dividerToFirstSectionGap +
        _subsectionHeaderHeight +
        _nutritionCardHeight +
        interSectionGap +
        _subsectionHeaderHeight +
        _regenerationCardHeight;
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

const double _phaseRecoWaveHeight = 80.0;
const double _phaseRecoWaveAmplitude = 24.0;
const double _phaseRecoHeaderHeight = 56.0;
const double _phaseRecoCardGap = 16.0;
const double _nutritionCardWidth = 160.0;
const double _nutritionCardHeight = 210.0;
const double _regenerationCardWidth = 165.0;
const double _regenerationCardHeight = 210.0;
const double _subsectionHeaderHeight = 40.0;
