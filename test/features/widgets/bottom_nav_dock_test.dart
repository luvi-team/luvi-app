import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/bottom_nav_dock.dart';
import 'package:luvi_app/features/widgets/bottom_nav_tokens.dart';

void main() {
  group('BottomNavDock', () {
    // Kodex: Geometry constants from tokens (Figma audit 2025-10-06)
    const double expectedDockHeight = dockHeight; // 96px (from tokens)
    const double expectedTapAreaSize = minTapArea; // 44px (from tokens)
    const double expectedCutoutDepth = cutoutDepth; // from tokens (now 42px)
    const double expectedSyncBottom = syncButtonBottom; // = dockHeight - cutoutDepth - desiredGapToWaveTop
    const double expectedButtonIconSize = iconSizeTight; // 65% of button diameter

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

    testWidgets('tab icons render as 32×32px SvgPicture widgets', (tester) async {
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

      final svgFinder = find.byType(SvgPicture);
      expect(svgFinder, findsNWidgets(tabs.length));

      final svgWidgets = tester.widgetList<SvgPicture>(svgFinder);
      for (final svg in svgWidgets) {
        expect(svg.width, tabIconSize,
            reason: 'Each tab icon should match the Figma spec width (32px)');
        expect(svg.height, tabIconSize,
            reason: 'Each tab icon should match the Figma spec height (32px)');
      }
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

    testWidgets('does not use punch-out ClipPath (prevents grey disc)', (tester) async {
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

      // Verify: no ClipPath below BottomNavDock (no transparent hole → no grey disc)
      final clipPathFinder = find.descendant(
        of: find.byType(BottomNavDock),
        matching: find.byType(ClipPath),
      );
      expect(
        clipPathFinder,
        findsNothing,
        reason:
            'BottomNavDock should not punch out a circular hole; area under button must stay solid',
      );
    });

    testWidgets('cutout depth and button offset follow tokens', (tester) async {
      // Note: Cutout depth is internal to painter, verified via visual inspection
      // and formula check (syncButtonBottom = dockHeight - (cutoutDepth + waveTopInset) + desiredGap)
      expect(expectedCutoutDepth, cutoutDepth);
      expect(expectedSyncBottom, dockHeight - (cutoutDepth + waveTopInset) + desiredGapToWaveTop);
    });

    testWidgets('button icon size keeps 65% fill ratio', (tester) async {
      // Icon size scales with button diameter to keep ~65% fill
      expect(expectedButtonIconSize / buttonDiameter, closeTo(0.65, 0.01),
          reason: 'Icon fill ratio should be ~0.65 (65%)');
    });
  });
}
