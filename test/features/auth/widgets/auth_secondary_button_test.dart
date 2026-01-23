import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_secondary_button.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('AuthSecondaryButton', () {
    testWidgets('renders with default height from metrics', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthSecondaryButton(
                label: 'Test',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AuthSecondaryButton));
      expect(size.height, AuthRebrandMetrics.buttonHeight);
    });

    testWidgets('respects custom height parameter', (tester) async {
      const customHeight = 60.0;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthSecondaryButton(
                label: 'Test',
                onPressed: () {},
                height: customHeight,
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AuthSecondaryButton));
      expect(size.height, customHeight);
    });

    testWidgets('respects custom width parameter', (tester) async {
      const customWidth = 200.0;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthSecondaryButton(
                label: 'Test',
                onPressed: () {},
                width: customWidth,
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AuthSecondaryButton));
      expect(size.width, customWidth);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthSecondaryButton(
                label: 'Test',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AuthSecondaryButton));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      // Use semantics-based testing to avoid coupling to internal widget types
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: AuthSecondaryButton(
                  label: 'Test',
                  onPressed: null,
                ),
              ),
            ),
          ),
        );

        // Test via accessibility semantics tree (not widget tree)
        final semantics = tester.getSemantics(find.byType(AuthSecondaryButton));
        expect(semantics.flagsCollection.isEnabled, isFalse);
      } finally {
        handle.dispose();
      }
    });
  });
}
