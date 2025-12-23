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
        initialLocation: '/auth/reset',
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
    });

    testWidgets('successful reset navigates to signin', (tester) async {
      // Test mode allows silent success without needing Supabase initialization
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

      // Enter valid email
      await tester.enterText(
        find.byKey(const ValueKey('reset_email_field')),
        'user@example.com',
      );
      await tester.pump();

      // Tap submit button
      final ctaFinder = find.byKey(const ValueKey('reset_cta'));
      final elevatedButtonFinder = find.descendant(
        of: ctaFinder,
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(elevatedButtonFinder);

      // Pump for async submit + 300ms navigation delay
      await tester.pump(); // setState after async
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify navigation to signin
      expect(
        find.byKey(const ValueKey('auth_signin_screen')),
        findsOneWidget,
        reason: 'Should navigate to AuthSignInScreen after successful reset',
      );
    });
  });
}
