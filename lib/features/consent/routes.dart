import 'package:go_router/go_router.dart';
import 'screens/consent_welcome_01_screen.dart';

const consentWelcome1Path = '/consent/w1';

final List<GoRoute> consentRoutes = [
  GoRoute(
    path: consentWelcome1Path,
    name: 'consent_w1',
    builder: (ctx, st) => const ConsentWelcome01Screen(),
  ),
];
