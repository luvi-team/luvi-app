import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/dashboard/screens/luvi_sync_journal_stub.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/dashboard/widgets/category_chip.dart';
import 'package:luvi_app/features/dashboard/widgets/recommendation_card.dart';
import 'package:luvi_app/features/dashboard/widgets/top_recommendation_tile.dart';
import 'package:luvi_app/core/design_tokens/bottom_nav_tokens.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/dashboard/data/fixtures/heute_fixtures.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';

import '../../../support/test_config.dart';

class _ViewportConfig {
  const _ViewportConfig({
    required this.testLabel,
    required this.logLabel,
    required this.logicalSize,
    required this.expectedBottomGap,
  });

  final String testLabel;
  final String logLabel;
  final Size logicalSize;
  final double expectedBottomGap;
}

const List<_ViewportConfig> _viewportConfigs = <_ViewportConfig>[
  _ViewportConfig(
    testLabel: '390×844',
    logLabel: '390x844',
    logicalSize: Size(390, 844),
    expectedBottomGap: 31.0,
  ),
  _ViewportConfig(
    testLabel: '428×926',
    logLabel: '428x926',
    logicalSize: Size(428, 926),
    expectedBottomGap: 31.0,
  ),
];

GoRouter _createTestRouter() => GoRouter(
  initialLocation: '/heute',
  routes: [
    GoRoute(path: '/heute', builder: (context, state) => const HeuteScreen()),
    GoRoute(
      path: LuviSyncJournalStubScreen.route,
      builder: (context, state) => const LuviSyncJournalStubScreen(),
    ),
  ],
);

Future<GoRouter> _pumpHeuteScreen(
  WidgetTester tester, {
  GoRouter? router,
}) async {
  final goRouter = router ?? _createTestRouter();
  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.buildAppTheme(),
      routerConfig: goRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
    ),
  );
  await tester.pumpAndSettle();
  return goRouter;
}

