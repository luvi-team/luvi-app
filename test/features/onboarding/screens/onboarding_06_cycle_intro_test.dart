import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_cycle_intro.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding06CycleIntroScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Onboarding06CycleIntroScreen(),
      ));
      // Use pump() instead of pumpAndSettle() because CalendarMiniWidget
      // has an infinite pulsating animation that never completes
      await tester.pump();

      // Verify screen rendered
      expect(find.byType(Onboarding06CycleIntroScreen), findsOneWidget);
    });
  });
}
