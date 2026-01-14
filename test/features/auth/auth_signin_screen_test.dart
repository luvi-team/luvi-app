import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../support/test_config.dart';

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: AuthSignInScreen.routeName,
    routes: [
      GoRoute(
        path: AuthSignInScreen.routeName,
        builder: (context, state) => const AuthSignInScreen(),
      ),
      GoRoute(
        path: LoginScreen.routeName,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LOGIN'))),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('SIGNUP'))),
      ),
    ],
  );
}

Widget _buildRouterHarness(GoRouter router, {Locale locale = const Locale('de')}) {
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    ),
  );
}

void main() {
  TestConfig.ensureInitialized();

  testWidgets('AuthSignInScreen shows hero image and LUVI logo', (
    tester,
  ) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router));
    await tester.pumpAndSettle();

    // Hero image should be present
    expect(find.byKey(const ValueKey('auth_entry_hero')), findsOneWidget);

    // LUVI logo SVG should be present
    expect(find.byType(SvgPicture), findsAtLeastNWidgets(1));
  });

  testWidgets('Teal dot is rendered within logo stack', (tester) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router));
    await tester.pumpAndSettle();

    // Find teal dot container by its decoration color
    final tealDotFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final decoration = widget.decoration as BoxDecoration;
        return decoration.color == DsColors.authRebrandTealDot &&
            decoration.shape == BoxShape.circle;
      }
      return false;
    });
    expect(tealDotFinder, findsOneWidget);

    // Find logo SVG
    final logoFinder = find.byType(SvgPicture);
    expect(logoFinder, findsAtLeastNWidgets(1));

    // Both should be descendants of a Stack with clipBehavior.none
    final stackFinder = find.ancestor(
      of: tealDotFinder,
      matching: find.byWidgetPredicate((widget) =>
          widget is Stack && widget.clipBehavior == Clip.none),
    );
    expect(stackFinder, findsOneWidget);
  });

  testWidgets('AuthSignInScreen shows CTA button "Los geht\'s"', (tester) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router));
    await tester.pumpAndSettle();

    // CTA button should be present
    expect(find.byType(AuthPrimaryButton), findsOneWidget);
    expect(find.byKey(const ValueKey('auth_entry_cta')), findsOneWidget);

    final l10n = AppLocalizations.of(tester.element(find.byType(AuthSignInScreen)))!;
    expect(find.text(l10n.authEntryCta), findsOneWidget);
  });

  testWidgets('CTA button opens register bottom sheet', (tester) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router));
    await tester.pumpAndSettle();

    final ctaButton = find.byKey(const ValueKey('auth_entry_cta'));
    expect(ctaButton, findsOneWidget);

    await tester.tap(ctaButton);
    await tester.pumpAndSettle();

    // Register sheet should be open with headline
    final l10n = AppLocalizations.of(tester.element(find.byType(AuthSignInScreen)))!;
    expect(find.text(l10n.authRegisterHeadline), findsOneWidget);
  });

  testWidgets('Login link opens login bottom sheet', (tester) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(AuthSignInScreen)))!;

    // Find and tap login link
    final loginLink = find.text(l10n.authEntryExistingAccount);
    expect(loginLink, findsOneWidget);

    await tester.tap(loginLink);
    await tester.pumpAndSettle();

    // Login sheet should be open with headline
    expect(find.text(l10n.authLoginSheetHeadline), findsOneWidget);
  });

  testWidgets('AuthSignInScreen shows correct content in English', (tester) async {
    final router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(_buildRouterHarness(router, locale: const Locale('en')));
    await tester.pumpAndSettle();

    // CTA button should show English text
    final l10n = AppLocalizations.of(tester.element(find.byType(AuthSignInScreen)))!;
    expect(l10n.localeName, 'en');
    expect(find.text(l10n.authEntryCta), findsOneWidget);
    expect(find.text(l10n.authEntryExistingAccount), findsOneWidget);
  });
}
