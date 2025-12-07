import 'screens/consent_02_screen.dart';

/// Public route names for consent screens exposed to the rest of the app.
abstract class ConsentRoutes {
  ConsentRoutes._();

  /// Identifier for the consent step (checkbox screen).
  static const String consent02 = Consent02Screen.routeName;
}
