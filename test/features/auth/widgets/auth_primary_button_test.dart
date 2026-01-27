import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('AuthPrimaryButton', () {
    testWidgets('invokes onPressed when tapped', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthPrimaryButton(
                label: 'Weiter',
                onPressed: () => tapCount++,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('shows spinner and disables button while loading', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: Center(
                child: AuthPrimaryButton(
                  label: 'Weiter',
                  onPressed: () {},
                  isLoading: true,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        final elevatedButton = tester.widget<ElevatedButton>(
          find.descendant(
            of: find.byType(AuthPrimaryButton),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(elevatedButton.onPressed, isNull);

        final semantics = tester.getSemantics(find.byType(AuthPrimaryButton));
        expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthPrimaryButton(
                label: 'Weiter',
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byType(AuthPrimaryButton),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(elevatedButton.onPressed, isNull);
    });
  });
}
