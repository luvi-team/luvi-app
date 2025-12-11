import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:luvi_app/core/navigation/routes.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/splash/screens/splash_screen.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';

import '../../support/test_config.dart';

class _MockGoRouterState extends Mock implements GoRouterState {}

class _MockBuildContext extends Mock implements BuildContext {}

class _MockSession extends Mock implements Session {}

/// Unit-Tests für supabaseRedirectWithSession
///
/// Diese Tests decken die kritischen Redirect-Szenarien ab:
/// 1. session == null + Auth-Routes → return null (erlauben)
/// 2. session != null + Login/AuthSignIn → return SplashScreen.routeName
/// 3. session == null + non-Auth-Route → return AuthSignInScreen.routeName
void main() {
  TestConfig.ensureInitialized();

  late _MockGoRouterState mockState;
  late _MockBuildContext mockContext;
  late _MockSession mockSession;

  setUp(() {
    mockState = _MockGoRouterState();
    mockContext = _MockBuildContext();
    mockSession = _MockSession();
  });

  group('supabaseRedirectWithSession', () {
    group('Szenario 1: session == null + Auth-Routes → allow', () {
      test('allows LoginScreen without session', () {
        when(() => mockState.matchedLocation).thenReturn(LoginScreen.routeName);

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'LoginScreen should be allowed without session');
      });

      test('allows AuthSignInScreen without session', () {
        when(() => mockState.matchedLocation).thenReturn(AuthSignInScreen.routeName);

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'AuthSignInScreen should be allowed without session');
      });

      test('allows AuthSignupScreen without session', () {
        when(() => mockState.matchedLocation).thenReturn(AuthSignupScreen.routeName);

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'AuthSignupScreen should be allowed without session');
      });

      test('allows ResetPasswordScreen without session', () {
        when(() => mockState.matchedLocation).thenReturn(ResetPasswordScreen.routeName);

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'ResetPasswordScreen should be allowed without session');
      });
    });

    group('Szenario 2: session != null + Login/AuthSignIn → redirect to Splash', () {
      test('redirects LoginScreen to Splash when session exists', () {
        when(() => mockState.matchedLocation).thenReturn(LoginScreen.routeName);

        final result = supabaseRedirectWithSession(
          mockContext,
          mockState,
          sessionOverride: mockSession,
          isInitializedOverride: true,
        );

        expect(
          result,
          equals(SplashScreen.routeName),
          reason: 'LoginScreen with session should redirect to Splash',
        );
      });

      test('redirects AuthSignInScreen to Splash when session exists', () {
        when(() => mockState.matchedLocation).thenReturn(AuthSignInScreen.routeName);

        final result = supabaseRedirectWithSession(
          mockContext,
          mockState,
          sessionOverride: mockSession,
          isInitializedOverride: true,
        );

        expect(
          result,
          equals(SplashScreen.routeName),
          reason: 'AuthSignInScreen with session should redirect to Splash',
        );
      });

      test('allows AuthSignupScreen even when session exists', () {
        when(() => mockState.matchedLocation).thenReturn(AuthSignupScreen.routeName);

        final result = supabaseRedirectWithSession(
          mockContext,
          mockState,
          sessionOverride: mockSession,
          isInitializedOverride: true,
        );

        // Signup screen should not redirect to Splash - only Login/AuthSignIn do
        expect(result, isNull, reason: 'AuthSignupScreen should be allowed even with session');
      });
    });

    group('Szenario 3: session == null + non-Auth-Route → redirect to AuthSignIn', () {
      test('redirects Dashboard to AuthSignIn without session', () {
        when(() => mockState.matchedLocation).thenReturn(HeuteScreen.routeName);

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Dashboard without session should redirect to AuthSignIn',
        );
      });

      test('redirects unknown route to AuthSignIn without session', () {
        when(() => mockState.matchedLocation).thenReturn('/unknown/route');

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(
          result,
          equals(AuthSignInScreen.routeName),
          reason: 'Unknown route without session should redirect to AuthSignIn',
        );
      });
    });

    group('Whitelist-Routes: always allowed without session', () {
      test('allows Splash without session', () {
        when(() => mockState.matchedLocation).thenReturn(SplashScreen.routeName);

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'Splash should always be allowed');
      });

      test('allows Welcome routes without session', () {
        when(() => mockState.matchedLocation).thenReturn('/onboarding/w1');

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'Welcome routes should always be allowed');
      });

      test('allows Consent routes without session', () {
        when(() => mockState.matchedLocation).thenReturn('/consent/02');

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'Consent routes should always be allowed');
      });

      test('allows PasswordRecovery without session', () {
        when(() => mockState.matchedLocation).thenReturn(CreateNewPasswordScreen.routeName);

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'PasswordRecovery should always be allowed');
      });

      test('allows PasswordSuccess without session', () {
        when(() => mockState.matchedLocation).thenReturn(SuccessScreen.passwordSavedRoutePath);

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'PasswordSuccess should always be allowed');
      });
    });

    group('Edge cases', () {
      test('handles nested auth routes correctly', () {
        // Test that routes starting with /auth/login are recognized
        when(() => mockState.matchedLocation).thenReturn('/auth/login/verify');

        final result = supabaseRedirectWithSession(mockContext, mockState);

        expect(result, isNull, reason: 'Nested login routes should be allowed without session');
      });

      test('Dashboard with session is allowed (no redirect)', () {
        when(() => mockState.matchedLocation).thenReturn(HeuteScreen.routeName);

        final result = supabaseRedirectWithSession(
          mockContext,
          mockState,
          sessionOverride: mockSession,
          isInitializedOverride: true,
        );

        expect(result, isNull, reason: 'Dashboard with valid session should be allowed');
      });
    });
  });
}
