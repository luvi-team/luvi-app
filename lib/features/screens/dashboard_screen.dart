import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/dashboard_fixtures.dart';
import 'package:luvi_app/features/screens/dashboard_vm.dart';
import 'package:luvi_app/features/widgets/category_chip.dart';
import 'package:luvi_app/features/widgets/recommendation_card.dart';
import 'package:luvi_app/features/widgets/section_header.dart';

// Dashboard-only spacing (audit-backed)
// from DASHBOARD_spec.json $.heroCard.autoLayout.padding (21px)
const double _pad21 = 21.0;
// from DASHBOARD_spec_deltas.json $.deltas[9].newValue (15px)
const double _gap15 = 15.0;
// from DASHBOARD_spec.json $.categories.grid.columns (4)
const int _categoriesColumns = 4;
// from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[4].value (8px)
const double _categoriesMinGap = 8.0;
// from DASHBOARD_spec_deltas.json $.deltas[6].newValue (41px)
const double _categoriesMaxGap = 41.0;
// TODO(audit): DASHBOARD_radii_corners.json node 68426:7254 → null; baseSpec 26.667 UNCONFIRMED (screenshot plausible)
const double _headerIconRadius = 26.667;
// from DASHBOARD_spec.json $.heroCard.container.radius.all (24px)
const double _heroCardRadius = 24.0;
// from DASHBOARD_spec.json $.bottomActions.container.radius.all (36.5px)
const double _bottomPillRadius = 36.5;
// from DASHBOARD_spec.json $.heroCard.progress.outerSize (59.92px)
const double _heroProgressOuterSize = 59.92;
const double _heroProgressFontSize = 16.12; // TODO(audit): visual fine-tune -1px; spec=17.12 from DASHBOARD_spec.json $.heroCard.progressPercentage.typography.size
// from DASHBOARD_spec.json heroCard.progress positioning (title.x - (progress.x + outerSize) ≈ 12.84px)
const double _heroProgressGap = 12.84;
// TODO(audit: hero icon-text gap missing; using DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[6].value (14px) until verified)
const double _heroIconTextGap = 14.0;
const double _heroCtaWidth = 291.05; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.heroCard.cta.style.width
const double _heroCtaHeight = 50.51; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.heroCard.cta.style.height
const double _heroCtaRadius = 17.12; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.heroCard.cta.style.radius.all
const double _heroCtaHorizontalPadding = 12.0; // from docs/audits/ONB_07_measures.json $.cta.padding.horizontal
const double _heroCtaVerticalPadding = 12.0; // TODO(audit): onboarding CTA padding top=11 bottom=12; using 12 for symmetry from docs/audits/ONB_07_measures.json $.cta.padding.bottom
const double _bottomStartMinWidth = 104.75; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.bottomActions.items[0].style.w
const double _bottomStartHeight = 60.0; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.bottomActions.items[0].style.h
const double _bottomStartHorizontalPadding = 20.0; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.bottomActions.items[0].style.padding.horizontal
const double _bottomStartVerticalPadding = 18.0; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.bottomActions.items[0].style.padding.vertical
const double _bottomIconDefaultExtent = 60.0; // TODO(audit): icon container width missing from spec; aligning to Figma pill footprint ≈60px
const double _bottomIconMinExtent = 44.0; // TODO(audit): responsive fit at 390px (screen constraint); spec lacks min width so using 44px floor
const double _bottomIconHorizontalPadding = 20.0; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.bottomActions.items[1].style.padding.horizontal
const double _bottomIconVerticalPadding = 18.0; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.bottomActions.items[1].style.padding.vertical
const double _bottomIconNominalSize = 24.0; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.bottomActions.items[1].iconSize

