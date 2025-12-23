import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/features/onboarding/widgets/calendar_mini_widget.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('CalendarMiniWidget', () {
    // Test 1: Render
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Scaffold(body: CalendarMiniWidget()),
      ));
      await tester.pump(); // Animation läuft - kein pumpAndSettle

      expect(find.byType(CalendarMiniWidget), findsOneWidget);
    });

    // Test 2: 31 Days Display
    testWidgets('displays all 31 days', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Scaffold(body: CalendarMiniWidget()),
      ));
      await tester.pump();

      for (int day = 1; day <= 31; day++) {
        expect(find.text('$day'), findsOneWidget);
      }
    });

    // Test 3: Highlighted Day Color (default: 25)
    testWidgets('highlighted day has signature color', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Scaffold(body: CalendarMiniWidget(highlightedDay: 25)),
      ));
      await tester.pump();

      final textWidget = tester.widget<Text>(find.text('25'));
      expect(textWidget.style?.color, DsColors.signature);
    });

    // Test 4: Period Range Color (days > highlightedDay)
    testWidgets('period range days have signature color', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Scaffold(body: CalendarMiniWidget(highlightedDay: 25)),
      ));
      await tester.pump();

      // Days 26-31 should have signature color
      for (final day in [26, 27, 28, 29, 30, 31]) {
        final textWidget = tester.widget<Text>(find.text('$day'));
        expect(textWidget.style?.color, DsColors.signature,
            reason: 'Day $day should have signature color');
      }
    });

    // Test 5: Normal Day Color (days < highlightedDay)
    testWidgets('normal days have grayscale black color', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Scaffold(body: CalendarMiniWidget(highlightedDay: 25)),
      ));
      await tester.pump();

      // Days before highlighted should have grayscale black
      for (final day in [1, 10, 15, 24]) {
        final textWidget = tester.widget<Text>(find.text('$day'));
        expect(textWidget.style?.color, DsColors.grayscaleBlack,
            reason: 'Day $day should have grayscale black color');
      }
    });

    // Test 6: Semantics Label (Fix 5: specific to CalendarMiniWidget)
    testWidgets('has accessibility semantics label', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Scaffold(body: CalendarMiniWidget()),
      ));
      await tester.pump();

      // Verify CalendarMiniWidget exists
      final calendarWidget = find.byType(CalendarMiniWidget);
      expect(calendarWidget, findsOneWidget);

      // Verify CalendarMiniWidget has Semantics descendant with non-null label
      final semanticsWidget = find.descendant(
        of: calendarWidget,
        matching: find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label != null,
        ),
      );
      expect(semanticsWidget, findsOneWidget);
    });
  });
}
