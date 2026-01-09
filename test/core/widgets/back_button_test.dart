import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import '../../support/test_config.dart';
import '../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('BackButtonCircle', () {
    testWidgets('renders with circular background by default', (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          home: Scaffold(
            body: Center(
              child: BackButtonCircle(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BackButtonCircle), findsOneWidget);
      // Should have a Container with circular decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BackButtonCircle),
          matching: find.byType(Container),
        ),
      );
      expect(container.decoration, isNotNull);
    });

    testWidgets('triggers onPressed callback when tapped', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        buildLocalizedApp(
          home: Scaffold(
            body: Center(
              child: BackButtonCircle(
                onPressed: () => wasPressed = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BackButtonCircle));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('applies custom semanticLabel', (tester) async {
      const testLabel = 'Go back';

      await tester.pumpWidget(
        buildLocalizedApp(
          home: Scaffold(
            body: Center(
              child: BackButtonCircle(
                onPressed: () {},
                semanticLabel: testLabel,
              ),
            ),
          ),
        ),
      );

      // Find the Semantics widget with our custom label
      final allSemantics = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(BackButtonCircle),
          matching: find.byType(Semantics),
        ),
      );

      final labeledSemantics = allSemantics
          .where((s) => s.properties.label == testLabel)
          .toList();
      expect(labeledSemantics, hasLength(1));
      expect(labeledSemantics.first.properties.button, isTrue);
    });

    testWidgets('maintains minimum touch target size', (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          home: Scaffold(
            body: Center(
              child: BackButtonCircle(
                onPressed: () {},
                size: 20, // Smaller than minimum
              ),
            ),
          ),
        ),
      );

      // Find all ConstrainedBox widgets and check if any has our min constraints
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.descendant(
          of: find.byType(BackButtonCircle),
          matching: find.byType(ConstrainedBox),
        ),
      );

      final touchTargetBox = constrainedBoxes.firstWhere(
        (box) =>
            box.constraints.minWidth == Sizes.touchTargetMin &&
            box.constraints.minHeight == Sizes.touchTargetMin,
        orElse: () => throw StateError('No ConstrainedBox with touch target constraints found'),
      );

      expect(touchTargetBox.constraints.minWidth, equals(Sizes.touchTargetMin));
      expect(touchTargetBox.constraints.minHeight, equals(Sizes.touchTargetMin));
    });

    testWidgets('hides circle when showCircle=false', (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          home: Scaffold(
            body: Center(
              child: BackButtonCircle(
                onPressed: () {},
                showCircle: false,
              ),
            ),
          ),
        ),
      );

      // Should not have a decorated Container
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(BackButtonCircle),
          matching: find.byType(Container),
        ),
      );

      // When showCircle=false, _buildIcon returns just the chevronIcon without Container
      // So we should have fewer Containers with decoration
      final decoratedContainers = containers
          .where((c) => c.decoration is BoxDecoration)
          .toList();
      expect(decoratedContainers, isEmpty);
    });
  });
}
