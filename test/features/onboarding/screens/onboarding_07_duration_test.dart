import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
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
  });
}