void main() {
  group('HeuteScreen smoke tests', () {
    testWidgets('renders without crash and displays all key sections', (
      tester,
    ) async {
      // Pump HeuteScreen with theme & localization
      await _pumpHeuteScreen(tester);

      // Verify header and hero are present
      expect(
        find.byKey(const Key('dashboard_header')),
        findsOneWidget,
        reason: 'Header section should be present',
      );
      expect(
        find.byKey(const Key('dashboard_hero_sync_preview')),
        findsOneWidget,
        reason: 'Hero Sync preview should be present',
      );

      if (TestConfig.featureDashboardV2) {
        // V2: Weekly training + Phase recommendations; legacy sections hidden
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('dashboard_weekly_training_section')),
          findsOneWidget,
          reason: 'Weekly training section should be present in V2',
        );

        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1200),
        );
        await tester.pumpAndSettle();
        final heuteContext = tester.element(find.byType(HeuteScreen));
        final l10n = AppLocalizations.of(heuteContext)!;
        expect(find.text(l10n.dashboardRecommendationsTitle), findsOneWidget);
        expect(find.text(l10n.dashboardNutritionTitle), findsOneWidget);
        expect(find.text(l10n.dashboardRegenerationTitle), findsOneWidget);

        // Legacy V1 sections should be absent in V2
        expect(
          find.byKey(const Key('dashboard_categories_grid')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('dashboard_training_stats_scroller')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('dashboard_recommendations_list')),
          findsNothing,
        );
      } else {
        // V1: Legacy sections visible
        expect(
          find.byKey(const Key('dashboard_categories_grid')),
          findsOneWidget,
          reason: 'Categories grid should be present',
        );
        expect(
          find.byKey(const Key('dashboard_recommendations_list')),
          findsOneWidget,
          reason: 'Recommendations list should be present',
        );
        expect(
          find.byKey(const Key('dashboard_training_stats_scroller')),
          findsOneWidget,
          reason: 'Training stats scroller should be present',
        );
      }

      expect(
        find.byKey(const Key('dashboard_dock_nav')),
        findsOneWidget,
        reason: 'Bottom navigation dock should be present',
      );
    });

    testWidgets('displays section headers', (tester) async {
      await _pumpHeuteScreen(tester);
      final heuteContext = tester.element(find.byType(HeuteScreen));
      final l10n = AppLocalizations.of(heuteContext)!;

      if (TestConfig.featureDashboardV2) {
        // V2 headers
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(find.text(l10n.dashboardTrainingWeekTitle), findsOneWidget);
        expect(find.text(l10n.dashboardTrainingWeekSubtitle), findsOneWidget);

        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1200),
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.dashboardRecommendationsTitle), findsOneWidget);
        expect(find.text(l10n.dashboardNutritionTitle), findsOneWidget);
        expect(find.text(l10n.dashboardRegenerationTitle), findsOneWidget);
      } else {
        // V1 headers
        expect(
          find.text(l10n.dashboardCategoriesTitle),
          findsOneWidget,
          reason: 'Categories section header should be visible',
        );
        expect(
          find.text(l10n.dashboardTopRecommendationTitle),
          findsOneWidget,
          reason: 'Top recommendation section header should be visible',
        );
        expect(
          find.text(l10n.dashboardMoreTrainingsTitle),
          findsOneWidget,
          reason: 'Recommendations section header should be visible',
        );
        expect(
          find.text(l10n.dashboardTrainingDataTitle),
          findsOneWidget,
          reason: 'Training stats section header should be visible',
        );
        expect(
          find.text(l10n.dashboardViewAll),
          findsOneWidget,
          reason: 'Recommendations header should expose trailing "Alle" CTA',
        );
      }
    });

    testWidgets('displays 4 category chips', (tester) async {
      await _pumpHeuteScreen(tester);
      final heuteContext = tester.element(find.byType(HeuteScreen));
      final l10n = AppLocalizations.of(heuteContext)!;

      // Verify 4 category chips (from default fixture)
      expect(
        find.byType(CategoryChip),
        findsNWidgets(4),
        reason: 'Should display 4 category chips',
      );

      // Verify category labels
      expect(find.text(l10n.dashboardCategoryTraining), findsOneWidget);
      expect(find.text(l10n.dashboardCategoryNutrition), findsOneWidget);
      expect(find.text(l10n.dashboardCategoryRegeneration), findsOneWidget);
      expect(find.text(l10n.dashboardCategoryMindfulness), findsOneWidget);
    }, skip: TestConfig.featureDashboardV2);

    testWidgets('displays 3 recommendation cards', (tester) async {
      await _pumpHeuteScreen(tester);

      // Verify 3 recommendation cards (from default fixture)
      expect(
        find.byType(RecommendationCard),
        findsNWidgets(3),
        reason: 'Should display 3 recommendation cards',
      );

      // Verify recommendation titles
      expect(find.text('Beine & Po'), findsOneWidget);
      expect(find.text('Rücken & Schulter'), findsOneWidget);
      expect(find.text('Ganzkörper'), findsOneWidget);
    }, skip: TestConfig.featureDashboardV2);

    testWidgets(
      'displays three stat cards with formatted values',
      (tester) async {
        await _pumpHeuteScreen(tester);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
        await tester.pumpAndSettle();

        expect(find.text('Puls'), findsOneWidget);
        expect(find.text('Verbrannte\nEnergie'), findsOneWidget);
        expect(find.text('Schritte'), findsOneWidget);
        expect(find.text('94'), findsOneWidget);
        expect(find.textContaining('500'), findsOneWidget);
        expect(find.text('2.500'), findsOneWidget);
        expect(find.text('bpm'), findsOneWidget);
      },
      skip: TestConfig.featureDashboardV2,
    );

    testWidgets('displays header greeting and cycle info', (tester) async {
      await _pumpHeuteScreen(tester);
      final heuteContext = tester.element(find.byType(HeuteScreen));
      final l10n = AppLocalizations.of(heuteContext)!;

      // Verify header text (from default fixture)
      expect(
        find.textContaining(l10n.dashboardGreeting('Sarah')),
        findsOneWidget,
        reason: 'Header greeting should be visible',
      );

      final header = find.byKey(const Key('dashboard_header'));

      // Compute expected phase label from the same fixture state and localization
      final fixtureState = HeuteFixtures.defaultState();
      final phase = fixtureState.cycleInfo.phaseFor(fixtureState.referenceDate);
      final expectedPhaseLabel = () {
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
      }();

      expect(
        find.descendant(
          of: header,
          matching: find.textContaining(expectedPhaseLabel),
        ),
        findsOneWidget,
        reason: 'Cycle phase info should be visible in header only',
      );
    });

    testWidgets('displays hero sync preview content', (tester) async {
      await _pumpHeuteScreen(tester);

      // Verify hero sync preview is present and shows CTA label "Mehr"
      expect(
        find.byKey(const Key('dashboard_hero_sync_preview')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('dashboard_hero_sync_preview')),
        findsOneWidget,
      );
      final heuteContext = tester.element(find.byType(HeuteScreen));
      final l10n = AppLocalizations.of(heuteContext)!;
      expect(find.text(l10n.dashboardHeroCtaMore), findsOneWidget);
    });

    testWidgets(
      'displays bottom navigation dock with 5 icon-only tabs (4 dock + 1 floating sync)',
      (tester) async {
        await _pumpHeuteScreen(tester);

        // Phase A: 5 icon-only tabs (Heute/Zyklus/Sync/Puls/Profil), no "Home" label
        expect(
          find.byKey(const Key('nav_today')),
          findsOneWidget,
          reason: 'Bottom nav should include Heute tab',
        );

        expect(
          find.byKey(const Key('nav_cycle')),
          findsOneWidget,
          reason: 'Bottom nav should include Zyklus tab',
        );

        expect(
          find.byKey(const Key('floating_sync_button')),
          findsOneWidget,
          reason: 'Bottom nav should include floating Sync button',
        );

        expect(
          find.byKey(const Key('nav_pulse')),
          findsOneWidget,
          reason: 'Bottom nav should include Puls tab',
        );

        expect(
          find.byKey(const Key('nav_profile')),
          findsOneWidget,
          reason: 'Bottom nav should include Profil tab',
        );
      },
    );

    testWidgets('renders at least six SVG icons', (tester) async {
      await _pumpHeuteScreen(tester);

      final svgCount = tester.widgetList(find.byType(SvgPicture)).length;
      expect(
        svgCount,
        greaterThanOrEqualTo(6),
        reason: 'Header(2) + Kategorien(4) + CTA/Bottom-Icons erwarten ≥6 SVGs',
      );
    });

    testWidgets(
      'keeps four category chips aligned within ±1px at 390 width',
      (tester) async {
        final view = tester.view;
        view.physicalSize = const Size(390, 844);
        view.devicePixelRatio = 1.0;
        addTearDown(() {
          view.resetPhysicalSize();
          view.resetDevicePixelRatio();
        });

        await _pumpHeuteScreen(tester);

        final chipFinder = find.byType(CategoryChip);
        expect(chipFinder, findsNWidgets(4));

        final topYs = List<double>.generate(
          4,
          (index) => tester.getTopLeft(chipFinder.at(index)).dy,
        );

        final baseline = topYs.first;
        for (final dy in topYs) {
          expect(
            (dy - baseline).abs(),
            lessThanOrEqualTo(1.0),
            reason: 'CategoryChip top edges should align innerhalb ±1px',
          );
        }
      },
      skip: TestConfig.featureDashboardV2,
    );

    testWidgets(
      'verifies equal horizontal spacing between 4 category chips',
      (tester) async {
        final view = tester.view;
        view.physicalSize = const Size(390, 844);
        view.devicePixelRatio = 1.0;
        addTearDown(() {
          view.resetPhysicalSize();
          view.resetDevicePixelRatio();
        });

        await _pumpHeuteScreen(tester);

        final chipFinder = find.byType(CategoryChip);
        expect(chipFinder, findsNWidgets(4));

        // Measure left x-coordinates and widths
        final rects = List<Rect>.generate(
          4,
          (index) => tester.getRect(chipFinder.at(index)),
        );

        // Calculate gaps: distance from right edge of chip[i] to left edge of chip[i+1]
        final gaps = <double>[
          rects[1].left - rects[0].right,
          rects[2].left - rects[1].right,
          rects[3].left - rects[2].right,
        ];

        final baselineGap = gaps.first;
        for (var index = 0; index < gaps.length; index++) {
          expect(
            (gaps[index] - baselineGap).abs(),
            lessThanOrEqualTo(1.0),
            reason:
                'd${index + 1} (Δx between chips) should stay within ±1px at 390px viewport',
          );
        }
      },
      skip: TestConfig.featureDashboardV2,
    );

    testWidgets('bottom nav pill sits close to screen bottom (≤4px gap)', (
      tester,
    ) async {
      final view = tester.view;
      view.physicalSize = const Size(390, 844);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      await _pumpHeuteScreen(tester);

      final dockFinder = find.byKey(const Key('dashboard_dock_nav'));
      expect(dockFinder, findsOneWidget);

      final dockRect = tester.getRect(dockFinder);
      final Size logicalSize = view.physicalSize / view.devicePixelRatio;
      // Dock now renders via Scaffold.bottomNavigationBar SafeArea; ensure it hugs the bottom inset.
      final double gap = logicalSize.height - dockRect.bottom;

      expect(
        gap,
        lessThanOrEqualTo(4.0),
        reason:
            'Bottom nav pill should sit within 4px of screen bottom (Figma parity)',
      );
    });

    for (final _ViewportConfig viewport in _viewportConfigs) {
      testWidgets(
        'validates vertical rhythm at ${viewport.testLabel}',
        (tester) async {
          final view = tester.view;
          view.physicalSize = viewport.logicalSize;
          view.devicePixelRatio = 1.0;
          addTearDown(() {
            view.resetPhysicalSize();
            view.resetDevicePixelRatio();
          });

          await _pumpHeuteScreen(tester);
          final heuteContext = tester.element(find.byType(HeuteScreen));
          final l10n = AppLocalizations.of(heuteContext)!;

          final Finder scrollable = find.byType(CustomScrollView);
          expect(
            scrollable,
            findsOneWidget,
            reason:
                'Dashboard nutzt CustomScrollView für Scroll + Fill, sollte in beiden Viewports verfügbar sein',
          );
          await tester.drag(scrollable, const Offset(0, -600));
          await tester.pumpAndSettle();

          const double tolerance = 0.5;

          final Rect categoriesHeaderRect = tester.getRect(
            find.text(l10n.dashboardCategoriesTitle),
          );
          final Rect categoriesRect = tester.getRect(
            find.byKey(const Key('dashboard_categories_grid')),
          );
          final Rect topRecoHeaderRect = tester.getRect(
            find.text(l10n.dashboardTopRecommendationTitle),
          );
          final Rect topRecoRect = tester.getRect(
            find.byType(TopRecommendationTile),
          );
          final Rect recsHeaderRect = tester.getRect(
            find.text(l10n.dashboardMoreTrainingsTitle),
          );
          final Rect listRect = tester.getRect(
            find.byKey(const Key('dashboard_recommendations_list')),
          );
          final Finder dockFinder = find.byKey(const Key('dashboard_dock_nav'));
          expect(dockFinder, findsOneWidget);
          final Rect dockRect = tester.getRect(dockFinder);
          final Rect navAreaRect = dockRect; // Dock itself is the nav area

          final double gapCatsHeaderToGrid =
              categoriesRect.top - categoriesHeaderRect.bottom;
          final double gapCatsBlockToTopRecoHeader =
              topRecoHeaderRect.top - categoriesRect.bottom;
          final double gapTopRecoHeaderToTile =
              topRecoRect.top - topRecoHeaderRect.bottom;
          final double gapTopRecoToRecsHeader =
              recsHeaderRect.top - topRecoRect.bottom;
          final double gapRecsHeaderToList =
              listRect.top - recsHeaderRect.bottom;
          final double gapListToBottomBarTop = dockRect.top - listRect.bottom;

          String fmt(double value) {
            const double epsilon = 1e-6;
            final double fractional = (value - value.truncateToDouble()).abs();
            if (fractional < epsilon) {
              return value.truncate().toString();
            }
            return value.toStringAsFixed(1);
          }

          // keep debug log for audits per viewport.
          // ignore: avoid_print
          print(
            'Viewport ${viewport.logLabel} → V-GAPS: '
            'catsHdr→grid=${fmt(gapCatsHeaderToGrid)}, '
            'catsBlock→topRecoHdr=${fmt(gapCatsBlockToTopRecoHeader)}, '
            'topRecoHdr→tile=${fmt(gapTopRecoHeaderToTile)}, '
            'topReco→recsHdr=${fmt(gapTopRecoToRecsHeader)}, '
            'recsHdr→list=${fmt(gapRecsHeaderToList)}, '
            'list→bottom=${fmt(dockRect.top - listRect.bottom)} '
            '(navTop→list=${fmt(gapListToBottomBarTop)} '
            'target=${fmt(viewport.expectedBottomGap)}, '
            'navPaddingTop=${fmt(navAreaRect.top)} '
            'vs. listBottom=${fmt(listRect.bottom)})',
          );

          expect(
            gapCatsHeaderToGrid,
            moreOrLessEquals(12.0, epsilon: tolerance),
            reason: 'Kategorien header → grid sollte 12px ±0.5 ergeben',
          );

          expect(
            gapCatsBlockToTopRecoHeader,
            moreOrLessEquals(16.0, epsilon: tolerance),
            reason:
                'Kategorien block → "Deine Top-Empfehlung" header sollte 16px ±0.5 ergeben',
          );

          expect(
            gapTopRecoHeaderToTile,
            moreOrLessEquals(12.0, epsilon: tolerance),
            reason:
                '"Deine Top-Empfehlung" header → tile sollte 12px ±0.5 ergeben',
          );

          expect(
            gapTopRecoToRecsHeader,
            moreOrLessEquals(20.0, epsilon: tolerance),
            reason:
                'Top-Empfehlung tile → "Weitere Trainings" header sollte 20px ±0.5 ergeben',
          );

          expect(
            gapRecsHeaderToList,
            moreOrLessEquals(12.0, epsilon: tolerance),
            reason: 'Weitere Trainings header → Liste sollte 12px ±0.5 ergeben',
          );

          expect(
            gapListToBottomBarTop,
            greaterThanOrEqualTo(viewport.expectedBottomGap - tolerance),
            reason:
                'Liste → Bottom-Pill top sollte mindestens ${viewport.expectedBottomGap}px betragen',
          );
        },
        skip: TestConfig.featureDashboardV2,
      );
    }

    testWidgets(
      'bottom nav tabs have hit area ≥44×44 (4 dock + 1 floating sync)',
      (tester) async {
        await _pumpHeuteScreen(tester);

        const List<String> navKeys = [
          'nav_today',
          'nav_cycle',
          'nav_pulse',
          'nav_profile',
          'floating_sync_button',
        ];

        for (final keyString in navKeys) {
          final finder = find.byKey(Key(keyString));
          expect(finder, findsOneWidget, reason: 'Tab $keyString should exist');

          final Size size = tester.getSize(finder);
          expect(
            size.width,
            greaterThanOrEqualTo(44.0),
            reason:
                'Tab $keyString width should be ≥44px (actual: ${size.width})',
          );
          expect(
            size.height,
            greaterThanOrEqualTo(44.0),
            reason:
                'Tab $keyString height should be ≥44px (actual: ${size.height})',
          );
        }
      },
    );

    testWidgets('floating sync button is positioned above dock (z-order)', (
      tester,
    ) async {
      await _pumpHeuteScreen(tester);

      final syncFinder = find.byKey(const Key('floating_sync_button'));
      final dockFinder = find.byKey(const Key('dashboard_dock_nav'));

      expect(syncFinder, findsOneWidget);
      expect(dockFinder, findsOneWidget);

      final syncRect = tester.getRect(syncFinder);
      final dockRect = tester.getRect(dockFinder);

      // Sync button should be positioned above dock (lower Y = higher on screen)
      expect(
        syncRect.top,
        lessThan(dockRect.top),
        reason: 'Floating sync button should be above dock-bar (z-order)',
      );
    });

    testWidgets('active tab displays Gold tint (colorScheme.primary)', (
      tester,
    ) async {
      await _pumpHeuteScreen(tester);

      // Default active tab is Heute (index 0)
      // Verify exactly one tab has selected=true semantics (which corresponds to Gold tint)
      final selectedSemantics = tester.widgetList<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.selected == true &&
              widget.properties.button == true,
        ),
      );

      expect(
        selectedSemantics.length,
        equals(1),
        reason:
            'Exactly one tab should have selected=true (receives Gold tint)',
      );

      // Verify the active tab is "Heute" (default)
      final heuteSemantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.byKey(const Key('nav_today')),
              matching: find.byWidgetPredicate((w) => w is Semantics),
            )
            .first,
      );

      expect(
        heuteSemantics.properties.selected,
        isTrue,
        reason: 'Heute tab should be active by default (receives Gold tint)',
      );
    });

    testWidgets(
      'floating sync button exposes semantics and navigates to journal',
      (tester) async {
        final goRouter = await _pumpHeuteScreen(tester);

        final syncButtonFinder = find.byKey(const Key('floating_sync_button'));
        expect(syncButtonFinder, findsOneWidget);

        final syncContext = tester.element(syncButtonFinder);
        final l10n = AppLocalizations.of(syncContext)!;

        final semanticsFinder = find.descendant(
          of: syncButtonFinder,
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.button == true,
          ),
        );

        expect(
          semanticsFinder,
          findsOneWidget,
          reason: 'Floating sync button should expose semantics entry',
        );

        final Semantics semantics = tester.widget<Semantics>(semanticsFinder);
        expect(
          semantics.properties.label,
          equals(l10n.dashboardNavSync),
          reason: 'Semantics label should use localized sync label',
        );
        expect(
          semantics.properties.selected,
          isFalse,
          reason: 'Sync button should be inactive before tap',
        );

        await tester.tap(syncButtonFinder);
        await tester.pumpAndSettle();

        final currentUri = goRouter.routerDelegate.currentConfiguration.uri
            .toString();
        expect(
          currentUri,
          equals(LuviSyncJournalStubScreen.route),
          reason: 'Tap on sync should navigate to Luvi Sync journal',
        );
      },
    );

    testWidgets('bottom nav has exactly one active tab with semantics', (
      tester,
    ) async {
      await _pumpHeuteScreen(tester);
      final heuteContext = tester.element(find.byType(HeuteScreen));
      final l10n = AppLocalizations.of(heuteContext)!;

      // Find all Semantics widgets with "selected" property
      final selectedSemantics = tester.widgetList<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.selected == true &&
              widget.properties.button == true,
        ),
      );

      expect(
        selectedSemantics.length,
        equals(1),
        reason: 'Exactly one tab should have selected=true (active tab)',
      );

      // Verify active tab is "Heute" (index 0, default)
      final todaySemantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.byKey(const Key('nav_today')),
              matching: find.byWidgetPredicate((w) => w is Semantics),
            )
            .first,
      );

      expect(
        todaySemantics.properties.label,
        equals(l10n.dashboardNavToday),
        reason: 'Active tab should have correct semantics label',
      );
      expect(
        todaySemantics.properties.selected,
        isTrue,
        reason: 'Default active tab (Heute) should have selected=true',
      );
    });

    testWidgets('sync icon uses compensated size when asset not tight', (
      tester,
    ) async {
      await _pumpHeuteScreen(tester);

      // Find the SvgPicture inside the floating sync button
      final Finder syncButtonFinder = find.byKey(
        const Key('floating_sync_button'),
      );
      expect(syncButtonFinder, findsOneWidget);

      final svgInButton = find.descendant(
        of: syncButtonFinder,
        matching: find.byType(SvgPicture),
      );
      expect(svgInButton, findsOneWidget);

      final SvgPicture svg = tester.widget<SvgPicture>(svgInButton);

      // The HeuteScreen passes iconTight: false, so the effective icon size should be
      // iconSizeCompensated (auto-derived from tokens and current SVG glyph ratio).
      expect(svg.width, moreOrLessEquals(iconSizeCompensated, epsilon: 0.1));
      expect(svg.height, moreOrLessEquals(iconSizeCompensated, epsilon: 0.1));
    });
  });
}
