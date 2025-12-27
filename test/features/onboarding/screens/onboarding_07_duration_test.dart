import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/onboarding/widgets/period_calendar.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

// Deterministic base date for flaky tests (mid-December 2025)
// Used instead of DateTime.now() to prevent month-boundary flakiness
final _baseDate = DateTime(2025, 12, 15);

/// Creates a test router for Onboarding07DurationScreen tests.
/// Extracted to reduce duplication across test cases.
GoRouter _createTestRouter(DateTime startDate) {
  return GoRouter(
    routes: [
      GoRoute(
        path: Onboarding06PeriodScreen.routeName,
        builder: (context, state) =>
            const Scaffold(body: Text('Onboarding 06')),
      ),
      GoRoute(
        path: Onboarding07DurationScreen.routeName,
        builder: (context, state) => Onboarding07DurationScreen(
          periodStartDate: startDate,
        ),
      ),
      GoRoute(
        path: OnboardingSuccessScreen.routeName,
        builder: (context, state) =>
            const Scaffold(body: Text('Success Screen')),
      ),
    ],
    initialLocation: Onboarding07DurationScreen.routeName,
  );
}

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding07DurationScreen', () {
    testWidgets('renders without errors', (tester) async {
      // Deterministic date: Fixed date for stable test (mid-December 2025)
      final startDate = DateTime(2025, 12, 15);
      final router = _createTestRouter(startDate);
      addTearDown(router.dispose);

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(Onboarding07DurationScreen), findsOneWidget);
    });

    testWidgets('displays PeriodCalendar widget', (tester) async {
      // Deterministic date: Fixed date for stable test (mid-December 2025)
      final startDate = DateTime(2025, 12, 12);
      final router = _createTestRouter(startDate);
      addTearDown(router.dispose);

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify PeriodCalendar is displayed
      expect(find.byType(PeriodCalendar), findsOneWidget);
    });

    testWidgets('calendar contains tappable day cells with InkResponse',
        (tester) async {
      // Deterministic date: Fixed date for stable test (mid-December 2025)
      final startDate = DateTime(2025, 12, 12);
      final router = _createTestRouter(startDate);
      addTearDown(router.dispose);

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify InkResponse widgets exist (day cells use InkResponse for tap UX)
      expect(find.byType(InkResponse), findsWidgets);
    });

    testWidgets('tapping earlier day shortens period range (state change)',
        (tester) async {
      // Deterministic date (10 days before _baseDate) to ensure calendar shows correct month
      // This test requires period days to be visible and tappable
      final startDate = _baseDate.subtract(const Duration(days: 10));
      final router = _createTestRouter(startDate);
      addTearDown(router.dispose);

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Count period days via semantics label (robust, month-independent)
      final periodDayPattern = RegExp(r'Periodentag');
      int countPeriodDays() {
        return find.bySemanticsLabel(periodDayPattern).evaluate().length;
      }

      final beforeCount = countPeriodDays();
      // Default periodDuration is 5 days → expect at least 3 period days
      expect(beforeCount, greaterThanOrEqualTo(3));

      // Find day 1 after startDate via semantics label (robust, exact date)
      // Format: "d. MMMM yyyy, Periodentag" — e.g., "6. Dezember 2025, Periodentag"
      final targetDate = startDate.add(const Duration(days: 1));
      final formattedDate = DateFormat('d. MMMM yyyy', 'de').format(targetDate);
      final targetSemantics = RegExp('$formattedDate, Periodentag');
      final dayFinder = find.bySemanticsLabel(targetSemantics);

      // Test MUST fail if no day found (no if-safeguard)
      expect(dayFinder, findsOneWidget,
          reason: 'Target period day must be found by Semantics label');

      await tester.tap(dayFinder);
      await tester.pumpAndSettle();

      // After tap: fewer period days
      final afterCount = countPeriodDays();
      expect(afterCount, lessThan(beforeCount),
          reason: 'Tapping earlier day should shorten period range');

      // Screen should still be present (no crash)
      expect(find.byType(Onboarding07DurationScreen), findsOneWidget);
    });

    testWidgets(
      'period duration is limited by kMaxPeriodDuration constant',
      (tester) async {
        // Deterministic date: Fixed date for stable test (mid-December 2025)
        final startDate = DateTime(2025, 12, 5);
        final router = _createTestRouter(startDate);
        addTearDown(router.dispose);

        await tester.pumpWidget(buildTestApp(router: router));
        await tester.pumpAndSettle();

        // Count period days via semantics label (robust, month-independent)
        final periodDayPattern = RegExp(r'Periodentag');
        int countPeriodDays() {
          return find.bySemanticsLabel(periodDayPattern).evaluate().length;
        }

        final initialCount = countPeriodDays();

        // Verify kMaxPeriodDuration constant value
        expect(kMaxPeriodDuration, equals(14),
            reason: 'kMaxPeriodDuration should be 14 days');

        // Verify period cannot exceed kMaxPeriodDuration
        // (implementation enforces this in _handlePeriodEndChanged)
        expect(initialCount, lessThanOrEqualTo(kMaxPeriodDuration),
            reason: 'Period days should not exceed kMaxPeriodDuration');
      },
    );
  });
}
