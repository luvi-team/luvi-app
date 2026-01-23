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
        expect(semantics.flagsCollection.isEnabled, isTrue);
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
        expect(semantics.label, 'Test Button');
        expect(semantics.flagsCollection.isButton, isTrue);
        // When loading, button is disabled
        expect(semantics.flagsCollection.isEnabled, isFalse);
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
        expect(semantics.flagsCollection.isEnabled, isFalse);
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
