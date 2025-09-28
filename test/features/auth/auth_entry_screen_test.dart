import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';
import 'package:luvi_app/features/consent/widgets/welcome_shell.dart';

void main() {
  testWidgets('AuthEntryScreen shows both CTAs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AuthEntryScreen())),
    );

    expect(
      find.byKey(const ValueKey('auth_entry_register_cta')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('auth_entry_login_cta')), findsOneWidget);
  });

  testWidgets(
    'AuthEntryScreen has screen key and title is wrapped in Semantics',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AuthEntryScreen())),
      );

      expect(find.byKey(const ValueKey('auth_entry_screen')), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is WelcomeShell &&
              widget.key == const ValueKey('auth_entry_screen'),
        ),
        findsOneWidget,
      );

      final titleFinder = find.text('Training, Ernährung und Regeneration');
      expect(titleFinder, findsOneWidget);
      // Ensure the title is wrapped in a Semantics widget and marked as header
      final semanticsTester = SemanticsTester(tester);
      addTearDown(semanticsTester.dispose);
      expect(
        semanticsTester,
        includesNodeWith(
          label: 'Training, Ernährung und Regeneration',
          flags: <SemanticsFlag>[SemanticsFlag.isHeader],
        ),
      );
    },
  );
}
