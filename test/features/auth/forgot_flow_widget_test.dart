import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/core/navigation/routes.dart' as features;
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reset password flow', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: features.featureRoutes,
        initialLocation: '/auth/forgot',
      );
    });

    tearDown(() {
      router.dispose();
    });

    testWidgets('button enables only for valid email', (tester) async {
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

      final emailField = find.byKey(const ValueKey('reset_email_field'));
      final ctaButtonFinder = find.byKey(const ValueKey('reset_cta'));

      // WelcomeButton wraps ElevatedButton - find the inner ElevatedButton
      ElevatedButton buttonWidget() {
        final elevatedButtonFinder = find.descendant(
          of: ctaButtonFinder,
          matching: find.byType(ElevatedButton),
        );
        return tester.widget<ElevatedButton>(elevatedButtonFinder);
      }

      // Initially invalid -> disabled CTA
      expect(buttonWidget().onPressed, isNull);

      await tester.enterText(emailField, 'invalid');
      await tester.pump();
      expect(buttonWidget().onPressed, isNull);

      await tester.enterText(emailField, 'user@example.com');
      await tester.pump();
      expect(buttonWidget().onPressed, isNotNull);

      // Note: Per Auth v2 refactoring, the reset flow shows a snackbar
      // and navigates to /auth/signin instead of showing a success screen.
      // Navigation test is omitted as it requires mocking the AuthRepository.
    });
  });
}
