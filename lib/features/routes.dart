import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/consent/routes.dart' as consent;
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/screens/verification_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';

final List<GoRoute> featureRoutes = [
  ...consent.consentRoutes.where((route) => route.name != 'login'),
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
