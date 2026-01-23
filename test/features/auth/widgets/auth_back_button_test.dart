import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../../support/test_app.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('AuthBackButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthBackButton(
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AuthBackButton));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('uses localized semantics label by default', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthBackButton(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify exact L10n value for semantics label
      final context = tester.element(find.byType(AuthBackButton));
      final l10n = AppLocalizations.of(context)!;
      final label = l10n.authBackSemantic;

      // IconButton uses Tooltip which provides the semantic label
      expect(find.byTooltip(label), findsOneWidget);
    });

    testWidgets('uses custom semanticsLabel when provided', (tester) async {
      const customLabel = 'Custom Back Label';

      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthBackButton(
                onPressed: () {},
                semanticsLabel: customLabel,
              ),
            ),
          ),
        ),
      );

      expect(find.byTooltip(customLabel), findsOneWidget);
    });

    testWidgets('has correct touch target size (44dp)', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          home: Scaffold(
            body: Center(
              child: AuthBackButton(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AuthBackButton));
      // Touch target should be at least 44dp (WCAG / iOS HIG)
      expect(size.width, greaterThanOrEqualTo(44.0));
      expect(size.height, greaterThanOrEqualTo(44.0));
    });
  });
}
