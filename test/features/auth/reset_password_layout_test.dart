import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/router.dart';

import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('ResetPasswordScreen layout', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: testAppRoutes,
        initialLocation: '/auth/reset',
      );
    });

    tearDown(() {
      router.dispose();
    });

    Future<void> pumpResetScreen(
      WidgetTester tester, {
      Locale locale = const Locale('de'),
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('uses Center widget for card positioning (Figma-alignment)',
        (tester) async {
      await pumpResetScreen(tester);

      // Verify Center widget is ancestor of AuthContentCard
      final centerAncestor = find.ancestor(
        of: find.byType(AuthContentCard),
        matching: find.byType(Center),
      );

      expect(
        centerAncestor,
        findsAtLeastNWidgets(1),
        reason: 'AuthContentCard must be wrapped in Center for vertical centering (Figma-alignment)',
      );
    });

    testWidgets('uses AnimatedPadding for keyboard handling', (tester) async {
      await pumpResetScreen(tester);

      // Verify AnimatedPadding is ancestor of AuthContentCard
      final animatedPaddingAncestor = find.ancestor(
        of: find.byType(AuthContentCard),
        matching: find.byType(AnimatedPadding),
      );

      expect(
        animatedPaddingAncestor,
        findsAtLeastNWidgets(1),
        reason: 'AuthContentCard must be wrapped in AnimatedPadding for smooth keyboard handling',
      );
    });
  });
}
