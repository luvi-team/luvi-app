import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart' as dash_assets;
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/data/fixtures/heute_fixtures.dart';
import 'package:luvi_app/features/dashboard/widgets/bottom_nav_dock.dart';
import 'package:luvi_app/features/dashboard/widgets/floating_sync_button.dart';
import 'package:luvi_app/core/design_tokens/bottom_nav_tokens.dart';
import 'package:luvi_app/features/dashboard/widgets/hero_sync_preview.dart';
import 'package:luvi_app/features/dashboard/widgets/painters/wave_painter.dart';
import 'package:luvi_app/features/cycle/domain/week_strip.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/dashboard/widgets/dashboard_calendar.dart';
import 'package:luvi_app/features/dashboard/state/heute_vm.dart';
import 'package:luvi_app/features/dashboard/screens/luvi_sync_journal_stub.dart';
import 'package:luvi_app/features/dashboard/widgets/heute_header.dart';
import 'package:luvi_app/features/dashboard/widgets/weekly_training_section.dart';
import 'package:luvi_app/features/dashboard/widgets/phase_recommendations_section.dart';
import 'package:luvi_app/features/dashboard/widgets/legacy_sections.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Calculates the visible portion of the wave arc based on viewport scaling.
/// The wave asset is designed at 428px width with a 40px arc height.
/// This function scales the arc proportionally to the current viewport width,
/// capped at [heroToSectionGap] to prevent layout overflow.
@visibleForTesting
double waveBottomRevealForWidth(
  double viewportWidth,
  double heroToSectionGap,
) {
  const double waveAssetWidth = 428.0;
  const double waveArcHeight = 40.0;
  final double scale = viewportWidth / waveAssetWidth;
  final double reveal = waveArcHeight * scale;
  return math.min(reveal, heroToSectionGap);
}

class _HeuteAppBar extends StatelessWidget {
  const _HeuteAppBar({
    required this.userName,
    required this.currentPhase,
    required this.hasNotifications,
  });

  final String userName;
  final Phase currentPhase;
  final bool hasNotifications;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Spacing.m),
            HeuteHeader(
              userName: userName,
              currentPhase: currentPhase,
              hasNotifications: hasNotifications,
            ),
            const SizedBox(height: Spacing.m),
          ],
        ),
      ),
    );
  }
}

class _HeuteSliverHeader extends StatelessWidget {
  const _HeuteSliverHeader({
    required this.calendar,
    required this.waveOverlay,
  });

  final Widget calendar;
  final Widget waveOverlay;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          calendar,
          waveOverlay,
        ],
      ),
    );
  }
}

class _HeuteStatsSection extends StatelessWidget {
  const _HeuteStatsSection({
    required this.isDashboardV2Enabled,
    required this.postWaveTopGap,
    required this.state,
    required this.currentPhase,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.onTrainingTap,
  });

  final bool isDashboardV2Enabled;
  final double postWaveTopGap;
  final HeuteFixtureState state;
  final Phase currentPhase;
  final Category selectedCategory;
  final ValueChanged<Category> onCategoryTap;
  final ValueChanged<String> onTrainingTap;

  @override
  Widget build(BuildContext context) {
    if (isDashboardV2Enabled) {
      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: postWaveTopGap),
            Padding(
              padding: const EdgeInsets.only(right: Spacing.l),
              child: WeeklyTrainingSection(
                trainings: state.weeklyTrainings,
                onTrainingTap: onTrainingTap,
              ),
            ),
            const SizedBox(height: Spacing.m),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: postWaveTopGap),
            LegacySections(
              categories: state.categories,
              selectedCategory: selectedCategory,
              onCategoryTap: onCategoryTap,
              topRecommendation: state.topRecommendation,
              recommendations: state.recommendations,
              trainingStats: state.trainingStats,
              isWearableConnected: state.wearable.connected,
              currentPhase: currentPhase,
            ),
            const SizedBox(height: Spacing.m),
          ],
        ),
      ),
    );
  }
}

class _HeuteRecommendationSection extends StatelessWidget {
  const _HeuteRecommendationSection({
    required this.isDashboardV2Enabled,
    required this.state,
    required this.waveSurface,
  });

