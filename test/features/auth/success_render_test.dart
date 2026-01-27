import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rainbow_background.dart';
import 'package:luvi_app/router.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_app.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('SuccessScreen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: testAppRoutes,
        initialLocation: SuccessScreen.passwordSavedRoutePath,
      );
    });

    tearDown(() {
      router.dispose();
    });

    testWidgets('navigating to /auth/password/success renders SuccessScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey(TestKeys.authSuccessScreen)), findsOneWidget);
    });

    testWidgets('displays AuthContentCard with title and subtitle (export-parity)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Export-parity: Must use AuthContentCard (not GlowCheckmark)
      expect(find.byType(AuthContentCard), findsOneWidget);

      // Get L10n from a descendant context (not MaterialApp root)
      final l10n = AppLocalizations.of(
        tester.element(find.byKey(const ValueKey(TestKeys.authSuccessScreen))),
      )!;

      // Title and subtitle must be visible
      expect(find.text(l10n.authSuccessPwdTitle), findsOneWidget);
      expect(find.text(l10n.authSuccessPwdSubtitle), findsOneWidget);
    });

    testWidgets('passes dynamic containerTop to AuthRainbowBackground', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp(router: router));
      await tester.pumpAndSettle();

      // Find AuthRainbowBackground and verify containerTop is set
      final rainbowFinder = find.byType(AuthRainbowBackground);
      expect(rainbowFinder, findsOneWidget);

      final rainbow = tester.widget<AuthRainbowBackground>(rainbowFinder);
      // containerTop should be dynamically calculated, not null (default)
      expect(
        rainbow.containerTop,
        isNotNull,
        reason: 'containerTop must be set for device consistency',
      );
      expect(rainbow.containerTop, greaterThan(0));

      // Upper-bound sanity check: containerTop should not exceed half screen height
      final context = tester.element(rainbowFinder);
      final screenHeight = MediaQuery.of(context).size.height;
      expect(
        rainbow.containerTop,
        lessThan(screenHeight * 0.5),
        reason: 'containerTop should not exceed 50% of screen height',
      );
    });
  });
}
