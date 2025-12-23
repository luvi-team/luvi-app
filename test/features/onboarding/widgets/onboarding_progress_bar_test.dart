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
  double parentWidth = 400.0, // Default parent width for testing
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: parentWidth,
            child: OnboardingProgressBar(
              currentStep: currentStep,
              totalSteps: totalSteps,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestConfig.ensureInitialized();

  testWidgets('renders with responsive size (80% of parent, max 307px)',
      (tester) async {
    // Parent width 400px -> 80% = 320px, but capped at max 307px
    await _pumpProgressBar(tester, currentStep: 1, totalSteps: 5);

    // Find the inner SizedBox created by the progress bar (inside LayoutBuilder)
    final sizedBoxes = find.byType(SizedBox);
    // The progress bar creates a SizedBox inside LayoutBuilder
    // We need to find the one with the calculated width
    SizedBox? progressBarSizedBox;
    for (final element in sizedBoxes.evaluate()) {
      final widget = element.widget as SizedBox;
      if (widget.height == Sizes.progressBarHeight) {
        progressBarSizedBox = widget;
        break;
      }
    }

    expect(progressBarSizedBox, isNotNull);
    // 400 * 0.8 = 320, clamped to max 307
    expect(progressBarSizedBox!.width, Sizes.progressBarMaxWidth);
    expect(progressBarSizedBox.height, Sizes.progressBarHeight);
  });

  testWidgets('renders smaller width for narrow parent', (tester) async {
    // Parent width 300px -> 80% = 240px (below max, so no clamping)
    await _pumpProgressBar(
      tester,
      currentStep: 1,
      totalSteps: 5,
      parentWidth: 300.0,
    );

    SizedBox? progressBarSizedBox;
    for (final element in find.byType(SizedBox).evaluate()) {
      final widget = element.widget as SizedBox;
      if (widget.height == Sizes.progressBarHeight) {
        progressBarSizedBox = widget;
        break;
      }
    }

    expect(progressBarSizedBox, isNotNull);
    // 300 * 0.8 = 240px
    expect(progressBarSizedBox!.width, closeTo(240.0, 0.1));
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
