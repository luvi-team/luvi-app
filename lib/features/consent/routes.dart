import 'package:go_router/go_router.dart';
import 'screens/consent_01_screen.dart';
import 'screens/consent_welcome_01_screen.dart';
import 'screens/consent_welcome_02_screen.dart';
import 'screens/consent_welcome_03_screen.dart';

final consentRoutes = <GoRoute>[
  GoRoute(
    path: '/onboarding/w1',
    name: 'welcome1',
    builder: (context, state) => const ConsentWelcome01Screen(),
  ),
  GoRoute(
    path: '/onboarding/w2',
    name: 'welcome2',
    builder: (context, state) => const ConsentWelcome02Screen(),
  ),
  GoRoute(
    path: '/onboarding/w3',
    name: 'welcome3',
    builder: (context, state) => const ConsentWelcome03Screen(),
  ),
  GoRoute(
    path: Consent01Screen.routeName,
    name: 'consent01',
    builder: (context, state) => const Consent01Screen(),
  ),
];
