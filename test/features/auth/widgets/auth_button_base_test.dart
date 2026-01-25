import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_button_base.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('AuthButtonBase', () {
    testWidgets('has correct semantics when enabled', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: AuthButtonBase(
                  label: 'Test Button',
                  onPressed: () {},
                  backgroundColor: DsColors.authRebrandCtaPrimary,
                ),
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AuthButtonBase));
        expect(semantics.label, 'Test Button');
        expect(semantics.flagsCollection.isButton, isTrue);
        // Using explicit comparison for Tristate (type-safe)
        expect(semantics.flagsCollection.isEnabled == true, isTrue);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('has correct semantics when loading', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: AuthButtonBase(
                  label: 'Test Button',
                  onPressed: () {},
                  backgroundColor: DsColors.authRebrandCtaPrimary,
                  isLoading: true,
                ),
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AuthButtonBase));
        // Loading state uses L10n interpolated label: "{label}, wird geladen" (de)
        expect(semantics.label, contains('Test Button'));
        expect(semantics.flagsCollection.isButton, isTrue);
        // When loading, button is disabled
        // Using explicit comparison for Tristate (type-safe)
        expect(semantics.flagsCollection.isEnabled == false, isTrue);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('uses loadingSemanticLabel when loading', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: AuthButtonBase(
                  label: 'Test Button',
                  onPressed: () {},
                  backgroundColor: DsColors.authRebrandCtaPrimary,
                  isLoading: true,
                  loadingSemanticLabel: 'Signing in...',
                ),
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AuthButtonBase));
        expect(semantics.label, 'Signing in...');
      } finally {
        handle.dispose();
      }
    });

    testWidgets('has correct semantics when disabled', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: AuthButtonBase(
                  label: 'Test Button',
                  onPressed: null,
                  backgroundColor: DsColors.authRebrandCtaPrimary,
                ),
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AuthButtonBase));
        expect(semantics.label, 'Test Button');
        // Using explicit comparison for Tristate (type-safe)
        expect(semantics.flagsCollection.isEnabled == false, isTrue);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('does not invoke callback when tapped while disabled',
        (tester) async {
      // This test verifies that a disabled button (onPressed: null) does not
      // respond to taps. Complement to 'does not call onPressed when tapped
      // while loading' which tests isLoading: true with a real callback.
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthButtonBase(
                label: 'Test Button',
                onPressed: null, // Disabled - no callback to invoke
                backgroundColor: DsColors.authRebrandCtaPrimary,
              ),
            ),
          ),
        ),
      );

      // Tap should be absorbed without effect
      await tester.tap(find.byType(AuthButtonBase));
      await tester.pump();

      // No assertion on callback - button has no callback.
      // Test passes if no exception is thrown during tap.
      // Semantics test above already verifies isEnabled == false.
    });

    testWidgets('has correct semantics when loading AND onPressed is null',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: AuthButtonBase(
                  label: 'Test Button',
                  onPressed: null, // Disabled via null callback
                  backgroundColor: DsColors.authRebrandCtaPrimary,
                  isLoading: true, // Also loading
                ),
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AuthButtonBase));
        // Loading state should show interpolated label (L10n fallback)
        expect(semantics.label, contains('Test Button'));
        expect(semantics.flagsCollection.isButton, isTrue);
        // Both conditions should result in disabled state
        expect(
          semantics.flagsCollection.isEnabled == false,
          isTrue,
          reason:
              'Button should be disabled when both isLoading and onPressed is null',
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
              child: AuthButtonBase(
                label: 'Test Button',
                onPressed: () {},
                backgroundColor: DsColors.authRebrandCtaPrimary,
                isLoading: true,
                loadingKey: const Key('test_loading'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_loading')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('shows label text when isLoading is false', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthButtonBase(
                label: 'Test Button',
                onPressed: () {},
                backgroundColor: DsColors.authRebrandCtaPrimary,
                isLoading: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('respects custom height parameter', (tester) async {
      const customHeight = 60.0;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthButtonBase(
                label: 'Test Button',
                onPressed: () {},
                backgroundColor: DsColors.authRebrandCtaPrimary,
                height: customHeight,
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AuthButtonBase));
      expect(size.height, customHeight);
    });

    testWidgets('respects custom width parameter', (tester) async {
      const customWidth = 200.0;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthButtonBase(
                label: 'Test Button',
                onPressed: () {},
                backgroundColor: DsColors.authRebrandCtaPrimary,
                width: customWidth,
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AuthButtonBase));
      expect(size.width, customWidth);
    });

    testWidgets('uses default height from metrics when not specified',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthButtonBase(
                label: 'Test Button',
                onPressed: () {},
                backgroundColor: DsColors.authRebrandCtaPrimary,
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AuthButtonBase));
      expect(size.height, AuthRebrandMetrics.buttonHeight);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthButtonBase(
                label: 'Test Button',
                onPressed: () => pressed = true,
                backgroundColor: DsColors.authRebrandCtaPrimary,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AuthButtonBase));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when tapped while loading',
        (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthButtonBase(
                label: 'Test Button',
                onPressed: () => pressed = true,
                backgroundColor: DsColors.authRebrandCtaPrimary,
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AuthButtonBase));
      // Use pump() instead of pumpAndSettle() because CircularProgressIndicator
      // animates forever and pumpAndSettle would time out
      await tester.pump();

      expect(pressed, isFalse,
          reason: 'onPressed should not be called when loading');
    });
  });
}
