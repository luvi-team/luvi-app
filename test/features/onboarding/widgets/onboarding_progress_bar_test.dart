import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_progress_bar.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

Future<void> _pumpProgressBar(
  WidgetTester tester, {
  required int currentStep,
  required int totalSteps,
  Locale locale = const Locale('de'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: OnboardingProgressBar(
          currentStep: currentStep,
          totalSteps: totalSteps,
        ),
      ),
    ),
  );
}

void main() {
  TestConfig.ensureInitialized();

  testWidgets('renders with correct size', (tester) async {
    await _pumpProgressBar(tester, currentStep: 1, totalSteps: 5);

    final sizedBox = find.byType(SizedBox).first;
    final widget = tester.widget<SizedBox>(sizedBox);

    expect(widget.width, Sizes.progressBarWidth); // 307px (Figma v2)
    expect(widget.height, 18);
  });

  testWidgets('shows correct progress for step 1 of 5', (tester) async {
    await _pumpProgressBar(tester, currentStep: 1, totalSteps: 5);

    final fractionBox = find.byType(FractionallySizedBox);
    expect(fractionBox, findsOneWidget);

    final widget = tester.widget<FractionallySizedBox>(fractionBox);
    expect(widget.widthFactor, closeTo(0.2, 0.01)); // 1/5 = 0.2
  });

  testWidgets('shows full progress for last step', (tester) async {
    await _pumpProgressBar(tester, currentStep: 7, totalSteps: 7);

    final fractionBox = find.byType(FractionallySizedBox);
    final widget = tester.widget<FractionallySizedBox>(fractionBox);

    expect(widget.widthFactor, closeTo(1.0, 0.01)); // 7/7 = 1.0
  });

  testWidgets('has correct semantics in German', (tester) async {
    await _pumpProgressBar(
      tester,
      currentStep: 2,
      totalSteps: 8,
      locale: const Locale('de'),
    );

    // German: "Frage 2 von 8"
    final semantics = find.bySemanticsLabel('Frage 2 von 8');
    expect(semantics, findsOneWidget);
  });

  testWidgets('has correct semantics in English', (tester) async {
    await _pumpProgressBar(
      tester,
      currentStep: 3,
      totalSteps: 6,
      locale: const Locale('en'),
    );

    // English: "Question 3 of 6"
    final semantics = find.bySemanticsLabel('Question 3 of 6');
    expect(semantics, findsOneWidget);
  });
}
