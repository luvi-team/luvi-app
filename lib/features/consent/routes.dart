import 'screens/consent_01_screen.dart';
import 'screens/consent_02_screen.dart';

/// Public route names for consent screens exposed to the rest of the app.
abstract class ConsentRoutes {
  ConsentRoutes._();

  /// Identifier for the first consent step.
  static const String consent01 = Consent01Screen.routeName;

  /// Identifier for the second consent step.
  static const String consent02 = Consent02Screen.routeName;
}
