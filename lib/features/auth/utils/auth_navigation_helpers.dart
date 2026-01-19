import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';

/// Navigates back or to the Auth Entry Screen as fallback.
///
/// This helper centralizes the back navigation pattern used across
/// auth screens (Login, Signup, Reset Password, Create New Password).
///
/// Behavior:
/// - If the router can pop (has history), pops to the previous screen
/// - Otherwise, navigates to the auth entry screen as fallback
void handleAuthBackNavigation(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go(RoutePaths.authSignIn);
  }
}
