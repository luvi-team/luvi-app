import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/heute_fixtures.dart';
import 'package:luvi_app/features/screens/heute_vm.dart';
import 'package:luvi_app/features/widgets/category_chip.dart';
import 'package:luvi_app/features/widgets/bottom_nav_dock.dart';
import 'package:luvi_app/features/widgets/floating_sync_button.dart';
import 'package:luvi_app/features/widgets/recommendation_card.dart';
import 'package:luvi_app/features/widgets/section_header.dart';
import 'package:luvi_app/features/widgets/bottom_nav_tokens.dart';
import 'package:luvi_app/features/widgets/hero_sync_preview.dart';
import 'package:luvi_app/features/cycle/domain/week_strip.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/cycle/widgets/cycle_inline_calendar.dart';
import 'package:luvi_app/features/dashboard/widgets/top_recommendation_tile.dart';
import 'package:luvi_app/features/dashboard/widgets/stats_scroller.dart';
import 'package:luvi_app/features/dashboard/widgets/cycle_tip_card.dart';

// Dashboard-only spacing (audit-backed)
// from DASHBOARD_spec.json $.heroCard.autoLayout.padding (21px)
const double _pad21 = 21.0;
// from DASHBOARD_spec_deltas.json $.deltas[9].newValue (15px)
// ignore: unused_element
const double _gap15 = 15.0; // legacy (kept for reference)
const double _gap16 = 16.0; // Spec: recommendations list gap 16px
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
// from DASHBOARD_spec.json $.heroCard.progress.outerSize (59.92px)
const double _heroProgressOuterSize = 59.92;
const double _heroProgressFontSize =
    16.12; // TODO(audit): visual fine-tune -1px; spec=17.12 from DASHBOARD_spec.json $.heroCard.progressPercentage.typography.size
// from DASHBOARD_spec.json heroCard.progress positioning (title.x - (progress.x + outerSize) ≈ 12.84px)
const double _heroProgressGap = 12.84;
// TODO(audit: hero icon-text gap missing; using DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[6].value (14px) until verified)
const double _heroIconTextGap = 14.0;
const double _heroCtaWidth =
    291.05; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.heroCard.cta.style.width
const double _heroCtaHeight =
    50.51; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.heroCard.cta.style.height
const double _heroCtaRadius =
    17.12; // from docs/product/measures/dashboard/DASHBOARD_spec.json $.heroCard.cta.style.radius.all
const double _heroCtaHorizontalPadding =
    12.0; // from docs/audits/ONB_07_measures.json $.cta.padding.horizontal
const double _heroCtaVerticalPadding =
    12.0; // TODO(audit): onboarding CTA padding top=11 bottom=12; using 12 for symmetry from docs/audits/ONB_07_measures.json $.cta.padding.bottom
const double _kMinBottomGap = 62.0; // increased breathing room above dock
const double _sectionGapTight =
    20.0; // tighter spacing between stacked sections

// Kodex: Bottom-nav geometry now imported from bottom_nav_tokens.dart (formula-based, no duplication)
// - dockHeight, buttonDiameter, cutoutDepth, desiredGapToWaveTop, syncButtonBottom all from tokens
/// Heute screen: 1:1 Figma implementation (audit-backed, static UI).
class HeuteScreen extends StatefulWidget {
  static const String routeName = '/heute';

  const HeuteScreen({super.key});

  @override
  State<HeuteScreen> createState() => _HeuteScreenState();
}

class _HeuteScreenState extends State<HeuteScreen> {
  late final HeuteFixtureState _fixtureState;
  late String _selectedCategory;
  int _activeTabIndex =
      0; // Dock nav state (0=Heute, 1=Zyklus, 2=Puls, 3=Profil)

  @override
  void initState() {
    super.initState();
    _fixtureState = HeuteFixtures.defaultState();
    _selectedCategory = _fixtureState.categories
        .firstWhere(
          (cat) => cat.isSelected,
          orElse: () => _fixtureState.categories.first,
        )
        .label;
  }

