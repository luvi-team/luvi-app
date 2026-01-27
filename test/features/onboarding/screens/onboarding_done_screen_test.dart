import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_done_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('OnboardingDoneScreen', () {
    testWidgets('renders completion text in center', (tester) async {
      await tester.pumpWidget(
        buildTestApp(home: const OnboardingDoneScreen()),
      );
      await tester.pump();

      final context = tester.element(find.byType(OnboardingDoneScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.text(l10n.onboardingComplete), findsOneWidget);
    });

    test('has correct route constants', () {
      expect(OnboardingDoneScreen.routeName, '/onboarding/done');
      expect(OnboardingDoneScreen.navName, 'onboarding_done');
    });
  });
}
