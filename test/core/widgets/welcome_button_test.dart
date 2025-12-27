import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/widgets/welcome_button.dart';

void main() {
  group('WelcomeButton A11y', () {
    testWidgets('maintains semantic label during loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Test Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Find the Semantics widget with our label
      final semanticsFinder = find.bySemanticsLabel('Test Button');
      expect(semanticsFinder, findsOneWidget);

      // Verify the button role is maintained
      final semantics = tester.getSemantics(find.byType(WelcomeButton));
      // ignore: deprecated_member_use - hasFlag replacement API not yet stabilized
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('tap action works when not loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Tap Me',
              onPressed: () => tapped = true,
              isLoading: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WelcomeButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('tap action disabled when loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Loading',
              onPressed: () => tapped = true,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WelcomeButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('tap action disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Disabled',
              onPressed: null,
              isLoading: false,
            ),
          ),
        ),
      );

      // Button should be visually disabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
              loadingKey: const Key('test_spinner'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_spinner')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows text when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeButton(
              label: 'Click Me',
              onPressed: () {},
              isLoading: false,
              labelKey: const Key('test_label'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_label')), findsOneWidget);
      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
