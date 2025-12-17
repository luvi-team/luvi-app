import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_04_goals.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding04GoalsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Onboarding04GoalsScreen(),
      ));
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(Onboarding04GoalsScreen), findsOneWidget);
    });
  });
}
