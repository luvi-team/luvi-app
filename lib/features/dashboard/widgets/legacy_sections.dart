import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/dashboard/data/props/heute_fixtures.dart';
import 'package:luvi_app/features/dashboard/domain/models/category.dart';
import 'package:luvi_app/features/dashboard/domain/models/recommendation.dart';
import 'package:luvi_app/features/dashboard/domain/top_recommendation_props.dart';
import 'package:luvi_app/features/dashboard/domain/training_stat_props.dart';
import 'package:luvi_app/features/dashboard/widgets/cycle_tip_card.dart';
import 'package:luvi_app/features/dashboard/widgets/stats_scroller.dart';
import 'package:luvi_app/features/dashboard/widgets/top_recommendation_tile.dart';
import 'package:luvi_app/features/dashboard/utils/heute_layout_utils.dart';
import 'package:luvi_app/features/dashboard/widgets/category_chip.dart';
import 'package:luvi_app/features/dashboard/widgets/recommendation_card.dart';
import 'package:luvi_app/features/dashboard/widgets/section_header.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class LegacySections extends StatefulWidget {
  const LegacySections({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.topRecommendation,
    required this.recommendations,
    required this.trainingStats,
    required this.isWearableConnected,
    required this.currentPhase,
  });

  final List<CategoryProps> categories;
  final Category selectedCategory;
  final void Function(Category category) onCategoryTap;
  final TopRecommendationProps topRecommendation;
  final List<Recommendation> recommendations;
  final List<TrainingStatProps> trainingStats;
  final bool isWearableConnected;
  final Phase currentPhase;

  @override
  State<LegacySections> createState() => _LegacySectionsState();
}

class _LegacySectionsState extends State<LegacySections> {
  final Map<String, double> _categoryWidthCache = {};

