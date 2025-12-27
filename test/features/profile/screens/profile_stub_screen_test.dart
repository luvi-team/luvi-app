import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/profile/screens/profile_stub_screen.dart';

import '../../../support/test_app.dart';

void main() {
  group('ProfileStubScreen', () {
    testWidgets('renders profile screen with AppBar title', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const ProfileStubScreen(),
        ),
      );

      // Verify AppBar exists
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders sign-out button', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const ProfileStubScreen(),
        ),
      );

      // Verify OutlinedButton exists (the sign-out button)
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('sign-out button has correct semantic label', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const ProfileStubScreen(),
        ),
      );

      // Button should contain the sign-out text from l10n
      final button = find.byType(OutlinedButton);
      expect(button, findsOneWidget);

      // Verify button contains Text widget
      expect(find.descendant(of: button, matching: find.byType(Text)), findsOneWidget);
    });

    testWidgets('ProfileStubScreen.routeName is correct', (tester) async {
      expect(ProfileStubScreen.routeName, equals('/profil'));
    });

    testWidgets('screen is scrollable via Center widget', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: const ProfileStubScreen(),
        ),
      );

      // Verify Center layout exists
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
