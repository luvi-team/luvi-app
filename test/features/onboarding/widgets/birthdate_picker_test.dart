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

  testWidgets('renders correctly', (tester) async {
    await _pumpPicker(
      tester,
      initialDate: DateTime(2000, 6, 15),
      onDateChanged: (_) {},
    );

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
    // Wheel item height matches _itemExtent in BirthdatePicker
    const double wheelItemHeight = 56;

    DateTime? changedDate;
    await _pumpPicker(
      tester,
      initialDate: DateTime(2000, 6, 15),
      onDateChanged: (date) => changedDate = date,
    );

    // Find any wheel and try to scroll
    final wheels = find.byType(ListWheelScrollView);
    expect(wheels, findsNWidgets(3));

    // Scroll the first wheel (month) by one item (drag UP = forward in list)
    await tester.drag(wheels.first, const Offset(0, -wheelItemHeight));
    await tester.pumpAndSettle();

    // Date should have changed
    expect(changedDate, isNotNull);
    // Verify the month actually changed (scrolled forward by one)
    // Initial: June 2000 (month 6) → After scroll: July 2000 (month 7)
    expect(changedDate!.year, 2000, reason: 'Year should remain unchanged');
    expect(changedDate!.month, 7, reason: 'Month should advance from June to July');
    expect(changedDate!.day, 15, reason: 'Day should remain unchanged');
  });

  testWidgets('clamps date to valid age range', (tester) async {
    // Try to set a date below minimum age (kMinAge = 16)
    final now = DateTime.now();
    final tooYoung = DateTime(now.year - (kMinAge - 1), 1, 1); // 15 years old
    final expectedClampedYear = now.year - kMinAge; // Maximum allowed birth year

    await _pumpPicker(
      tester,
      initialDate: tooYoung,
      onDateChanged: (_) {},
    );

    // Widget renders without error - this verifies the clamping logic works.
    // The widget's _clampDate() method is exercised during initState.
    // If clamping failed, the controller would receive an invalid index
    // and the widget would fail to render properly.
    expect(find.byType(BirthdatePicker), findsOneWidget);

    // Verify three wheels are present (clamped date is displayed correctly)
    final wheels = find.byType(ListWheelScrollView);
    expect(wheels, findsNWidgets(3));

    // Verify the year was clamped to the maximum allowed (minimum age boundary)
    // The clamped year should be visible in the year wheel
    expect(
      find.text('$expectedClampedYear'),
      findsWidgets,
      reason: 'Clamped year $expectedClampedYear should be visible in year wheel',
    );
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

    await tester.pumpAndSettle();

    // Primary assertion: German month "Januar" should be in widget tree
    // ListWheelScrollView renders visible items, January should be visible
    expect(find.text('Januar'), findsWidgets);

    // Verify NOT English (proves German locale is active)
    expect(find.text('January'), findsNothing);
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
