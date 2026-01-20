// Template for widget tests
// Replace: {feature}, {ScreenName}, {screen_file}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/{feature}/screens/{screen_file}.dart';
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
      // Example patterns:
      //   expect(find.bySemanticsLabel(l10n.someLabel), findsOneWidget);
      //   final semantics = tester.widget<Semantics>(
      //     find.byWidgetPredicate((w) => w is Semantics && w.properties.button == true),
      //   );
      //   expect(semantics.properties.label, contains('expected text'));

      handle.dispose();
    });
  });
}
