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
import 'package:luvi_app/services/supabase_service.dart';

final List<GoRoute> featureRoutes = [
  ...consent.consentRoutes.where((route) => route.name != 'login'),
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
  final isInitialized = SupabaseService.isInitialized;
  final isLoggingIn = state.matchedLocation.startsWith('/auth/login');
  final isAuthEntry = state.matchedLocation.startsWith(
    AuthEntryScreen.routeName,
  );
  final session = isInitialized
      ? SupabaseService.client.auth.currentSession
      : null;

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
