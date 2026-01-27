import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_done_screen.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('OnboardingDoneScreen', () {
    testWidgets('renders completion text in center', (tester) async {
      await tester.pumpWidget(
        buildTestApp(home: const OnboardingDoneScreen()),
      );

      // Verify Center and Text widgets are present
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('has correct route constants', (tester) async {
      // Verify static route constants are defined correctly
      expect(OnboardingDoneScreen.routeName, '/onboarding/done');
      expect(OnboardingDoneScreen.navName, 'onboarding_done');
    });
  });
}