  @override
  void didUpdateWidget(covariant LegacySections oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _categoryWidthCache.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    assert(l10n != null, 'AppLocalizations must be initialized');
    if (l10n == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.dashboardCategoriesTitle,
          showTrailingAction: false,
        ),
        const SizedBox(height: Spacing.s),
        _buildCategories(context, l10n),
        const SizedBox(height: Spacing.m),
        SectionHeader(
          title: l10n.dashboardTopRecommendationTitle,
          showTrailingAction: false,
        ),
        const SizedBox(height: Spacing.s),
        TopRecommendationTile(
          workoutId: widget.topRecommendation.id,
          tag: widget.topRecommendation.tag,
          title: widget.topRecommendation.title,
          imagePath: widget.topRecommendation.imagePath,
          badgeAssetPath: widget.topRecommendation.badgeAssetPath,
          fromLuviSync: widget.topRecommendation.fromLuviSync,
          duration: widget.topRecommendation.duration,
        ),
        const SizedBox(height: _sectionGapTight),
        SectionHeader(title: l10n.dashboardMoreTrainingsTitle),
        const SizedBox(height: Spacing.s),
        _buildRecommendations(context, l10n),
        const SizedBox(height: _sectionGapTight),
        SectionHeader(
          title: l10n.dashboardTrainingDataTitle,
          showTrailingAction: false,
        ),
        const SizedBox(height: Spacing.s),
        StatsScroller(
          key: const Key('dashboard_training_stats_scroller'),
          trainingStats: widget.trainingStats,
          isWearableConnected: widget.isWearableConnected,
        ),
        const SizedBox(height: Spacing.m),
        CycleTipCard(phase: widget.currentPhase),
      ],
    );
  }

  Widget _buildCategories(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;
        if (widget.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        final textDirection = Directionality.of(context);
        final labels = [
          for (final category in widget.categories)
            _categoryLabel(l10n, category.category),
        ];
        final measuredWidths = _measureChipWidths(labels, textDirection);
        final columnCount =
            math.min(widget.categories.length, _categoriesColumns);
        final resolvedWidths = compressFirstRowWidths(
          measured: measuredWidths,
          contentWidth: contentWidth,
          columnCount: columnCount,
          minGap: _categoriesMinGap,
          minWidth: CategoryChip.minWidth,
        );
        assert(
          resolvedWidths.length >= labels.length,
          'compressFirstRowWidths returned ${resolvedWidths.length} widths '
          'for ${labels.length} category labels.',
        );
        final gapCount = columnCount > 1 ? columnCount - 1 : 0;
        final totalWidth = resolvedWidths
            .take(columnCount)
            .fold<double>(0, (sum, width) => sum + width);
        final rawGap = gapCount > 0
            ? (contentWidth - totalWidth) / gapCount
            : _categoriesMinGap;
        final gap = rawGap
            .clamp(_categoriesMinGap, _categoriesMaxGap)
            .toDouble();

        return _buildCategoryWrap(labels, resolvedWidths, gap);
      },
    );
  }

  List<double> _measureChipWidths(List<String> labels, TextDirection dir) {
    return [for (final label in labels) _measureWidth(label, dir)];
  }

  double _measureWidth(String label, TextDirection dir) {
    final cacheKey = '${dir.name}|$label';
    final cached = _categoryWidthCache[cacheKey];
    if (cached != null) {
      return cached;
    }
    final width = CategoryChip.measuredWidth(label, dir);
    _categoryWidthCache[cacheKey] = width;
    return width;
  }

  Widget _buildCategoryWrap(
    List<String> labels,
    List<double> resolvedWidths,
    double gap,
  ) {
    assert(
      resolvedWidths.length >= labels.length,
      'Resolved widths (${resolvedWidths.length}) are fewer than labels (${labels.length}).',
    );
    final columnCount =
        math.min(widget.categories.length, _categoriesColumns);
    return Wrap(
      key: const Key('dashboard_categories_grid'),
      spacing: columnCount > 1 ? gap : 0,
      runSpacing: 8,
      children: [
        for (var i = 0; i < widget.categories.length; i++)
          CategoryChip(
            key: ValueKey(widget.categories[i].category),
            iconPath: widget.categories[i].iconPath,
            label: labels[i],
            isSelected:
                widget.categories[i].category == widget.selectedCategory,
            width: resolvedWidths[i],
            onTap: () => widget.onCategoryTap(widget.categories[i].category),
          ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, AppLocalizations l10n) {
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    if (widget.recommendations.isEmpty) {
      final emptyTextColor =
          textTokens?.secondary ?? ColorTokens.recommendationTag;
      return SizedBox(
        height: Sizes.recommendationListHeight,
        child: Center(
          child: Text(
            l10n.dashboardRecommendationsEmpty,
            style: TextStyle(
              fontFamily: FontFamilies.figtree,
              fontSize: 16,
              color: emptyTextColor,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      key: const Key('dashboard_recommendations_list'),
      height: Sizes.recommendationListHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.recommendations.length,
        clipBehavior: Clip.hardEdge,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) => const SizedBox(width: _gap16),
        itemBuilder: (context, index) {
          final recommendation = widget.recommendations[index];
          return RecommendationCard(
            imagePath: recommendation.imagePath,
            tag: recommendation.tag,
            title: recommendation.title,
            showTag: false,
          );
        },
      ),
    );
  }

  String _categoryLabel(AppLocalizations l10n, Category category) {
    switch (category) {
      case Category.training:
        return l10n.dashboardCategoryTraining;
      case Category.nutrition:
        return l10n.dashboardCategoryNutrition;
      case Category.regeneration:
        return l10n.dashboardCategoryRegeneration;
      case Category.mindfulness:
        return l10n.dashboardCategoryMindfulness;
    }
  }
}

const double _gap16 = 16.0;
const int _categoriesColumns = 4;
const double _categoriesMinGap = 8.0;
const double _categoriesMaxGap = 41.0;
const double _sectionGapTight = 20.0;
