import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart' as dash_assets;
import 'package:luvi_app/core/design_tokens/divider_tokens.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/data/fixtures/heute_fixtures.dart';
import 'package:luvi_app/features/widgets/category_chip.dart';
import 'package:luvi_app/features/widgets/bottom_nav_dock.dart';
import 'package:luvi_app/features/widgets/floating_sync_button.dart';
import 'package:luvi_app/features/widgets/recommendation_card.dart';
import 'package:luvi_app/features/widgets/section_header.dart';
import 'package:luvi_app/features/widgets/bottom_nav_tokens.dart';
import 'package:luvi_app/features/widgets/hero_sync_preview.dart';
import 'package:luvi_app/features/screens/heute_layout_utils.dart';
import 'package:luvi_app/features/cycle/domain/week_strip.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/widgets/dashboard_calendar.dart';
import 'package:luvi_app/features/dashboard/widgets/top_recommendation_tile.dart';
import 'package:luvi_app/features/dashboard/widgets/stats_scroller.dart';
import 'package:luvi_app/features/dashboard/widgets/weekly_training_card.dart';
import 'package:luvi_app/features/dashboard/widgets/cycle_tip_card.dart';
import 'package:luvi_app/features/dashboard/state/heute_vm.dart';
import 'package:luvi_app/features/dashboard/screens/luvi_sync_journal_stub.dart';
import 'package:luvi_app/features/dashboard/domain/weekly_training_props.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

// Dashboard-only spacing (audit-backed)
const double _gap16 = 16.0; // Spec: recommendations list gap 16px
// from DASHBOARD_spec.json $.categories.grid.columns (4)
const int _categoriesColumns = 4;
// from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[4].value (8px)
const double _categoriesMinGap = 8.0;
// from DASHBOARD_spec_deltas.json $.deltas[6].newValue (41px)
const double _categoriesMaxGap = 41.0;
// TODO(audit): DASHBOARD_radii_corners.json node 68426:7254 → null; baseSpec 26.667 UNCONFIRMED (screenshot plausible)
const double _headerIconRadius = 26.667;
const double _sectionGapTight =
    20.0; // tighter spacing between stacked sections
const double _weeklyTrainingCardHeight = 280.0;
const double _weeklyTrainingCardMaxWidth = 340.0;
const double _weeklyTrainingHorizontalInset = 48.0;
const double _weeklyTrainingItemGap = 17.0;
const double _phaseRecoWaveHeight = 60.0; // Beige wave vertical span (reduced from 72.0 per Phase 9 visual tuning)
const double _phaseRecoWaveAmplitude = 24.0; // Height of curved lip
const double _phaseRecoFramePadding =
    20.0; // Frame internal padding (from audit)
const double _phaseRecoHeaderHeight =
    56.0; // Two-line header allowance (20pt type @ 24px line height + 8px cushion)
const double _phaseRecoCardGap = 16.0; // Gap between cards in carousel
const double _nutritionCardWidth = 160.0; // Nutrition card width (from audit)
const double _nutritionCardHeight = 210.0; // Nutrition card height (from audit)
const double _regenerationCardWidth =
    165.0; // Regeneration card width (from audit)
const double _regenerationCardHeight =
    210.0; // Regeneration card height (from audit)
const double _subsectionHeaderHeight = 40.0; // Subsection title + gap
const bool featureDashboardV2 = true;

double _waveBottomRevealFor(BuildContext context, double heroToSectionGap) {
  const double waveAssetWidth = 428.0;
  const double waveArcHeight = 40.0;
  final double viewportWidth = MediaQuery.sizeOf(context).width;
  final double scale = viewportWidth / waveAssetWidth;
  final double reveal = waveArcHeight * scale;
  return math.min(reveal, heroToSectionGap);
}

