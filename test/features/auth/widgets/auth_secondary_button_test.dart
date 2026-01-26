import 'dart:ui' show Tristate;

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

      // Pre-condition: verify test isolation
      expect(pressed, isFalse, reason: 'pressed should be false before tap');

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

        // Full semantics assertions for disabled button state
        // Flutter 3.38+: isEnabled returns Tristate, not bool
        final semantics = tester.getSemantics(find.byType(AuthSecondaryButton));
        expect(
          semantics.flagsCollection.isEnabled,
          Tristate.isFalse,
          reason: 'Disabled button should report isEnabled=Tristate.isFalse',
        );
        expect(
          semantics.flagsCollection.isButton,
          isTrue,
          reason: 'Widget should identify as button for accessibility',
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthSecondaryButton(
                label: 'Test',
                onPressed: () {},
                isLoading: true,
                loadingKey: const ValueKey('loading_indicator'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('loading_indicator')), findsOneWidget);
    });

    testWidgets('announces loadingSemanticLabel during loading',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: AuthSecondaryButton(
                  label: 'Test',
                  onPressed: () {},
                  isLoading: true,
                  loadingSemanticLabel: 'Processing request...',
                ),
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AuthSecondaryButton));
        expect(semantics.label, 'Processing request...');
      } finally {
        handle.dispose();
      }
    });
  });
}
