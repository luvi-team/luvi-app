import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/dashboard_screen.dart';
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
  group('DashboardScreen smoke tests', () {
    testWidgets('renders without crash and displays all key sections',
        (tester) async {
      // Pump DashboardScreen with theme & localization
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const DashboardScreen(),
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
        find.byKey(const Key('dashboard_bottom_nav_pill')),
        findsOneWidget,
        reason: 'Bottom navigation pill should be present',
      );
    });

    testWidgets('displays section headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const DashboardScreen(),
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
          home: const DashboardScreen(),
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
          home: const DashboardScreen(),
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
          home: const DashboardScreen(),
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
          home: const DashboardScreen(),
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

    testWidgets('displays bottom navigation pill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify bottom nav "Home" label
      expect(
        find.text('Home'),
        findsOneWidget,
        reason: 'Bottom nav "Home" label should be visible',
      );

      expect(
        find.byKey(const Key('dashboard_nav_flower')),
        findsOneWidget,
        reason: 'Bottom nav should include the flower icon button',
      );

      expect(
        find.byKey(const Key('dashboard_nav_social')),
        findsOneWidget,
        reason: 'Bottom nav should include the social icon button',
      );

      expect(
        find.byKey(const Key('dashboard_nav_chart')),
        findsOneWidget,
        reason: 'Bottom nav should include the chart icon button',
      );

      expect(
        find.byKey(const Key('dashboard_nav_account')),
        findsOneWidget,
        reason: 'Bottom nav should include the account icon button',
      );
    });

    testWidgets('renders at least six SVG icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const DashboardScreen(),
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
          home: const DashboardScreen(),
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
          home: const DashboardScreen(),
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
          home: const DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final pillFinder = find.byKey(const Key('dashboard_bottom_nav_pill'));
      expect(pillFinder, findsOneWidget);

      final pillRect = tester.getRect(pillFinder);
      final Size logicalSize = view.physicalSize / view.devicePixelRatio;
      // Pill now renders via Scaffold.bottomNavigationBar SafeArea; ensure it hugs the bottom inset.
      final double gap = logicalSize.height - pillRect.bottom;

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
            home: const DashboardScreen(),
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
        final Finder pillFinder =
            find.byKey(const Key('dashboard_bottom_nav_pill'));
        expect(pillFinder, findsOneWidget);
        final Rect pillRect = tester.getRect(pillFinder);
        final Rect navAreaRect = tester.getRect(
          find
              .ancestor(
                of: pillFinder,
                matching: find.byType(Padding),
              )
              .first,
        );

        final double gapCatsHeaderToGrid =
            categoriesRect.top - categoriesHeaderRect.bottom;
        final double gapCatsBlockToRecsHeader =
            recsHeaderRect.top - categoriesRect.bottom;
        final double gapRecsHeaderToList =
            listRect.top - recsHeaderRect.bottom;
        final double gapListToBottomBarTop =
            pillRect.top - listRect.bottom;

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
          'list→bottom=${fmt(pillRect.top - listRect.bottom)} '
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

  });
}