double _calculatePhaseRecoSectionHeight(double totalDividerSpacing) {
  // Dynamic height calculation for responsive design
  return _phaseRecoWaveHeight +
      (_phaseRecoFramePadding * 2) +
      _phaseRecoHeaderHeight +
      Spacing.m +
      _subsectionHeaderHeight +
      _nutritionCardHeight +
      totalDividerSpacing +
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

// Kodex: Bottom-nav geometry now imported from bottom_nav_tokens.dart (formula-based, no duplication)
// - dockHeight, buttonDiameter, cutoutDepth, desiredGapToWaveTop, syncButtonBottom,
//   calculateBottomPadding() all from tokens
/// Heute screen: 1:1 Figma implementation (audit-backed, static UI).
class HeuteScreen extends StatefulWidget {
  static const String routeName = '/heute';

  const HeuteScreen({super.key});

  @override
  State<HeuteScreen> createState() => _HeuteScreenState();
}

class _HeuteScreenState extends State<HeuteScreen> {
  late final HeuteFixtureState _fixtureState;
  late Category _selectedCategory;
  int _activeTabIndex =
      0; // Dock nav state (0=Heute, 1=Zyklus, 2=Puls, 3=Profil)

  @override
  void initState() {
    super.initState();
    _fixtureState = HeuteFixtures.defaultState();
    _selectedCategory = _fixtureState.selectedCategory;
  }

  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      // Precache the images visible on initial render to avoid first-frame jank.
      final heroImagePath = dash_assets.Assets.images.heroSync01;
      precacheImage(AssetImage(heroImagePath), context);
      precacheImage(AssetImage(dash_assets.Assets.images.strawberry), context);
      precacheImage(AssetImage(dash_assets.Assets.images.roteruebe), context);
      _imagesPrecached = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maybeL10n = AppLocalizations.of(context);
    if (maybeL10n == null) {
      return Localizations.override(
        context: context,
        delegates: AppLocalizations.localizationsDelegates,
        locale: AppLocalizations.supportedLocales.first,
        child: Builder(
          builder: (overrideContext) =>
              _buildLocalizedScaffold(overrideContext),
        ),
      );
    }

    return _buildLocalizedScaffold(context);
  }

  Widget _buildLocalizedScaffold(BuildContext context) {
    // Use default fixture state (can be parameterized later)
    final state = _fixtureState;
    final weekView = weekViewFor(state.referenceDate, state.cycleInfo);
    final topRecommendation = state.topRecommendation;
    final currentPhase = state.cycleInfo.phaseFor(state.referenceDate);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final layout = Theme.of(context).extension<DashboardLayoutTokens>();
    final double heroToSectionGap = layout?.heroToSectionGapPx ?? 42;
    final double bottomReveal = _waveBottomRevealFor(context, heroToSectionGap);
    final double postWaveTopGap = math.max(
      Spacing.xs,
      heroToSectionGap - bottomReveal,
    );
    final Color waveTint = _phaseWaveBackgroundColor(context);
    final Color waveSurface = Color.alphaBlend(waveTint, Colors.white);

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: _buildDockNavigation(l10n),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Spacing.m),
                    _buildHeader(
                      context,
                      l10n,
                      state.header,
                      currentPhase,
                      state.bottomNav.hasNotifications,
                    ),
                    const SizedBox(height: Spacing.m),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildCalendar(weekView)),
            SliverToBoxAdapter(child: _buildWaveOverlay(context, state)),
            if (featureDashboardV2)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: postWaveTopGap),
                    Padding(
                      padding: const EdgeInsets.only(right: Spacing.l),
                      child: _buildWeeklyTrainingSection(
                        context,
                        l10n,
                        state.weeklyTrainings,
                      ),
                    ),
                    const SizedBox(height: _sectionGapTight),
                  ],
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: postWaveTopGap),
                      SectionHeader(
                        title: l10n.dashboardCategoriesTitle,
                        showTrailingAction: false,
                      ),
                      const SizedBox(
                        height: Spacing.s,
                      ), // Figma: header→content 12px (Audit V3)
                      _buildCategories(l10n, state.categories),
                      const SizedBox(height: Spacing.m),
                    ],
                  ),
                ),
              ),
            if (featureDashboardV2)
              SliverToBoxAdapter(
                child: _buildPhaseRecommendationsWaveSection(
                  context,
                  l10n,
                  state.nutritionRecommendations,
                  state.regenerationRecommendations,
                ),
              ),
            SliverToBoxAdapter(
              child: ColoredBox(
                color: waveSurface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!featureDashboardV2) ...[
                        // Section header: Deine Top-Empfehlung
                        SectionHeader(
                          title: l10n.dashboardTopRecommendationTitle,
                          showTrailingAction: false,
                        ),
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
                        SectionHeader(title: l10n.dashboardMoreTrainingsTitle),
                        const SizedBox(
                          height: Spacing.s,
                        ), // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[6].value (12px)
                        _buildRecommendations(
                          context,
                          l10n,
                          state.recommendations,
                        ),
                        const SizedBox(height: _sectionGapTight),
                        SectionHeader(
                          title: l10n.dashboardTrainingDataTitle,
                          showTrailingAction: false,
                        ),
                        const SizedBox(height: Spacing.s),
                        StatsScroller(
                          key: const Key('dashboard_training_stats_scroller'),
                          trainingStats: state.trainingStats,
                          isWearableConnected: state.wearable.connected,
                        ),
                        const SizedBox(height: Spacing.m),
                        CycleTipCard(phase: currentPhase),
                      ],
                      SizedBox(height: calculateBottomPadding()),
                    ],
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: ColoredBox(color: waveSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    HeaderProps header,
    Phase currentPhase,
    bool hasNotifications,
  ) {
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    final primaryColor = textTokens?.primary ?? DsColors.textPrimary;
    final secondaryColor =
        textTokens?.secondary ?? ColorTokens.recommendationTag;
    final greeting = l10n.dashboardGreeting(header.userName);
    final phaseLabel = _localizedPhaseLabel(l10n, currentPhase);
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
                    greeting,
                    style: const TextStyle(
                      fontFamily: FontFamilies.playfairDisplay,
                      fontSize: 32,
                      height: 40 / 32,
                      fontWeight: FontWeight.w400,
                    ).copyWith(color: primaryColor),
                  ),
                  const SizedBox(
                    height: 2,
                  ), // from DASHBOARD_spec.json $.spacingTokensObserved[1]
                  // from DASHBOARD_spec.json $.header.subtitle.typography (Figtree 16/24)
                  Text(
                    phaseLabel,
                    style: TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w400,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              children: [
                _buildHeaderIcon(dash_assets.Assets.icons.notifications),
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

  Widget _buildCalendar(WeekStripView weekView) {
    return DashboardCalendar(view: weekView);
  }

  Widget _buildWaveOverlay(BuildContext context, HeuteFixtureState state) {
    final surface = Theme.of(context).extension<SurfaceColorTokens>();
    final layout = Theme.of(context).extension<DashboardLayoutTokens>();
    final Color waveColor =
        surface?.waveOverlayPink ?? DsColors.waveOverlayPink;
    final double waveHeight = layout?.waveHeightPx ?? 220;
    final double heroMargin = layout?.heroHorizontalMarginPx ?? Spacing.l;
    final double calendarGap = layout?.calendarToWaveGapPx ?? Spacing.xs;
    assert(calendarGap >= 0);
    final double heroToSectionGap = layout?.heroToSectionGapPx ?? 42;
    final double heroHeight = HeroSyncPreview.kContainerHeight;
    final double bottomReveal = _waveBottomRevealFor(context, heroToSectionGap);
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final double effectiveWaveHeight = math.max(
      waveHeight,
      heroHeight + calendarGap + bottomReveal,
    );

    return RepaintBoundary(
      child: SizedBox(
        height: effectiveWaveHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _WavePainter(
                  color: waveColor,
                  amplitude: bottomReveal,
                  background: backgroundColor,
                ),
              ),
            ),
            Positioned(
              left: heroMargin,
              right: heroMargin,
              bottom: bottomReveal,
              child: HeroSyncPreview(
                key: const Key('dashboard_hero_sync_preview'),
                imagePath: dash_assets.Assets.images.heroSync01,
                badgeAssetPath: dash_assets.Assets.icons.syncBadge,
                dateText: state.heroCard.dateText,
                subtitle: state.heroCard.subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrainingSection(
    BuildContext context,
    AppLocalizations l10n,
    List<WeeklyTrainingProps> trainings,
  ) {
    final theme = Theme.of(context);
    final typographyTokens = theme.extension<WorkoutCardTypographyTokens>();
    final subtitleStyle =
        typographyTokens?.sectionSubtitleStyle ??
        const TextStyle(
          fontFamily: FontFamilies.figtree,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 24 / 16,
          fontStyle: FontStyle.italic,
          color: Color(0x99030401),
        );
    final double cardWidth = _weeklyTrainingCardWidth(context);
    final double peekPadding = math.min(60.0, cardWidth * 0.2);
    return Column(
      key: const Key('dashboard_weekly_training_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Spacing.l),
          child: SectionHeader(
            title: l10n.dashboardTrainingWeekTitle,
            showTrailingAction: false,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Padding(
          padding: const EdgeInsets.only(left: Spacing.l),
          child: Text(l10n.dashboardTrainingWeekSubtitle, style: subtitleStyle),
        ),
        const SizedBox(height: Spacing.s),
        RepaintBoundary(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.85, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SizedBox(
              height: _weeklyTrainingCardHeight,
              child: ListView.separated(
                padding: EdgeInsets.only(
                  left: Spacing.l,
                  right: peekPadding,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: trainings.length,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.hardEdge,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: _weeklyTrainingItemGap),
                itemBuilder: (context, index) {
                  final training = trainings[index];
                  return WeeklyTrainingCard(
                    title: training.title,
                    subtitle: training.subtitle,
                    imagePath: training.imagePath,
                    dayLabel: training.dayLabel,
                    duration: training.duration,
                    isCompleted: training.isCompleted,
                    onTap: () => context.push('/workout/${training.id}'),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _weeklyTrainingCardWidth(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = viewportWidth - _weeklyTrainingHorizontalInset;
    return math.min(_weeklyTrainingCardMaxWidth, availableWidth);
  }

  Widget _buildPhaseRecommendationsWaveSection(
    BuildContext context,
    AppLocalizations l10n,
    List<RecommendationProps> nutritionRecos,
    List<RecommendationProps> regenerationRecos,
  ) {
    final theme = Theme.of(context);
    final waveColor = _phaseWaveBackgroundColor(
      context,
    ); // Fallback to frame color if token missing (SSOT-compliant)
    final dividerTokens = theme.extension<DividerTokens>();
    final totalDividerSpacing = (dividerTokens?.sectionDividerVerticalMargin ?? 12.0) * 2 +
        (dividerTokens?.sectionDividerThickness ?? 1.0);
    final sectionHeight = _calculatePhaseRecoSectionHeight(totalDividerSpacing);

    return RepaintBoundary(
      child: SizedBox(
        height: sectionHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Beige wave with upward-bulging curve (flipVertical: true)
            // Wave color (#F0E5DA) contrasts against the slightly darker frame surface
            Positioned.fill(
              child: CustomPaint(
                painter: _WavePainter(
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
              top: _phaseRecoWaveHeight - _phaseRecoWaveAmplitude,
              child: Padding(
                padding: const EdgeInsets.all(_phaseRecoFramePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: l10n.dashboardRecommendationsTitle,
                      showTrailingAction: false,
                      maxLines: 2,
                    ),
                    const SizedBox(height: Spacing.m),
                    _buildRecommendationSubsection(
                      context,
                      l10n.dashboardNutritionTitle,
                      nutritionRecos,
                      _nutritionCardWidth,
                      _nutritionCardHeight,
                      l10n.nutritionRecommendation,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: dividerTokens?.sectionDividerVerticalMargin ??
                            12.0,
                      ),
                      child: Divider(
                        color: dividerTokens?.sectionDividerColor ??
                            const Color(0xFFDCDCDC),
                        thickness: dividerTokens?.sectionDividerThickness ?? 1.0,
                        height: 0,
                      ),
                    ),
                    _buildRecommendationSubsection(
                      context,
                      l10n.dashboardRegenerationTitle,
                      regenerationRecos,
                      _regenerationCardWidth,
                      _regenerationCardHeight,
                      l10n.regenerationRecommendation,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSubsection(
    BuildContext context,
    String title,
    List<RecommendationProps> recommendations,
    double cardWidth,
    double cardHeight,
    String semanticPrefix,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const headerTextStyle = TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w600,
    );

    if (recommendations.isEmpty) {
      final placeholderColor =
          theme.extension<TextColorTokens>()?.secondary ??
          ColorTokens.recommendationTag;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: headerTextStyle),
          const SizedBox(height: Spacing.s),
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
        const SizedBox(height: Spacing.s),
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
              final reco = recommendations[index];
              return Semantics(
                label:
                    '$semanticPrefix: ${reco.title}${reco.subtitle != null ? ', ${reco.subtitle}' : ''}',
                child: RecommendationCard(
                  imagePath: reco.imagePath,
                  tag: reco.tag,
                  title: reco.title,
                  subtitle: reco.subtitle,
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
          color: Colors.white.withValues(alpha: 0.08),
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

  Widget _buildCategories(
    AppLocalizations l10n,
    List<CategoryProps> categories,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth =
            constraints.maxWidth; // from layout: content width nach Padding
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        final textDirection = Directionality.of(context);
        final labels = [
          for (final category in categories)
            _categoryLabel(l10n, category.category),
        ];
        final measuredWidths = _measureChipWidths(labels, textDirection);
        final columnCount = math.min(categories.length, _categoriesColumns);
        final resolvedWidths = compressFirstRowWidths(
          measured: measuredWidths,
          contentWidth: contentWidth,
          columnCount: columnCount,
          minGap: _categoriesMinGap,
          minWidth: CategoryChip.minWidth,
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

        return _buildCategoryWrap(categories, labels, resolvedWidths, gap);
      },
    );
  }

  List<double> _measureChipWidths(List<String> labels, TextDirection dir) {
    return [for (final label in labels) CategoryChip.measuredWidth(label, dir)];
  }

  Widget _buildCategoryWrap(
    List<CategoryProps> categories,
    List<String> labels,
    List<double> resolvedWidths,
    double gap,
  ) {
    final columnCount = math.min(categories.length, _categoriesColumns);
    return Wrap(
      key: const Key('dashboard_categories_grid'),
      spacing: columnCount > 1 ? gap : 0,
      runSpacing:
          8, // from DASHBOARD_spec.json $.spacingTokensObserved.valuesPx[4].value (8px rows)
      children: [
        for (var i = 0; i < categories.length; i++)
          CategoryChip(
            key: ValueKey(categories[i].category),
            iconPath: categories[i].iconPath,
            label: labels[i],
            isSelected: categories[i].category == _selectedCategory,
            width: resolvedWidths[i],
            onTap: () => _onCategoryTap(categories[i]),
          ),
      ],
    );
  }

  void _onCategoryTap(CategoryProps category) {
    if (_selectedCategory == category.category) {
      return;
    }
    setState(() {
      _selectedCategory = category.category;
    });
    // TODO(reco-filter): hook selection into recommendations filter once feature lands.
  }

  Widget _buildRecommendations(
    BuildContext context,
    AppLocalizations l10n,
    List<RecommendationProps> recommendations,
  ) {
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    if (recommendations.isEmpty) {
      // Placeholder for empty state
      final Color emptyTextColor =
          textTokens?.secondary ?? ColorTokens.recommendationTag;
      return SizedBox(
        height:
            180, // from DASHBOARD_spec.json $.recommendations.list.itemSize.h (placeholder uses same height)
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

  Widget _buildDockNavigation(AppLocalizations l10n) {
    final tabs = [
      DockTab(
        iconPath: dash_assets.Assets.icons.navToday,
        label: l10n.dashboardNavToday,
        key: const Key('nav_today'),
      ),
      DockTab(
        iconPath: dash_assets.Assets.icons.navCycle,
        label: l10n.dashboardNavCycle,
        key: const Key('nav_cycle'),
      ),
      DockTab(
        iconPath: dash_assets.Assets.icons.navPulse,
        label: l10n.dashboardNavPulse,
        key: const Key('nav_pulse'),
      ),
      DockTab(
        iconPath: dash_assets.Assets.icons.navProfile,
        label: l10n.dashboardNavProfile,
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
              iconPath: dash_assets.Assets.icons.navSync,
              // Kodex: size and iconSize from tokens (64px, 42px)
              // Current SVG has 3px padding (26/32 glyph). Compensate to keep 65% fill.
              iconTight: false,
              isActive: _activeTabIndex == 4, // Gold tint when sync is active
              onTap: () {
                setState(() {
                  _activeTabIndex = 4; // Sync tab index
                });
                context.go(LuviSyncJournalStubScreen.route);
              },
            ),
          ),
        ),
      ],
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

  String _localizedPhaseLabel(AppLocalizations l10n, Phase phase) {
    switch (phase) {
      case Phase.menstruation:
        return l10n.cyclePhaseMenstruation;
      case Phase.follicular:
        return l10n.cyclePhaseFollicular;
      case Phase.ovulation:
        return l10n.cyclePhaseOvulation;
      case Phase.luteal:
        return l10n.cyclePhaseLuteal;
    }
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.color,
    required this.amplitude,
    required this.background,
    this.flipVertical = false,
  });

  final Color color;
  final double amplitude;
  final Color background;
  // If true, curve bulges upward; if false, curve bulges downward.
  final bool flipVertical;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final double w = size.width;
    final double h = size.height;
    if (w == 0 || h == 0) {
      return;
    }
    final double arc = amplitude.clamp(0.0, h);
    if (arc <= 0) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    canvas.drawRect(Offset.zero & size, paint);

    // Ratios derived from consent_wave.svg control points (85.5, 214, 342.5 of width 428).
    const double c1Ratio = 85.5 / 428.0;
    const double midRatio = 214.0 / 428.0;
    const double c2Ratio = 342.5 / 428.0;

    final double baseY = flipVertical ? arc : h - arc;
    // Calculate curve offset based on flip direction.
    final double curveOffset = flipVertical ? baseY - arc : baseY + arc;

    final Path path = Path()
      ..moveTo(0, baseY)
      ..cubicTo(0, baseY, w * c1Ratio, curveOffset, w * midRatio, curveOffset)
      ..cubicTo(w * c2Ratio, curveOffset, w, baseY, w, baseY);

    if (flipVertical) {
      path
        ..lineTo(w, 0)
        ..lineTo(0, 0);
    } else {
      path
        ..lineTo(w, h)
        ..lineTo(0, h);
    }
    path.close();

    final Paint cutPaint = Paint()..color = background;
    canvas.drawPath(path, cutPaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.background != background ||
        oldDelegate.flipVertical != flipVertical;
  }
}
