import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/onboarding/widgets/period_calendar.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding07DurationScreen', () {
    testWidgets('renders without errors', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding06PeriodScreen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 06')),
          ),
          GoRoute(
            path: Onboarding07DurationScreen.routeName,
            builder: (context, state) => const Onboarding07DurationScreen(),
          ),
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Success Screen')),
          ),
        ],
        initialLocation: Onboarding07DurationScreen.routeName,
      );

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(Onboarding07DurationScreen), findsOneWidget);
    });

    testWidgets('displays PeriodCalendar widget', (tester) async {
      // Use a deterministic start date (3 days ago)
      final startDate = DateTime.now().subtract(const Duration(days: 3));

      final router = GoRouter(
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

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify PeriodCalendar is displayed
      expect(find.byType(PeriodCalendar), findsOneWidget);
    });

    testWidgets('calendar contains tappable day cells with InkResponse',
        (tester) async {
      final startDate = DateTime.now().subtract(const Duration(days: 3));

      final router = GoRouter(
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

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify InkResponse widgets exist (day cells use InkResponse for tap UX)
      expect(find.byType(InkResponse), findsWidgets);
    });

    testWidgets('tapping earlier day shortens period range (state change)',
        (tester) async {
      // Deterministisches Datum: 10 Tage vor heute für stabilen Test
      final startDate = DateTime.now().subtract(const Duration(days: 10));

      final router = GoRouter(
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

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Zähle Periodentage via Semantics-Label (robust, unabhängig von Monat)
      final periodDayPattern = RegExp(r'Periodentag');
      int countPeriodDays() {
        return find.bySemanticsLabel(periodDayPattern).evaluate().length;
      }

      final beforeCount = countPeriodDays();
      // Default periodDuration ist 5 Tage → erwarte mindestens 3 Periodentage
      expect(beforeCount, greaterThanOrEqualTo(3));

      // Finde Tag 2 nach startDate via Semantics-Label (robust, exaktes Datum)
      // Format: "17. Dezember 2024, Periodentag" (per period_calendar.dart)
      final targetDate = startDate.add(const Duration(days: 1));
      final formattedDate = DateFormat('d. MMMM yyyy', 'de').format(targetDate);
      final targetSemantics = RegExp('$formattedDate, Periodentag');
      final dayFinder = find.bySemanticsLabel(targetSemantics);

      // Test MUSS fehlschlagen wenn kein Tag gefunden wird (kein if-Safeguard)
      expect(dayFinder, findsOneWidget,
          reason: 'Target period day must be found by Semantics label');

      await tester.tap(dayFinder);
      await tester.pumpAndSettle();

      // Nach Tap: weniger Periodentage
      final afterCount = countPeriodDays();
      expect(afterCount, lessThan(beforeCount),
          reason: 'Tapping earlier day should shorten period range');

      // Screen sollte noch da sein (kein Crash)
      expect(find.byType(Onboarding07DurationScreen), findsOneWidget);
    });
  });
}
