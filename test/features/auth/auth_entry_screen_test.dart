import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';

void main() {
  testWidgets('AuthEntryScreen renders both CTA buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AuthEntryScreen())),
    );

    expect(
      find.byKey(const ValueKey('auth_entry_register_cta')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('auth_entry_login_cta')), findsOneWidget);
  });
}
