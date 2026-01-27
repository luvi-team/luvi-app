import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_error_banner.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('AuthErrorBanner', () {
    testWidgets('renders message and exposes live-region semantics', (
      tester,
    ) async {
      const message = 'Fehler beim Anmelden';
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          buildTestApp(
            home: Scaffold(
              body: AuthErrorBanner(message: message),
            ),
          ),
        );

        expect(find.text(message), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AuthErrorBanner),
            matching: find.byType(ExcludeSemantics),
          ),
          findsOneWidget,
        );

        final semantics = tester.getSemantics(find.byType(AuthErrorBanner));
        expect(semantics.label, message);
      } finally {
        handle.dispose();
      }
    });
  });
}
