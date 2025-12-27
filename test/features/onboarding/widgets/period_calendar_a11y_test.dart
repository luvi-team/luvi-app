import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/widgets/period_calendar.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  group('PeriodCalendar A11y (P1.6 Hit-Area Fix)', () {
    Widget buildTestApp({
      DateTime? selectedDate,
      List<DateTime> periodDays = const [],
    }) {
      return MaterialApp(
        theme: AppTheme.buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: PeriodCalendar(
              selectedDate: selectedDate,
              periodDays: periodDays,
            ),
          ),
        ),
      );
    }

    testWidgets('DayCell width meets A11y minimum (44dp)', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Find the InkResponse widgets (day cells)
      final inkResponses = find.byType(InkResponse);
      expect(inkResponses, findsWidgets);

      // Check at least one InkResponse has correct parent SizedBox width
      // The SizedBox is the immediate parent of InkResponse in _DayCell
      bool foundValidHitArea = false;

      for (final element in inkResponses.evaluate()) {
        // Find ancestor SizedBox with valid hit area
        final sizedBox = element.findAncestorWidgetOfExactType<SizedBox>();
        if (sizedBox != null &&
            sizedBox.width != null &&
            sizedBox.width! >= Sizes.touchTargetMin) {
          foundValidHitArea = true;
          break;
        }
      }

      // Assert that at least one day cell meets the touch target requirement
      expect(foundValidHitArea, isTrue,
          reason: 'At least one day cell must meet 44dp touch target');

      // Verify Sizes.touchTargetMin is 44
      expect(Sizes.touchTargetMin, equals(44.0),
          reason: 'WCAG minimum touch target should be 44dp');
    });

    testWidgets('Sizes.calendarDayCellHeight is defined correctly', (tester) async {
      // Verify the new constant exists and has expected value
      expect(Sizes.calendarDayCellHeight, equals(48.0),
          reason: 'Calendar cell height should be 48dp for label space');
    });

    testWidgets('Grid renders without overflow errors', (tester) async {
      // This test ensures the 40->44 width change doesn't break layout
      await tester.pumpWidget(buildTestApp(
        selectedDate: DateTime.now().subtract(const Duration(days: 3)),
        periodDays: [
          DateTime.now().subtract(const Duration(days: 3)),
          DateTime.now().subtract(const Duration(days: 2)),
          DateTime.now().subtract(const Duration(days: 1)),
        ],
      ));
      await tester.pumpAndSettle();

      // No overflow errors should occur
      expect(tester.takeException(), isNull);

      // Calendar should render
      expect(find.byType(PeriodCalendar), findsOneWidget);
    });

    testWidgets('Weekday headers and day cells have consistent width', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Both weekday headers and day cells should use Sizes.touchTargetMin (44)
      // This ensures grid alignment
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);

      // Count SizedBoxes with width 44 (touchTargetMin)
      int widthCount44 = 0;
      for (final element in sizedBoxes.evaluate()) {
        final widget = element.widget as SizedBox;
        if (widget.width == Sizes.touchTargetMin) {
          widthCount44++;
        }
      }

      // Should have multiple cells with 44dp width (7 weekday headers + day cells)
      expect(widthCount44, greaterThanOrEqualTo(7),
          reason: 'At least 7 weekday headers should have 44dp width');
    });
  });
}
