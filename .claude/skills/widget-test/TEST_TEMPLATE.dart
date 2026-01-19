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
        buildTestApp(child: const {ScreenName}Screen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType({ScreenName}Screen), findsOneWidget);
    });

    testWidgets('has correct semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildTestApp(child: const {ScreenName}Screen()),
      );
      await tester.pumpAndSettle();

      // Verify key semantic labels exist
      // expect(find.bySemanticsLabel('...'), findsOneWidget);

      handle.dispose();
    });
  });
}
