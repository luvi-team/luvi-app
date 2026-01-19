import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_back_button.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('AuthBackButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthBackButton(
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AuthBackButton));
      expect(pressed, isTrue);
    });

    testWidgets('uses localized semantics label by default', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthBackButton(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Semantics should have a label (from L10n or fallback)
      final semantics = tester.getSemantics(find.byType(AuthBackButton));
      expect(semantics.label, isNotEmpty);
    });

    testWidgets('uses custom semanticsLabel when provided', (tester) async {
      const customLabel = 'Custom Back Label';

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthBackButton(
                onPressed: () {},
                semanticsLabel: customLabel,
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AuthBackButton));
      expect(semantics.label, customLabel);
    });

    testWidgets('has correct touch target size (44dp)', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthBackButton(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AuthBackButton));
      // Touch target should be at least 44dp (WCAG / iOS HIG)
      expect(size.width, greaterThanOrEqualTo(44.0));
      expect(size.height, greaterThanOrEqualTo(44.0));
    });
  });
}
