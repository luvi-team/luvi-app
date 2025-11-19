import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/widgets/link_text.dart';

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

    final linkFinder = find.bySemanticsLabel('Open legal document');
    await tester.tap(linkFinder);
    await tester.pumpAndSettle();
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
