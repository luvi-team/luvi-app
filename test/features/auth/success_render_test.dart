import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rainbow_background.dart';
import 'package:luvi_app/router.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
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

      expect(find.byKey(const ValueKey('auth_success_screen')), findsOneWidget);
    });

    testWidgets('displays AuthContentCard with title and subtitle (export-parity)', (
      tester,
    ) async {
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

      // Export-parity: Must use AuthContentCard (not GlowCheckmark)
      expect(find.byType(AuthContentCard), findsOneWidget);

      // Get L10n from a descendant context (not MaterialApp root)
      final l10n = AppLocalizations.of(
        tester.element(find.byKey(const ValueKey('auth_success_screen'))),
      )!;

      // Title and subtitle must be visible
      expect(find.text(l10n.authSuccessPwdTitle), findsOneWidget);
      expect(find.text(l10n.authSuccessPwdSubtitle), findsOneWidget);
    });

    testWidgets('passes dynamic containerTop to AuthRainbowBackground', (
      tester,
    ) async {
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
    });
  });
}
