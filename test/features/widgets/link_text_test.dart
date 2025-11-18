import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/widgets/link_text.dart';

void main() {
  testWidgets('LinkText exposes accessible hit target and semantics', (tester) async {
    bool tapped = false;
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LinkText(
              style: const TextStyle(fontSize: 14),
              parts: [
                LinkTextPart(
                  'Legal',
                  semanticsLabel: 'Open legal document',
                  onTap: () => tapped = true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final targetFinder = find.descendant(
      of: find.byType(LinkText),
      matching: find.byType(AnimatedContainer),
    );
    final targetSize = tester.getSize(targetFinder);

    // Allow slight rounding jitter when enforcing the 44px minimum size.
    expect(targetSize.height, greaterThanOrEqualTo(43.5));
    expect(targetSize.width, greaterThanOrEqualTo(43.5));

    final tapFinder = find.descendant(
      of: find.byType(LinkText),
      matching: find.byType(GestureDetector),
    );
    final gesture = tester.widget<GestureDetector>(tapFinder);
    gesture.onTap?.call();
    expect(tapped, isTrue);

    final semanticsNode =
        tester.getSemantics(find.bySemanticsLabel('Open legal document'));
    expect(
      semanticsNode.flagsCollection.isLink,
      isTrue,
      reason: 'Interactive region should expose link semantics',
    );
    expect(find.bySemanticsLabel('Legal'), findsNothing);

    semanticsHandle.dispose();
  });
}
