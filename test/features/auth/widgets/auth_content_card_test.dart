import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('AuthContentCard', () {
    testWidgets('renders child with default metrics', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthContentCard(
                child: const Text('Inhalt'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Inhalt'), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AuthContentCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minWidth, AuthRebrandMetrics.cardWidth);
      expect(container.constraints?.maxWidth, AuthRebrandMetrics.cardWidth);
      expect(
        container.padding,
        const EdgeInsets.all(AuthRebrandMetrics.cardPadding),
      );
    });

    testWidgets('respects custom width and padding', (tester) async {
      const customWidth = 280.0;
      const customPadding = EdgeInsets.all(8);

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthContentCard(
                width: customWidth,
                padding: customPadding,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AuthContentCard),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minWidth, customWidth);
      expect(container.constraints?.maxWidth, customWidth);
      expect(container.padding, customPadding);
    });
  });
}
