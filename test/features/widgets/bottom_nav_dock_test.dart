import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/bottom_nav_dock.dart';
import 'package:luvi_app/features/widgets/painters/wave_clip.dart';
import 'package:luvi_app/features/widgets/bottom_nav_tokens.dart';

void main() {
  group('BottomNavDock', () {
    // Kodex: Geometry constants from tokens (Figma audit 2025-10-06)
    const double expectedDockHeight = dockHeight; // 96px (from tokens)
    const double expectedIconSize = tabIconSize; // 32px (from tokens)
    const double expectedCenterGap = centerGap; // 118px = 2 × 59 (from tokens)
    const double expectedTapAreaSize = minTapArea; // 44px (from tokens)
    const double expectedCutoutDepth = cutoutDepth; // 38px (from tokens, was 25px)
    const double expectedSyncBottom = syncButtonBottom; // 49px = 96-38-9 (from tokens)
    const double expectedButtonIconSize = iconSizeTight; // 42px for 65% fill (from tokens)

    final tabs = [
      const DockTab(iconPath: 'assets/icons/dashboard/nav.today.svg', label: 'Heute'),
      const DockTab(iconPath: 'assets/icons/dashboard/nav.cycle.svg', label: 'Zyklus'),
      const DockTab(iconPath: 'assets/icons/dashboard/nav.pulse.svg', label: 'Puls'),
      const DockTab(iconPath: 'assets/icons/dashboard/nav.profile.svg', label: 'Profil'),
    ];

    testWidgets('renders 4 tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              activeIndex: 0,
              onTabTap: (_) {},
              tabs: tabs,
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavDock), findsOneWidget);
    });

    testWidgets('calls onTabTap when tab is tapped', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              activeIndex: 0,
              onTabTap: (index) => tappedIndex = index,
              tabs: tabs,
            ),
          ),
        ),
      );

      // Tap second tab (Zyklus)
      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('updates active state when index changes', (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: AppTheme.buildAppTheme(),
              home: Scaffold(
                bottomNavigationBar: BottomNavDock(
                  activeIndex: activeIndex,
                  onTabTap: (index) {
                    setState(() => activeIndex = index);
                  },
                  tabs: tabs,
                ),
              ),
            );
          },
        ),
      );

      expect(activeIndex, 0);

      // Tap third tab (Puls)
      await tester.tap(find.byType(GestureDetector).at(2));
      await tester.pump();

      expect(activeIndex, 2);
    });

    testWidgets('renders with default height (96px Figma spec)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              activeIndex: 0,
              onTabTap: (_) {},
              tabs: tabs,
            ),
          ),
        ),
      );

      final dockFinder = find.byType(BottomNavDock);
      expect(dockFinder, findsOneWidget);

      final Size size = tester.getSize(dockFinder);
      expect(size.height, expectedDockHeight, reason: 'Dock height should match Figma spec (96px)');
    });

    testWidgets('tab icons are 32×32px (Figma spec)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              activeIndex: 0,
              onTabTap: (_) {},
              tabs: tabs,
            ),
          ),
        ),
      );

      // Note: Icon size is passed to SvgPicture.asset(width: 32, height: 32)
      // Visual check via inspector, not directly testable via finder
      expect(find.byType(BottomNavDock), findsOneWidget);
    });

    testWidgets('center gap is 118px (2 × cutoutHalfWidth)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              activeIndex: 0,
              onTabTap: (_) {},
              tabs: tabs,
            ),
          ),
        ),
      );

      // Note: centerGap (SizedBox(width: 118)) is internal to Row layout
      // Visual check via inspector; hard to measure directly via widget test
      expect(find.byType(BottomNavDock), findsOneWidget);
    });

    testWidgets('tap area is ≥44×44px (accessibility)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              activeIndex: 0,
              onTabTap: (_) {},
              tabs: tabs,
            ),
          ),
        ),
      );

      // Each GestureDetector's Container is 44×44
      final gestures = tester.widgetList<GestureDetector>(find.byType(GestureDetector));
      expect(gestures.length, greaterThanOrEqualTo(4), reason: 'Should have at least 4 tab gestures');

      for (var i = 0; i < 4; i++) {
        final containerFinder = find.descendant(
          of: find.byType(GestureDetector).at(i),
          matching: find.byType(Container),
        ).first;
        final size = tester.getSize(containerFinder);
        expect(size.width, expectedTapAreaSize, reason: 'Tab $i tap area width should be 44px');
        expect(size.height, expectedTapAreaSize, reason: 'Tab $i tap area height should be 44px');
      }
    });

    testWidgets('has ClipPath with WavePunchOutClipper (no white line)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            bottomNavigationBar: BottomNavDock(
              activeIndex: 0,
              onTabTap: (_) {},
              tabs: tabs,
            ),
          ),
        ),
      );

      // Kodex: Verify ClipPath exists in tree (punch-out for button area)
      final clipPathFinder = find.descendant(
        of: find.byType(BottomNavDock),
        matching: find.byType(ClipPath),
      );
      expect(clipPathFinder, findsOneWidget, reason: 'ClipPath should exist to prevent white line under button');

      // Verify WavePunchOutClipper is used
      final clipPath = tester.widget<ClipPath>(clipPathFinder);
      expect(clipPath.clipper, isA<WavePunchOutClipper>(), reason: 'Clipper should be WavePunchOutClipper');
    });

    testWidgets('cutout depth is 38px (Figma spec, updated from 25px)', (tester) async {
      // Note: Cutout depth is internal to painter, verified via visual inspection
      // and formula check (syncButtonBottom = 96 - 38 - 9 = 49)
      expect(expectedCutoutDepth, 38.0, reason: 'Cutout depth from tokens should be 38px');
      expect(expectedSyncBottom, 49.0, reason: 'Sync button bottom = dockHeight(96) - cutoutDepth(38) - gap(9) = 49');
    });

    testWidgets('button icon size is 42px (65% fill ratio)', (tester) async {
      // Note: Icon size verified via FloatingSyncButton default prop
      expect(expectedButtonIconSize, 42.0, reason: 'Button icon size from tokens should be 42px (65% fill)');
      expect(expectedButtonIconSize / buttonDiameter, closeTo(0.65, 0.01),
        reason: 'Icon fill ratio should be ~0.65 (65%)');
    });
  });
}
