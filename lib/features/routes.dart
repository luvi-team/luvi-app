import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/consent/routes.dart' as consent;
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/screens/auth_signup_screen.dart';

final List<GoRoute> featureRoutes = [
  ...consent.consentRoutes.where((route) => route.name != 'login'),
  GoRoute(
    path: '/auth/login',
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/auth/signup',
    name: 'signup',
    builder: (context, state) => const AuthSignupScreen(),
  ),
];
