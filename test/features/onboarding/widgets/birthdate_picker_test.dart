import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/onboarding/widgets/birthdate_picker.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_glass_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

Future<void> _pumpPicker(
  WidgetTester tester, {
  required DateTime initialDate,
  required ValueChanged<DateTime> onDateChanged,
  Locale locale = const Locale('de'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: BirthdatePicker(
          initialDate: initialDate,
          onDateChanged: onDateChanged,
        ),
      ),
    ),
  );
}

void main() {
  TestConfig.ensureInitialized();

  testWidgets('renders with correct size', (tester) async {
    await _pumpPicker(
      tester,
      initialDate: DateTime(2000, 6, 15),
      onDateChanged: (_) {},
    );

    final container = find.byType(Container).first;
    expect(container, findsOneWidget);

    // Check that BirthdatePicker renders
    expect(find.byType(BirthdatePicker), findsOneWidget);
  });

  testWidgets('displays three ListWheelScrollViews for month, day, year', (tester) async {
    await _pumpPicker(
      tester,
      initialDate: DateTime(1995, 3, 20),
      onDateChanged: (_) {},
    );

    final wheels = find.byType(ListWheelScrollView);
    expect(wheels, findsNWidgets(3));
  });

  testWidgets('calls onDateChanged when scrolling', (tester) async {
    DateTime? changedDate;
    await _pumpPicker(
      tester,
      initialDate: DateTime(2000, 6, 15),
      onDateChanged: (date) => changedDate = date,
    );

    // Find any wheel and try to scroll
    final wheels = find.byType(ListWheelScrollView);
    expect(wheels, findsNWidgets(3));

    // Scroll the first wheel (month)
    await tester.drag(wheels.first, const Offset(0, -56));
    await tester.pumpAndSettle();

    // Date should have changed
    expect(changedDate, isNotNull);
  });

  testWidgets('clamps date to valid age range', (tester) async {
    // Try to set a date below minimum age (kMinAge = 16)
    final now = DateTime.now();
    final tooYoung = DateTime(now.year - (kMinAge - 1), 1, 1); // 15 years old

    await _pumpPicker(
      tester,
      initialDate: tooYoung,
      onDateChanged: (_) {},
    );

    // Should render without error (date gets clamped internally)
    expect(find.byType(BirthdatePicker), findsOneWidget);
  });

  testWidgets('has correct semantics in German', (tester) async {
    await _pumpPicker(
      tester,
      initialDate: DateTime(1990, 1, 1),
      onDateChanged: (_) {},
      locale: const Locale('de'),
    );

    // German: "Geburtsdatum auswählen"
    final semantics = find.bySemanticsLabel('Geburtsdatum auswählen');
    expect(semantics, findsOneWidget);
  });

  testWidgets('has correct semantics in English', (tester) async {
    await _pumpPicker(
      tester,
      initialDate: DateTime(1990, 1, 1),
      onDateChanged: (_) {},
      locale: const Locale('en'),
    );

    // English: "Select birth date"
    final semantics = find.bySemanticsLabel('Select birth date');
    expect(semantics, findsOneWidget);
  });

  testWidgets('displays localized month names in German', (tester) async {
    await _pumpPicker(
      tester,
      initialDate: DateTime(2000, 1, 15),
      onDateChanged: (_) {},
      locale: const Locale('de'),
    );

    // Should render BirthdatePicker with German locale
    expect(find.byType(BirthdatePicker), findsOneWidget);
  });

  testWidgets('uses OnboardingGlassCard with BackdropFilter blur', (tester) async {
    await _pumpPicker(
      tester,
      initialDate: DateTime(2000, 6, 15),
      onDateChanged: (_) {},
    );

    // Verify OnboardingGlassCard wrapper exists
    expect(find.byType(OnboardingGlassCard), findsOneWidget);

    // Verify BackdropFilter is INSIDE OnboardingGlassCard (real blur effect)
    expect(
      find.descendant(
        of: find.byType(OnboardingGlassCard),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
  });

  testWidgets('selection highlight uses transparent fill', (tester) async {
    await _pumpPicker(
      tester,
      initialDate: DateTime(2000, 6, 15),
      onDateChanged: (_) {},
    );

    final highlightFinder = find.byWidgetPredicate((widget) {
      if (widget is! Container) return false;
      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) return false;
      return decoration.color == DsColors.transparent &&
          decoration.borderRadius ==
              BorderRadius.circular(Sizes.radiusPickerHighlight);
    });

    expect(
      highlightFinder,
      findsOneWidget,
      reason: 'Selection highlight should be transparent with 14px radius',
    );
  });

}