  final bool isDashboardV2Enabled;
  final HeuteFixtureState state;
  final Color waveSurface;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDashboardV2Enabled)
            PhaseRecommendationsSection(
              nutritionRecommendations: state.nutritionRecommendations,
              regenerationRecommendations: state.regenerationRecommendations,
            ),
          ColoredBox(
            color: waveSurface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [SizedBox(height: scrollStopPadding(context))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeuteBottomDock extends StatelessWidget {
  const _HeuteBottomDock({
    required this.l10n,
    required this.activeTabIndex,
    required this.onTabSelected,
    required this.onSyncTap,
  });

  final AppLocalizations l10n;
  final int activeTabIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onSyncTap;

  @override
  Widget build(BuildContext context) {
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
        BottomNavDock(
          key: const Key('dashboard_dock_nav'),
          activeIndex: activeTabIndex == 4 ? -1 : activeTabIndex,
          onTabTap: onTabSelected,
          tabs: tabs,
        ),
        Positioned(
          bottom: syncButtonBottom,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingSyncButton(
              key: const Key('floating_sync_button'),
              iconPath: dash_assets.Assets.icons.navSync,
              iconTight: false,
              isActive: activeTabIndex == 4,
              onTap: onSyncTap,
            ),
          ),
        ),
      ],
    );
  }
}

double _waveBottomRevealFor(BuildContext context, double heroToSectionGap) {
  final double viewportWidth = MediaQuery.sizeOf(context).width;
  return waveBottomRevealForWidth(viewportWidth, heroToSectionGap);
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
    final currentPhase = state.cycleInfo.phaseFor(state.referenceDate);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final layout = theme.extension<DashboardLayoutTokens>();
    final double heroToSectionGap = layout?.heroToSectionGapPx ?? 42;
    final bool isDashboardV2Enabled = FeatureFlags.featureDashboardV2;
    final double bottomReveal = _waveBottomRevealFor(context, heroToSectionGap);
    final double postWaveTopGap = math.max(
      Spacing.xs,
      heroToSectionGap - bottomReveal,
    );
    final surfaceTokens = theme.extension<SurfaceColorTokens>();
    final dsTokens = theme.extension<DsTokens>();
    final Color waveTint =
        surfaceTokens?.waveOverlayBeige ??
        dsTokens?.cardSurface ??
        SurfaceColorTokens.light.waveOverlayBeige;
    final Color waveSurface = Color.alphaBlend(waveTint, Colors.white);
    final Widget calendar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: _buildCalendar(weekView),
    );
    final Widget waveOverlay = _buildWaveOverlay(
      context,
      state,
      heroToSectionGap,
      bottomReveal,
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: _HeuteBottomDock(
        l10n: l10n,
        activeTabIndex: _activeTabIndex,
        onTabSelected: (index) {
          setState(() {
            _activeTabIndex = index;
          });
        },
        onSyncTap: () {
          setState(() {
            _activeTabIndex = 4;
          });
          if (!mounted) {
            return;
          }
          context.go(LuviSyncJournalStubScreen.route);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _HeuteAppBar(
              userName: state.header.userName,
              currentPhase: currentPhase,
              hasNotifications: state.bottomNav.hasNotifications,
            ),
            _HeuteSliverHeader(
              calendar: calendar,
              waveOverlay: waveOverlay,
            ),
            _HeuteStatsSection(
              isDashboardV2Enabled: isDashboardV2Enabled,
              postWaveTopGap: postWaveTopGap,
              state: state,
              currentPhase: currentPhase,
              selectedCategory: _selectedCategory,
              onCategoryTap: (category) {
                if (_selectedCategory == category) {
                  return;
                }
                setState(() {
                  _selectedCategory = category;
                });
              },
              onTrainingTap: (trainingId) =>
                  context.push('/workout/$trainingId'),
            ),
            _HeuteRecommendationSection(
              isDashboardV2Enabled: isDashboardV2Enabled,
              state: state,
              waveSurface: waveSurface,
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

  Widget _buildCalendar(WeekStripView weekView) {
    return DashboardCalendar(view: weekView);
  }

  Widget _buildWaveOverlay(
    BuildContext context,
    HeuteFixtureState state,
    double heroToSectionGap,
    double bottomReveal,
  ) {
    final surface = Theme.of(context).extension<SurfaceColorTokens>();
    final layout = Theme.of(context).extension<DashboardLayoutTokens>();
    final Color waveColor =
        surface?.waveOverlayPink ?? DsColors.waveOverlayPink;
    final double waveHeight = layout?.waveHeightPx ?? 220;
    final double heroMargin = layout?.heroHorizontalMarginPx ?? Spacing.l;
    final double calendarGap = layout?.calendarToWaveGapPx ?? Spacing.xs;
    assert(calendarGap >= 0);
    final double heroHeight = HeroSyncPreview.kContainerHeight;
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
                painter: WavePainter(
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

}
