import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/consent/routes.dart' as consent;
import 'package:luvi_app/features/auth/screens/auth_entry_screen.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/screens/verification_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';
import 'package:luvi_app/features/screens/onboarding_02.dart';
import 'package:luvi_app/features/screens/onboarding_03.dart';
import 'package:luvi_app/features/screens/onboarding_04.dart';
import 'package:luvi_app/features/screens/onboarding_05.dart';
import 'package:luvi_app/features/screens/onboarding_06.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/services/supabase_service.dart';

final List<GoRoute> featureRoutes = [
  ...consent.consentRoutes.where((route) => route.name != 'login'),
  GoRoute(
    path: Onboarding01Screen.routeName,
    name: 'onboarding_01',
    builder: (ctx, st) => const Onboarding01Screen(),
  ),
  GoRoute(
    path: Onboarding02Screen.routeName,
    name: 'onboarding_02',
    builder: (ctx, st) => const Onboarding02Screen(),
  ),
  GoRoute(
    path: Onboarding03Screen.routeName,
    name: 'onboarding_03',
    builder: (ctx, st) => const Onboarding03Screen(),
  ),
  GoRoute(
    path: Onboarding04Screen.routeName,
    name: 'onboarding_04',
    builder: (ctx, st) => const Onboarding04Screen(),
  ),
  GoRoute(
    path: Onboarding05Screen.routeName,
    name: 'onboarding_05',
    builder: (ctx, st) => const Onboarding05Screen(),
  ),
  GoRoute(
    path: Onboarding06Screen.routeName,
    name: 'onboarding_06',
    builder: (ctx, st) => const Onboarding06Screen(),
  ),
  GoRoute(
    path: Onboarding07Screen.routeName,
    name: 'onboarding_07',
    builder: (ctx, st) => const Onboarding07Screen(),
  ),
  GoRoute(
    path: '/onboarding/done',
    name: 'onboarding_done',
    builder: (ctx, st) => const Center(child: Text('Onboarding abgeschlossen')),
  ),
  GoRoute(
    path: AuthEntryScreen.routeName,
    name: 'auth_entry',
    builder: (context, state) => const AuthEntryScreen(),
  ),
  GoRoute(
    path: '/auth/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/auth/forgot',
    name: 'forgot',
    builder: (context, state) => const ResetPasswordScreen(),
  ),
  GoRoute(
    path: '/auth/forgot/sent',
    name: 'forgot_sent',
    builder: (context, state) =>
        const SuccessScreen(variant: SuccessVariant.forgotEmailSent),
  ),
  GoRoute(
    path: '/auth/password/new',
    name: 'password_new',
    builder: (context, state) => const CreateNewPasswordScreen(),
  ),
  GoRoute(
    path: '/auth/password/success',
    name: 'password_success',
    builder: (context, state) => const SuccessScreen(),
  ),
  GoRoute(
    path: '/auth/verify',
    name: 'verify',
    builder: (context, state) {
      final variantParam = state.uri.queryParameters['variant'];
      final variant = variantParam == 'email'
          ? VerificationScreenVariant.emailConfirmation
          : VerificationScreenVariant.resetPassword;
      return VerificationScreen(variant: variant);
    },
  ),
  GoRoute(
    path: '/auth/signup',
    name: 'signup',
    builder: (context, state) => const AuthSignupScreen(),
  ),
];

String? supabaseRedirect(BuildContext context, GoRouterState state) {
  // Dev-only bypass to allow opening onboarding without auth during development
  const allowOnboardingDev = bool.fromEnvironment(
    'ALLOW_ONBOARDING_DEV',
    defaultValue: false,
  );

  final isInitialized = SupabaseService.isInitialized;
  final isLoggingIn = state.matchedLocation.startsWith('/auth/login');
  final isAuthEntry = state.matchedLocation.startsWith(
    AuthEntryScreen.routeName,
  );
  final isOnboarding = state.matchedLocation.startsWith('/onboarding/');
  final session = isInitialized
      ? SupabaseService.client.auth.currentSession
      : null;

  if (allowOnboardingDev && !kReleaseMode && isOnboarding) {
    return null; // allow onboarding routes in dev without auth
  }

  if (session == null) {
    if (isLoggingIn || isAuthEntry) {
      return null;
    }
    return AuthEntryScreen.routeName;
  }
  if (isLoggingIn) {
    return '/onboarding/w1';
  }
  return null;
}
