import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/features/widgets/category_chip.dart';
import 'package:luvi_app/features/widgets/recommendation_card.dart';

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

void main() {
  group('HeuteScreen smoke tests', () {
    testWidgets('renders without crash and displays all key sections',
        (tester) async {
      // Pump HeuteScreen with theme & localization
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );

      // Wait for all widgets to settle
      await tester.pumpAndSettle();

      // Verify key widgets are present
      expect(
        find.byKey(const Key('dashboard_header')),
        findsOneWidget,
        reason: 'Header section should be present',
      );

      expect(
        find.byKey(const Key('dashboard_hero_card')),
        findsOneWidget,
        reason: 'Hero card section should be present',
      );

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
        find.byKey(const Key('dashboard_dock_nav')),
        findsOneWidget,
        reason: 'Bottom navigation dock should be present',
      );
    });

    testWidgets('displays section headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify section headers
      expect(
        find.text('Kategorien'),
        findsOneWidget,
        reason: 'Categories section header should be visible',
      );

      expect(
        find.text('Empfehlungen'),
        findsOneWidget,
        reason: 'Recommendations section header should be visible',
      );

      expect(
        find.text('Alle'),
        findsOneWidget,
        reason: 'Recommendations header should expose trailing "Alle" CTA',
      );
    });

    testWidgets('displays 4 category chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 4 category chips (from default fixture)
      expect(
        find.byType(CategoryChip),
        findsNWidgets(4),
        reason: 'Should display 4 category chips',
      );

      // Verify category labels
      expect(find.text('Training'), findsOneWidget);
      expect(find.text('Ernährung'), findsOneWidget);
      expect(find.text('Regeneration'), findsOneWidget);
      expect(find.text('Achtsamkeit'), findsOneWidget);
    });

    testWidgets('displays 3 recommendation cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

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
    });

    testWidgets('displays header greeting and cycle info', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header text (from default fixture)
      expect(
        find.textContaining('Hey, Sarah'),
        findsOneWidget,
        reason: 'Header greeting should be visible',
      );

      expect(
        find.textContaining('Folikelphase'),
        findsOneWidget,
        reason: 'Cycle phase info should be visible',
      );
    });

    testWidgets('displays hero card content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify hero card content (from default fixture)
      expect(find.text('Kraft - Ganzkörper'), findsOneWidget);
      expect(find.text('12 Übungen offen'), findsOneWidget);
      expect(find.text('Training ansehen'), findsOneWidget);
      expect(
        find.text('25%'),
        findsOneWidget,
        reason: 'Progress percentage should be visible',
      );
    });

    testWidgets('displays bottom navigation dock with 5 icon-only tabs (4 dock + 1 floating sync)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

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
    });

    testWidgets('renders at least six SVG icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final svgCount = tester.widgetList(find.byType(SvgPicture)).length;
      expect(
        svgCount,
        greaterThanOrEqualTo(6),
        reason: 'Header(2) + Kategorien(4) + CTA/Bottom-Icons erwarten ≥6 SVGs',
      );
    });

    testWidgets('keeps four category chips aligned within ±1px at 390 width',
        (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(390, 844);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

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
    });

    testWidgets('verifies equal horizontal spacing between 4 category chips',
        (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(390, 844);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

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
          reason: 'd${index + 1} (Δx between chips) should stay within ±1px at 390px viewport',
        );
      }
    });

    testWidgets('bottom nav pill sits close to screen bottom (≤4px gap)',
        (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(390, 844);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final dockFinder = find.byKey(const Key('dashboard_dock_nav'));
      expect(dockFinder, findsOneWidget);

      final dockRect = tester.getRect(dockFinder);
      final Size logicalSize = view.physicalSize / view.devicePixelRatio;
      // Dock now renders via Scaffold.bottomNavigationBar SafeArea; ensure it hugs the bottom inset.
      final double gap = logicalSize.height - dockRect.bottom;

      expect(
        gap,
        lessThanOrEqualTo(4.0),
        reason: 'Bottom nav pill should sit within 4px of screen bottom (Figma parity)',
      );
    });


    for (final _ViewportConfig viewport in _viewportConfigs) {
      testWidgets('validates vertical rhythm at ${viewport.testLabel}',
          (tester) async {
        final view = tester.view;
        view.physicalSize = viewport.logicalSize;
        view.devicePixelRatio = 1.0;
        addTearDown(() {
          view.resetPhysicalSize();
          view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.buildAppTheme(),
            home: const HeuteScreen(),
          ),
        );
        await tester.pumpAndSettle();

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

        final Rect categoriesHeaderRect = tester.getRect(find.text('Kategorien'));
        final Rect categoriesRect = tester.getRect(
          find.byKey(const Key('dashboard_categories_grid')),
        );
        final Rect recsHeaderRect = tester.getRect(find.text('Empfehlungen'));
        final Rect listRect = tester.getRect(
          find.byKey(const Key('dashboard_recommendations_list')),
        );
        final Finder dockFinder =
            find.byKey(const Key('dashboard_dock_nav'));
        expect(dockFinder, findsOneWidget);
        final Rect dockRect = tester.getRect(dockFinder);
        final Rect navAreaRect = dockRect; // Dock itself is the nav area

        final double gapCatsHeaderToGrid =
            categoriesRect.top - categoriesHeaderRect.bottom;
        final double gapCatsBlockToRecsHeader =
            recsHeaderRect.top - categoriesRect.bottom;
        final double gapRecsHeaderToList =
            listRect.top - recsHeaderRect.bottom;
        final double gapListToBottomBarTop =
            dockRect.top - listRect.bottom;

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
          'catsBlock→recsHdr=${fmt(gapCatsBlockToRecsHeader)}, '
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
          gapCatsBlockToRecsHeader,
          moreOrLessEquals(24.0, epsilon: tolerance),
          reason:
              'Kategorien block → Empfehlungen header sollte 24px ±0.5 ergeben',
        );

        expect(
          gapRecsHeaderToList,
          moreOrLessEquals(12.0, epsilon: tolerance),
          reason: 'Empfehlungen header → Liste sollte 12px ±0.5 ergeben',
        );

        expect(
          gapListToBottomBarTop,
          greaterThanOrEqualTo(viewport.expectedBottomGap - tolerance),
          reason:
              'Liste → Bottom-Pill top sollte mindestens ${viewport.expectedBottomGap}px betragen',
        );
      });
    }

    testWidgets('bottom nav tabs have hit area ≥44×44 (4 dock + 1 floating sync)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

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
          reason: 'Tab $keyString width should be ≥44px (actual: ${size.width})',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(44.0),
          reason: 'Tab $keyString height should be ≥44px (actual: ${size.height})',
        );
      }
    });

    testWidgets('floating sync button is positioned above dock (z-order)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

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

    testWidgets('active tab displays Gold tint (colorScheme.primary)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

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
        reason: 'Exactly one tab should have selected=true (receives Gold tint)',
      );

      // Verify the active tab is "Heute" (default)
      final heuteSemantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.byKey(const Key('nav_today')),
          matching: find.byWidgetPredicate((w) => w is Semantics),
        ).first,
      );

      expect(
        heuteSemantics.properties.selected,
        isTrue,
        reason: 'Heute tab should be active by default (receives Gold tint)',
      );
    });

    testWidgets('sync button receives Gold tint when active (index==4)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap sync button to activate it
      await tester.tap(find.byKey(const Key('floating_sync_button')));
      await tester.pumpAndSettle();

      // Verify sync button has selected=true (Gold tint)
      final syncSemanticsWidgets = tester.widgetList<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Sync' &&
              widget.properties.button == true,
        ),
      );

      expect(
        syncSemanticsWidgets.isNotEmpty,
        isTrue,
        reason: 'Sync button Semantics should exist',
      );

      final syncSemantics = syncSemanticsWidgets.first;
      expect(
        syncSemantics.properties.selected,
        isTrue,
        reason: 'Sync button should be active after tap (receives Gold tint)',
      );

      // Verify no dock tab is selected when sync is active
      final dockTabsWithSelected = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byKey(const Key('dashboard_dock_nav')),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.selected == true &&
                widget.properties.button == true,
          ),
        ),
      );

      expect(
        dockTabsWithSelected.length,
        equals(0),
        reason: 'No dock tab should be selected when sync is active (index==4)',
      );
    });

    testWidgets('bottom nav has exactly one active tab with semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
        ),
      );
      await tester.pumpAndSettle();

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
        find.ancestor(
          of: find.byKey(const Key('nav_today')),
          matching: find.byWidgetPredicate((w) => w is Semantics),
        ).first,
      );

      expect(
        todaySemantics.properties.label,
        equals('Heute'),
        reason: 'Active tab should have correct semantics label',
      );
      expect(
        todaySemantics.properties.selected,
        isTrue,
        reason: 'Default active tab (Heute) should have selected=true',
      );
    });

  });
}
