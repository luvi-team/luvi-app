import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/dashboard_screen.dart';
import 'package:luvi_app/features/widgets/category_chip.dart';
import 'package:luvi_app/features/widgets/recommendation_card.dart';

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

      // Verify bottom nav "Start" label
      expect(
        find.text('Start'),
        findsOneWidget,
        reason: 'Bottom nav "Start" label should be visible',
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
  });
}
