import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/router.dart';

import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('CreateNewPasswordScreen layout', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: testAppRoutes,
        initialLocation: RoutePaths.createNewPassword,
      );
    });

    tearDown(() {
      router.dispose();
    });

    Future<void> pumpCreatePasswordScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('uses Center widget for card positioning (Figma-alignment)',
        (tester) async {
      await pumpCreatePasswordScreen(tester);

      final centerAncestor = find.ancestor(
        of: find.byType(AuthContentCard),
        matching: find.byType(Center),
      );

      expect(
        centerAncestor,
        findsOneWidget,
        reason: 'AuthContentCard must be wrapped in Center for vertical centering',
      );
    });

    testWidgets('uses AnimatedPadding for keyboard handling', (tester) async {
      await pumpCreatePasswordScreen(tester);

      final animatedPaddingAncestor = find.ancestor(
        of: find.byType(AuthContentCard),
        matching: find.byType(AnimatedPadding),
      );

      expect(
        animatedPaddingAncestor,
        findsOneWidget,
        reason: 'AuthContentCard must be wrapped in AnimatedPadding for smooth keyboard handling',
      );
    });
  });
}
