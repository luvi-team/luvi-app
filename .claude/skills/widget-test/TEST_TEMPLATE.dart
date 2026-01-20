// Template for widget tests
// Replace: {feature}, {ScreenName}, {screen_file}

// Material import kept for common test utilities (Key, BuildContext, etc.)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/{feature}/screens/{screen_file}.dart';
// Kept for semantics assertions in TODO comments below
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_app.dart';

void main() {
  group('{ScreenName}Screen', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        // Add const if screen has const constructor
        buildTestApp(child: {ScreenName}Screen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType({ScreenName}Screen), findsOneWidget);
    });

    testWidgets('has correct semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        // Add const if screen has const constructor
        buildTestApp(child: {ScreenName}Screen()),
      );
      await tester.pumpAndSettle();

      // TODO(a11y): Add semantics assertions for {ScreenName}Screen
      //
      // Access localization in tests:
      //   final l10n = AppLocalizations.of(
      //     tester.element(find.byType({ScreenName}Screen)),
      //   )!;
      //
      // Example assertions:
      //   expect(find.bySemanticsLabel(l10n.someLabel), findsOneWidget);
      //   expect(find.bySemanticsLabel('Expected Text'), findsOneWidget);

      handle.dispose();
    });
  });
}
