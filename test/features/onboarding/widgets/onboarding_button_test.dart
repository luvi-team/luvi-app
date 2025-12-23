import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import '../../../support/test_config.dart';

Future<void> _pumpButton(
  WidgetTester tester, {
  required String label,
  VoidCallback? onPressed,
  bool isEnabled = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: OnboardingButton(
          label: label,
          onPressed: onPressed,
          isEnabled: isEnabled,
        ),
      ),
    ),
  );
}

void main() {
  TestConfig.ensureInitialized();

  testWidgets('renders label text', (tester) async {
    await _pumpButton(tester, label: 'Continue', onPressed: () {});

    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('enabled button has primary color', (tester) async {
    await _pumpButton(tester, label: 'Test', onPressed: () {});

    final animatedContainer = find.byType(AnimatedContainer);
    expect(animatedContainer, findsOneWidget);

    final container = tester.widget<AnimatedContainer>(animatedContainer);
    final decoration = container.decoration;
    expect(decoration, isA<BoxDecoration>());
    final boxDecoration = decoration as BoxDecoration;
    expect(boxDecoration.color, DsColors.buttonPrimary);
  });

  testWidgets('disabled button has gray color', (tester) async {
    await _pumpButton(tester, label: 'Test', isEnabled: false);

    final animatedContainer = find.byType(AnimatedContainer);
    final container = tester.widget<AnimatedContainer>(animatedContainer);
    final decoration = container.decoration;
    expect(decoration, isA<BoxDecoration>());
    final boxDecoration = decoration as BoxDecoration;
    expect(boxDecoration.color, DsColors.gray300);
  });

  testWidgets('calls onPressed when tapped and enabled', (tester) async {
    bool tapped = false;
    await _pumpButton(
      tester,
      label: 'Tap Me',
      onPressed: () => tapped = true,
    );

    await tester.tap(find.byType(OnboardingButton));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('does not call onPressed when disabled', (tester) async {
    bool tapped = false;
    await _pumpButton(
      tester,
      label: 'Disabled',
      onPressed: () => tapped = true,
      isEnabled: false,
    );

    await tester.tap(find.byType(OnboardingButton));
    await tester.pump();

    expect(tapped, isFalse);
  });

  testWidgets('has correct semantics with button role and label', (tester) async {
    await _pumpButton(tester, label: 'Continue', onPressed: () {});

    // Should find semantics with button role
    final buttonSemantics = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.button == true,
    );
    expect(buttonSemantics, findsOneWidget);

    // Should find semantics with the correct label
    final labelSemantics = find.bySemanticsLabel('Continue');
    expect(labelSemantics, findsOneWidget);
  });
}
