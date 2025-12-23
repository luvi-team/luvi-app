import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

Future<void> _pumpHeader(
  WidgetTester tester, {
  required int step,
  required int totalSteps,
  VoidCallback? onBack,
  String? semanticsLabel,
  bool centerTitle = true,
  Locale locale = const Locale('de'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: OnboardingHeader(
          title: 'Ready for LUVI?',
          step: step,
          totalSteps: totalSteps,
          onBack: onBack ?? () {},
          semanticsLabel: semanticsLabel,
          centerTitle: centerTitle,
        ),
      ),
    ),
  );
}

void main() {
  TestConfig.ensureInitialized();
  testWidgets('renders header text, semantics, and step fraction', (
    tester,
  ) async {
    await _pumpHeader(
      tester,
      step: 1,
      totalSteps: 5,
      semanticsLabel: 'Custom header label',
    );

    expect(find.text('Ready for LUVI?'), findsOneWidget);
    // New format: "Frage X von Y" instead of "X/Y" - use L10n for locale-independence
    final context = tester.element(find.byType(OnboardingHeader));
    final l10n = AppLocalizations.of(context)!;
    expect(find.text(l10n.onboardingProgressLabel(1, 5)), findsOneWidget);
    // Back button is hidden on step 1 (correct behavior)
    expect(find.byType(BackButtonCircle), findsNothing);

    final headerSemanticsFinder = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.header == true,
    );
    final headerSemantics = tester.widget<Semantics>(headerSemanticsFinder);
    expect(headerSemantics.properties.label, 'Custom header label');

    final stepSemanticsFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Schritt 1 von 5',
    );
    expect(stepSemanticsFinder, findsOneWidget);
  });

  testWidgets('shows back button and respects spacing tokens after step 1', (
    tester,
  ) async {
    await _pumpHeader(tester, step: 3, totalSteps: 8);

    expect(find.byType(BackButtonCircle), findsOneWidget);

    // Combined SizedBox: touchTargetMin + Spacing.s on each side
    final combinedWidth = Sizes.touchTargetMin + Spacing.s;
    final spacingBoxes = find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.width == combinedWidth,
    );
    // Two combined spacing boxes wrap the progress bar on both sides.
    expect(spacingBoxes, findsNWidgets(2));
  });

  testWidgets('emits English semantics when locale is en', (tester) async {
    await _pumpHeader(
      tester,
      step: 1,
      totalSteps: 5,
      semanticsLabel: 'Custom header label',
      locale: const Locale('en'),
    );

    final stepSemanticsFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Step 1 of 5',
    );
    expect(stepSemanticsFinder, findsOneWidget);
  });
}
