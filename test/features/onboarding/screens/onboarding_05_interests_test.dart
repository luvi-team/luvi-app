import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Onboarding05InterestsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestApp(
        home: const Onboarding05InterestsScreen(),
      ));
      await tester.pumpAndSettle();

      // Verify screen rendered
      expect(find.byType(Onboarding05InterestsScreen), findsOneWidget);
    });
  });
}