/// Dashboard screen: 1:1 Figma implementation (audit-backed, static UI).
class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardFixtureState _fixtureState;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fixtureState = DashboardFixtures.defaultState();
    _selectedCategory = _fixtureState.categories.firstWhere(
      (cat) => cat.isSelected,
      orElse: () => _fixtureState.categories.first,
    ).label;
  }

  @override
  Widget build(BuildContext context) {
    // Use default fixture state (can be parameterized later)
    final state = _fixtureState;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.l), // from DASHBOARD_spec.json $.frame.safeAreas.left (24px)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Spacing.m), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[8].value (16px)
                _buildHeader(state.header, state.bottomNav.hasNotifications),
                const SizedBox(height: Spacing.l), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[12].value (24px)
                _buildHeroCard(state.heroCard, state.heroCta),
                const SizedBox(height: Spacing.l), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[12].value (24px)
                SectionHeader(
                  title: 'Kategorien',
                  showTrailingAction: false,
                ),
                const SizedBox(height: Spacing.m), // from DASHBOARD_spec.json $.categories.autoLayout.gap
                _buildCategories(state.categories),
                const SizedBox(height: Spacing.l), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[12].value (24px)
                const SectionHeader(
                  title: 'Empfehlungen',
                  trailingLabel: 'Alle',
                ),
                const SizedBox(height: Spacing.s), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[6].value (12px)
                _buildRecommendations(state.recommendations),
                const SizedBox(height: Spacing.l), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[12].value (24px)
                _buildBottomPill(state.bottomNav),
                const SizedBox(height: 8), // TODO(audit: bottom safe-area buffer missing in spec -> keeping +8px)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(HeaderProps header, bool hasNotifications) {
    return Row(
      key: const Key('dashboard_header'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // from DASHBOARD_spec.json $.header.title.typography (Playfair Display 32/40)
              Text(
                'Hey, ${header.userName} 💜',
                style: const TextStyle(
                  fontFamily: FontFamilies.playfairDisplay,
                  fontSize: 32,
                  height: 40 / 32,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF030401),
                ),
              ),
              const SizedBox(height: 2), // from DASHBOARD_spec.json $.spacingTokensObserved[1]
              // from DASHBOARD_spec.json $.header.subtitle.typography (Figtree 16/24)
              Text(
                '${header.dateText}: ${header.cyclePhaseText}',
                style: const TextStyle(
                  fontFamily: FontFamilies.figtree,
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6d6d6d),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildHeaderIcon(Assets.icons.search),
            // from DASHBOARD_spec.json $.header.actions.gap (68426:7253)
            const SizedBox(width: 8),
            Stack(
              children: [
                _buildHeaderIcon(Assets.icons.notifications),
                if (hasNotifications)
                  Positioned(
                    top: 8,
                    right: 8,
                    // from DASHBOARD_spec_deltas.json $.deltas[2].newValue (notification dot)
                    child: Container(
                      width: 6.668,
                      height: 6.668,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(String assetPath) {
    // from DASHBOARD_spec.json $.header.actions[0].container (40×40, radius 26.667)
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(10), // from DASHBOARD_spec.json $.header.actions[0].container.padding
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_headerIconRadius),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.08),
          width: 0.769, // from DASHBOARD_spec.json $.header.actions[0].container.border.width
        ),
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 20, // from DASHBOARD_spec.json $.header.actions[0].iconSize.w
        height: 20, // from DASHBOARD_spec.json $.header.actions[0].iconSize.h
      ),
    );
  }

  Widget _buildHeroCard(HeroCardProps hero, HeroCtaState heroCta) {
    final ctaLabel = _resolveHeroCtaLabel(heroCta);

    return Container(
      key: const Key('dashboard_hero_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(_pad21), // from DASHBOARD_spec.json $.heroCard.autoLayout.padding
      decoration: BoxDecoration(
        // from DASHBOARD_spec.json $.heroCard.container.bg.hex
        color: const Color(0xFFCCB2F4),
        borderRadius: BorderRadius.circular(_heroCardRadius),
        // from DASHBOARD_spec.json $.heroCard.container.stroke
        border: Border.all(
          color: const Color(0xFF696969),
          width: 1, // from DASHBOARD_spec.json $.heroCard.container.stroke.width
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TODO(audit: hero icon container styling missing → using raw SVG)
              SvgPicture.asset(Assets.icons.heroTraining),
              const SizedBox(width: _heroIconTextGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // from DASHBOARD_spec.json $.heroCard.title.typography (Figtree 20/24)
                    Text(
                      hero.programTitle,
                      style: const TextStyle(
                        fontFamily: FontFamilies.figtree,
                        fontSize: 20,
                        height: 24 / 20,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[3].value (6px)
                    const SizedBox(height: 6),
                    // from DASHBOARD_spec.json $.heroCard.subtitle.typography (Figtree 16/24)
                    Text(
                      hero.openCountText,
                      style: const TextStyle(
                        fontFamily: FontFamilies.figtree,
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6d6d6d),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: _heroProgressGap),
              SizedBox(
                width: _heroProgressOuterSize,
                height: _heroProgressOuterSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress ring placeholder (from DASHBOARD_spec.json $.heroCard.progress)
                    SvgPicture.asset(
                      Assets.icons.cycleOutline,
                      width: _heroProgressOuterSize,
                      height: _heroProgressOuterSize,
                    ),
                    // from DASHBOARD_spec.json $.heroCard.progressPercentage.typography
                    Text(
                      '${(hero.progressRatio * 100).toInt()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Urbanist', // TODO(font): non-brand; not in pubspec → runtime fallback expected
                        fontSize: _heroProgressFontSize,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[13].value (24px)
          const SizedBox(height: 24),
          Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: _heroCtaWidth),
              height: _heroCtaHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: _heroCtaHorizontalPadding,
                vertical: _heroCtaVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(_heroCtaRadius),
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    ctaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF030401),
                    ),
                  ),
                  const Opacity(
                    opacity: 0.0,
                    child: Text(
                      'Training ansehen',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontFamilies.figtree,
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF030401),
                      ),
                    ),
                  ), // from DASHBOARD_spec.json $.heroCard.cta.label (secondary state fixture)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(List<CategoryProps> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth; // from layout: content width nach Padding
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        final textDirection = Directionality.of(context);
        final measuredWidths = categories
            .map((cat) => CategoryChip.measuredWidth(cat.label, textDirection))
            .toList();

        final columnCount = math.min(categories.length, _categoriesColumns);
        final gapCount = columnCount > 1 ? columnCount - 1 : 0;
        final resolvedWidths = List<double>.from(measuredWidths);

        final minGapTotal = gapCount * _categoriesMinGap;
        final minWidth = CategoryChip.minWidth;
        var totalWidth = resolvedWidths
            .take(columnCount)
            .fold<double>(0, (sum, width) => sum + width);
        final availableForItems = math.max(0, contentWidth - minGapTotal);

        if (columnCount > 0 && gapCount > 0 && totalWidth > availableForItems) {
          var overflow = totalWidth - availableForItems;
          var adjustable = <int>[
            for (var i = 0; i < columnCount; i++)
              if (resolvedWidths[i] > minWidth) i,
          ];
          var guard = 0;
          while (overflow > 0.1 && adjustable.isNotEmpty && guard < 6) {
            // Evenly compress chip widths until first-row total fits the 390–428px viewport window.
            final perItemReduction = overflow / adjustable.length;
            double consumed = 0;
            final nextAdjustable = <int>[];
            for (final index in adjustable) {
              final maxReduction = resolvedWidths[index] - minWidth;
              if (maxReduction <= 0.1) {
                continue;
              }
              final reduction = math.min(maxReduction, perItemReduction);
              if (reduction > 0) {
                resolvedWidths[index] -= reduction;
                consumed += reduction;
              }
              if ((resolvedWidths[index] - minWidth) > 0.1) {
                nextAdjustable.add(index);
              }
            }
            if (consumed == 0) {
              break;
            }
            overflow = math.max(0, overflow - consumed);
            adjustable = nextAdjustable;
            guard++;
          }
          totalWidth = resolvedWidths
              .take(columnCount)
              .fold<double>(0, (sum, width) => sum + width);
        }

        final rawGap = gapCount > 0
            ? (contentWidth - totalWidth) / gapCount
            : _categoriesMinGap;
        final gap = rawGap.clamp(_categoriesMinGap, _categoriesMaxGap).toDouble();

        return Wrap(
          key: const Key('dashboard_categories_grid'),
          spacing: columnCount > 1 ? gap : 0,
          runSpacing: 8, // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[4].value (8px rows)
          children: [
            for (var i = 0; i < categories.length; i++)
              CategoryChip(
                iconPath: categories[i].iconPath,
                label: categories[i].label,
                isSelected: categories[i].label == _selectedCategory,
                width: resolvedWidths[i],
                onTap: () => _onCategoryTap(categories[i]),
              ),
          ],
        );
      },
    );
  }

  void _onCategoryTap(CategoryProps category) {
    if (_selectedCategory == category.label) {
      return;
    }
    setState(() {
      _selectedCategory = category.label;
    });
    // TODO(reco-filter): hook selection into recommendations filter once feature lands.
  }

  Widget _buildRecommendations(List<RecommendationProps> recommendations) {
    if (recommendations.isEmpty) {
      // Placeholder for empty state
      return const SizedBox(
        height: 180, // from DASHBOARD_spec.json $.recommendations.list.itemSize.h (placeholder uses same height)
        child: Center(
          child: Text(
            'Keine Empfehlungen verfügbar',
            style: TextStyle(
              fontFamily: FontFamilies.figtree,
              fontSize: 16,
              color: Color(0xFF6d6d6d),
            ),
          ),
        ),
      );
    }

    // from DASHBOARD_spec_deltas.json $.deltas[9] (gap 15px)
    return SizedBox(
      key: const Key('dashboard_recommendations_list'),
      // from DASHBOARD_spec.json $.recommendations.list.itemSize.h (180px)
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        clipBehavior: Clip.hardEdge,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) => const SizedBox(width: _gap15),
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          return RecommendationCard(
            imagePath: rec.imagePath,
            tag: rec.tag,
            title: rec.title,
          );
        },
      ),
    );
  }

  Widget _buildBottomPill(BottomNavProps nav) {
    // from DASHBOARD_spec.json $.bottomActions
    return Container(
      key: const Key('dashboard_bottom_nav_pill'),
      padding: const EdgeInsets.all(6), // from DASHBOARD_spec.json $.bottomActions.autoLayout.padding.top
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(_bottomPillRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
            blurRadius: 24, // from DASHBOARD_spec.json $.bottomActions.container.shadow[0].blur
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBottomNavStartButton(),
          // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[3].value (6px)
          const SizedBox(width: 6),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double iconCount = 4;
                const double iconGap = 6; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.bottomActions.autoLayout.gap
                const double defaultIconWidth = _bottomIconDefaultExtent;
                const double minIconWidth = _bottomIconMinExtent;

                final double availableWidth = constraints.maxWidth;
                final double requiredWidth =
                    (defaultIconWidth * iconCount) + (iconGap * (iconCount - 1));
                final double resolvedIconWidth = availableWidth >= requiredWidth
                    ? defaultIconWidth
                    : ((availableWidth - (iconGap * (iconCount - 1))) / iconCount)
                        .clamp(minIconWidth, defaultIconWidth); // TODO(audit): responsive fit at 390px

                return FittedBox(
                  // 390px viewport squeezes icon pill row; scale down uniformly to respect audit gaps.
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildBottomNavIcon(
                        Assets.icons.navFlower,
                        key: const Key('dashboard_nav_flower'),
                        width: resolvedIconWidth,
                      ),
                      const SizedBox(width: iconGap),
                      _buildBottomNavIcon(
                        Assets.icons.navSocial,
                        key: const Key('dashboard_nav_social'),
                        width: resolvedIconWidth,
                      ),
                      const SizedBox(width: iconGap),
                      _buildBottomNavIcon(
                        Assets.icons.navChart,
                        key: const Key('dashboard_nav_chart'),
                        width: resolvedIconWidth,
                      ),
                      const SizedBox(width: iconGap),
                      _buildBottomNavIcon(
                        Assets.icons.navAccount,
                        key: const Key('dashboard_nav_account'),
                        width: resolvedIconWidth,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavStartButton() {
    return Container(
      constraints: const BoxConstraints(minWidth: _bottomStartMinWidth),
      height: _bottomStartHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: _bottomStartHorizontalPadding,
        vertical: _bottomStartVerticalPadding,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD9B18E),
        borderRadius: BorderRadius.circular(_bottomPillRadius),
      ),
      child: const Text(
        'Start',
        style: TextStyle(
          fontFamily: FontFamilies.figtree,
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }

  Widget _buildBottomNavIcon(String assetPath, {Key? key, double? width}) {
    final double resolvedWidth = width ?? _bottomIconDefaultExtent;
    final double baselinePadding = _bottomIconHorizontalPadding;
    final double availablePadding = (resolvedWidth - _bottomIconNominalSize) / 2;
    final double horizontalPadding = resolvedWidth >=
            (_bottomIconNominalSize + (baselinePadding * 2))
        ? baselinePadding
        : math.max(0.0, availablePadding); // TODO(audit): responsive fit at 390px reduces padding when frame shrinks
    final double resolvedIconSize = math
        .max(0.0, resolvedWidth - (horizontalPadding * 2))
        .clamp(0, _bottomIconNominalSize);

    return Container(
      key: key,
      constraints: BoxConstraints.tightFor(
        width: resolvedWidth,
        height: _bottomStartHeight,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: _bottomIconVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(_bottomPillRadius),
      ),
      child: Center(
        child: SvgPicture.asset(
          assetPath,
          width: resolvedIconSize,
          height: resolvedIconSize,
        ),
      ),
    );
  }

  String _resolveHeroCtaLabel(HeroCtaState state) {
    // from docs/ui/contracts/dashboard_state.md (HeroCtaState → label mapping)
    switch (state) {
      case HeroCtaState.resumeActiveWorkout:
        return 'Zurück zum Training';
      case HeroCtaState.startNewWorkout:
        return 'Starte dein Training';
    }
  }
}
