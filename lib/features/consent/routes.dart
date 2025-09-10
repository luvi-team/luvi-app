import 'package:go_router/go_router.dart';
import 'screens/consent_welcome_01_screen.dart';

const consentWelcome1Path = '/consent/w1';
// Route name constant for clarity and to prevent string drift.
const String consentWelcome1Name = 'consent_w1';

final List<GoRoute> consentRoutes = [
  GoRoute(
    name: consentWelcome1Name,
    path: consentWelcome1Path,
    builder: (ctx, st) => const ConsentWelcome01Screen(),
  ),
];
