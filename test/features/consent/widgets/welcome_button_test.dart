import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('WelcomeButton', () {
    testWidgets('renders with correct label', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Test Label',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('triggers onPressed callback when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Tap me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('uses Design System token colors', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;

      // Verify backgroundColor resolves to welcomeButtonBg
      final bgColor = style.backgroundColor?.resolve({});
      expect(bgColor, equals(DsColors.welcomeButtonBg));

      // Verify foregroundColor resolves to welcomeButtonText
      final fgColor = style.foregroundColor?.resolve({});
      expect(fgColor, equals(DsColors.welcomeButtonText));
    });

    testWidgets('has pill-shaped border radius with correct Design Token value', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;
      final shape = style.shape?.resolve({}) as RoundedRectangleBorder?;

      expect(shape, isNotNull);
      // Verify actual Design Token value (Sizes.radiusWelcomeButton = 40.0)
      expect(
        shape!.borderRadius,
        equals(BorderRadius.circular(Sizes.radiusWelcomeButton)),
      );
    });
  });
}
