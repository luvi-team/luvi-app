/// Authentication flow routes.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';

/// Builds authentication routes with custom transitions.
List<RouteBase> buildAuthRoutes() {
  return [
    GoRoute(
      path: RoutePaths.authSignIn,
      name: RouteNames.authSignIn,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AuthSignInScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    GoRoute(
      path: RoutePaths.resetPassword,
      name: 'reset',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    // Legacy redirect: /auth/forgot -> /auth/reset (backward compatibility)
    GoRoute(
      path: RoutePaths.authForgot,
      redirect: (context, state) => RoutePaths.resetPassword,
    ),
    GoRoute(
      path: RoutePaths.createNewPassword,
      name: 'password_new',
      builder: (context, state) => const CreateNewPasswordScreen(
        key: ValueKey(TestKeys.authCreateNewScreen),
      ),
    ),
    GoRoute(
      path: RoutePaths.passwordSaved,
      name: SuccessScreen.passwordSavedRouteName,
      builder: (context, state) => const SuccessScreen(),
    ),
    GoRoute(
      path: RoutePaths.signup,
      name: 'signup',
      builder: (context, state) => const AuthSignupScreen(),
    ),
  ];
}

/// Shared fade transition for auth screens.
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ),
    child: child,
  );
}