  @override
  Widget build(BuildContext context) {
    // Use default fixture state (can be parameterized later)
    final state = _fixtureState;
    final weekView = weekViewFor(state.referenceDate, state.cycleInfo);
    final topRecommendation = state.topRecommendation;
    final currentPhase = state.cycleInfo.phaseFor(state.referenceDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: _buildDockNavigation(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: Spacing.m,
                    ), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[8].value (16px)
                    _buildHeader(
                      state.header,
                      state.bottomNav.hasNotifications,
                      weekView,
                    ),
                    const SizedBox(height: _sectionGapTight),
                    // Hero Sync Preview (image + badge + info card)
                    HeroSyncPreview(
                      key: const Key('dashboard_hero_sync_preview'),
                      imagePath: Assets.images.heroSync01,
                      badgeAssetPath: Assets.icons.syncBadge,
                      dateText: state.heroCard.dateText,
                      subtitle: state.heroCard.subtitle,
                    ),
                    const SizedBox(height: _sectionGapTight),
                    const SectionHeader(title: 'Kategorien', showTrailingAction: false),
                    const SizedBox(
                      height: Spacing.s,
                    ), // Figma: header→content 12px (Audit V3)
                    _buildCategories(state.categories),
                    const SizedBox(height: Spacing.m),
                    // Section header: Deine Top-Empfehlung
                    const SectionHeader(title: 'Deine Top-Empfehlung', showTrailingAction: false),
                    const SizedBox(height: Spacing.s),
                    // Top recommendation tile
                    TopRecommendationTile(
                      workoutId: topRecommendation.id,
                      tag: topRecommendation.tag,
                      title: topRecommendation.title,
                      imagePath: topRecommendation.imagePath,
                      badgeAssetPath: topRecommendation.badgeAssetPath,
                      fromLuviSync: topRecommendation.fromLuviSync,
                      duration: topRecommendation.duration,
                    ),
                    const SizedBox(height: _sectionGapTight),
                    const SectionHeader(
                      title: 'Weitere Trainings',
                      trailingLabel: 'Alle',
                    ),
                    const SizedBox(
                      height: Spacing.s,
                    ), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[6].value (12px)
                    _buildRecommendations(state.recommendations),
                    const SizedBox(height: _sectionGapTight),
                    const SectionHeader(
                      title: 'Deine Trainingsdaten',
                      showTrailingAction: false,
                    ),
                    const SizedBox(height: Spacing.s),
                    StatsScroller(
                      trainingStats: state.trainingStats,
                      isWearableConnected: state.wearable.connected,
                    ),
                    const SizedBox(height: Spacing.m),
                    CycleTipCard(phase: currentPhase),
                    const SizedBox(height: _kMinBottomGap),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    HeaderProps header,
    bool hasNotifications,
    WeekStripView weekView,
  ) {
    return Column(
      key: const Key('dashboard_header'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(
                    height: 2,
                  ), // from DASHBOARD_spec.json $.spacingTokensObserved[1]
                  // from DASHBOARD_spec.json $.header.subtitle.typography (Figtree 16/24)
                  Text(
                    header.phaseLabel,
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
        const SizedBox(height: Spacing.m),
        CycleInlineCalendar(view: weekView),
      ],
    );
  }

  Widget _buildHeaderIcon(String assetPath) {
    // from DASHBOARD_spec.json $.header.actions[0].container (40×40, radius 26.667)
    return Container(
      width: 40,
      height: 40,
      // Container 40x40, padding 10→8: eff 24x24 (H1 audit)
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_headerIconRadius),
        border: Border.all(
          color: Color(0xFFFFFFFF).withOpacity(0.08),
          width:
              0.769, // from DASHBOARD_spec.json $.header.actions[0].container.border.width
        ),
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 24, // Spec 20px → +4px tuning (Figma parity)
        height: 24, // Spec 20px → +4px tuning (Figma parity)
      ),
    );
  }

  // ignore: unused_element
  Widget _buildHeroCard(HeroCardProps hero, HeroCtaState heroCta) {
    final ctaLabel = _resolveHeroCtaLabel(heroCta);

    return Container(
      key: const Key('dashboard_hero_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(
        _pad21,
      ), // from DASHBOARD_spec.json $.heroCard.autoLayout.padding
      decoration: BoxDecoration(
        // from DASHBOARD_spec.json $.heroCard.container.bg.hex
        color: const Color(0xFFCCB2F4),
        borderRadius: BorderRadius.circular(_heroCardRadius),
        // from DASHBOARD_spec.json $.heroCard.container.stroke
        border: Border.all(
          color: const Color(0xFF696969),
          width:
              1, // from DASHBOARD_spec.json $.heroCard.container.stroke.width
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
                        fontFamily:
                            'Urbanist', // TODO(font): non-brand; not in pubspec → runtime fallback expected
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
        final contentWidth =
            constraints.maxWidth; // from layout: content width nach Padding
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
        final gap = rawGap
            .clamp(_categoriesMinGap, _categoriesMaxGap)
            .toDouble();

        return Wrap(
          key: const Key('dashboard_categories_grid'),
          spacing: columnCount > 1 ? gap : 0,
          runSpacing:
              8, // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[4].value (8px rows)
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
        height:
            180, // from DASHBOARD_spec.json $.recommendations.list.itemSize.h (placeholder uses same height)
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
        separatorBuilder: (context, index) => const SizedBox(width: _gap16),
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          return RecommendationCard(
            imagePath: rec.imagePath,
            tag: rec.tag,
            title: rec.title,
            showTag: false,
          );
        },
      ),
    );
  }

  Widget _buildDockNavigation() {
    final tabs = [
      DockTab(
        iconPath: Assets.icons.navToday,
        label: 'Heute',
        key: const Key('nav_today'),
      ),
      DockTab(
        iconPath: Assets.icons.navCycle,
        label: 'Zyklus',
        key: const Key('nav_cycle'),
      ),
      DockTab(
        iconPath: Assets.icons.navPulse,
        label: 'Puls',
        key: const Key('nav_pulse'),
      ),
      DockTab(
        iconPath: Assets.icons.navProfile,
        label: 'Profil',
        key: const Key('nav_profile'),
      ),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dock bar with violet wave top-border (white bg, shadow)
        BottomNavDock(
          key: const Key('dashboard_dock_nav'),
          activeIndex: _activeTabIndex == 4
              ? -1
              : _activeTabIndex, // When sync active (4), no dock tab is selected
          onTabTap: (index) {
            setState(() {
              _activeTabIndex = index;
            });
          },
          tabs: tabs,
          // Kodex: height from tokens (96px, formula-based)
        ),
        // Floating sync button above center (index 4)
        Positioned(
          bottom:
              syncButtonBottom, // Kodex: Formula from tokens = 96 - 38 - 9 = 49px
          left: 0,
          right: 0,
          child: Center(
            child: FloatingSyncButton(
              key: const Key('floating_sync_button'),
              iconPath: Assets.icons.navSync,
              // Kodex: size and iconSize from tokens (64px, 42px)
              // Current SVG has 3px padding (26/32 glyph). Compensate to keep 65% fill.
              iconTight: false,
              isActive: _activeTabIndex == 4, // Gold tint when sync is active
              onTap: () {
                setState(() {
                  _activeTabIndex = 4; // Sync tab index
                });
                // TODO: sync action
              },
            ),
          ),
        ),
      ],
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
