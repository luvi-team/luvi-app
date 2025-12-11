import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:luvi_app/core/navigation/routes.dart' as routes;
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/data/auth_repository.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

import '../../support/test_config.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Auth-Flow Bugfix Tests: Verify auth route whitelist behavior.
///
/// These tests verify that navigation between auth screens works correctly:
/// 1. LoginScreen → SignupScreen navigation works
/// 2. LoginScreen → ResetPasswordScreen navigation works
/// 3. All auth routes are accessible without being redirected to sign-in
void main() {
  TestConfig.ensureInitialized();
  late _MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = _MockAuthRepository();
    when(
      () => mockRepo.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(AuthException('invalid credentials'));
  });

  group('Auth route whitelist (navigation without session)', () {
    testWidgets('LoginScreen → SignupScreen navigation works', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        routes: routes.featureRoutes,
        initialLocation: LoginScreen.routeName,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we start on LoginScreen
      expect(find.byKey(const ValueKey('auth_login_screen')), findsOneWidget);

      // Scroll down to make signup link visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Tap "Neu bei LUVI? Hier starten" link
      final signupLink = find.byKey(const ValueKey('login_signup_link'));
      expect(signupLink, findsOneWidget);
      await tester.tap(signupLink);
      await tester.pumpAndSettle();

      // Auth-Flow Bugfix: Verify navigation to SignupScreen (not redirect to sign-in)
      expect(
        find.byKey(const ValueKey('auth_signup_screen')),
        findsOneWidget,
        reason: 'Should navigate to SignupScreen, not redirect to AuthSignInScreen',
      );
    });

    testWidgets('LoginScreen → ResetPasswordScreen navigation works', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        routes: routes.featureRoutes,
        initialLocation: LoginScreen.routeName,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we start on LoginScreen
      expect(find.byKey(const ValueKey('auth_login_screen')), findsOneWidget);

      // Tap "Passwort vergessen?" link
      final forgotLink = find.byKey(const ValueKey('login_forgot_link'));
      expect(forgotLink, findsOneWidget);
      await tester.tap(forgotLink);
      await tester.pumpAndSettle();

      // Auth-Flow Bugfix: Verify navigation to ResetPasswordScreen (not redirect to sign-in)
      expect(
        find.byKey(const ValueKey('auth_reset_screen')),
        findsOneWidget,
        reason: 'Should navigate to ResetPasswordScreen, not redirect to AuthSignInScreen',
      );
    });

    testWidgets('AuthSignInScreen is accessible', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        routes: routes.featureRoutes,
        initialLocation: AuthSignInScreen.routeName,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify AuthSignInScreen is shown (not redirected)
      expect(
        find.byKey(const ValueKey('auth_signin_screen')),
        findsOneWidget,
        reason: 'AuthSignInScreen should be accessible without session',
      );
    });

    testWidgets('AuthSignupScreen is directly accessible', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        routes: routes.featureRoutes,
        initialLocation: AuthSignupScreen.routeName,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Auth-Flow Bugfix: Verify SignupScreen is accessible (not redirected to sign-in)
      expect(
        find.byKey(const ValueKey('auth_signup_screen')),
        findsOneWidget,
        reason: 'AuthSignupScreen should be accessible without session (whitelist)',
      );
    });

    testWidgets('ResetPasswordScreen is directly accessible', (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(1080, 2340);
      view.devicePixelRatio = 1.0;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        routes: routes.featureRoutes,
        initialLocation: ResetPasswordScreen.routeName,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.buildAppTheme(),
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Auth-Flow Bugfix: Verify ResetPasswordScreen is accessible (not redirected to sign-in)
      expect(
        find.byKey(const ValueKey('auth_reset_screen')),
        findsOneWidget,
        reason: 'ResetPasswordScreen should be accessible without session (whitelist)',
      );
    });
  });
}
