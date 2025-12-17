import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding06PeriodScreen', () {
    testWidgets('renders without errors', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: Onboarding05InterestsScreen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 05')),
          ),
          GoRoute(
            path: Onboarding06PeriodScreen.routeName,
            builder: (context, state) => const Onboarding06PeriodScreen(),
          ),
          GoRoute(
            path: Onboarding07DurationScreen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Onboarding 07')),
          ),
        ],
        initialLocation: Onboarding06PeriodScreen.routeName,
      );

      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(Onboarding06PeriodScreen), findsOneWidget);
    });
  });
}
