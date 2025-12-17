import 'screens/consent_intro_screen.dart';

/// Public route names for consent screens exposed to the rest of the app.
abstract class ConsentRoutes {
  ConsentRoutes._();

  /// Identifier for the consent intro screen (C1).
  /// Route: /consent/02 (mapped from W5 for backwards compatibility)
  static const String consent02 = ConsentIntroScreen.routeName;
}
