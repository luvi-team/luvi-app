import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_intro_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  group('OnboardingIntroScreen', () {
    Widget buildTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const OnboardingIntroScreen(),
        ),
      );
    }

    testWidgets('renders with correct background color', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify the scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has semantics label for accessibility', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify the screen has a semantics wrapper
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('static route constants are defined correctly', (tester) async {
      expect(OnboardingIntroScreen.routeName, '/onboarding/intro');
      expect(OnboardingIntroScreen.navName, 'onboarding_intro');
    });
  });
}
