import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      // Should have a Container with circular BoxDecoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BackButtonCircle),
          matching: find.byType(Container),
        ),
      );
      expect(container.decoration, isA<BoxDecoration>());
      final boxDecoration = container.decoration! as BoxDecoration;
      expect(
        boxDecoration.shape,
        equals(BoxShape.circle),
        reason: 'BackButtonCircle should render circular background',
      );
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

      // If firstWhere succeeds without throwing, the constraint is satisfied
      constrainedBoxes.firstWhere(
        (box) =>
            box.constraints.minWidth == Sizes.touchTargetMin &&
            box.constraints.minHeight == Sizes.touchTargetMin,
        orElse: () => throw StateError('No ConstrainedBox with touch target constraints found'),
      );
      // Test passes if no StateError is thrown
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

      // Behavior check: SVG chevron icon should still be present
      expect(
        find.descendant(
          of: find.byType(BackButtonCircle),
          matching: find.byType(SvgPicture),
        ),
        findsOneWidget,
        reason: 'Chevron SVG icon should be visible regardless of showCircle',
      );

      // Behavior check: No circular background container with BoxDecoration.circle
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(BackButtonCircle),
          matching: find.byType(Container),
        ),
      );
      final hasCircularDecoration = containers.any((c) {
        final decoration = c.decoration;
        return decoration is BoxDecoration && decoration.shape == BoxShape.circle;
      });
      expect(
        hasCircularDecoration,
        isFalse,
        reason: 'showCircle=false should not render circular BoxDecoration',
      );
    });
  });
}
