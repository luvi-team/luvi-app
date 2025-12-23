import 'screens/consent_intro_screen.dart';

/// Public route names for consent screens exposed to the rest of the app.
abstract class ConsentRoutes {
  ConsentRoutes._();

  /// Historical mapping: W5 Welcome screen navigates to /consent/02
  /// which is actually the Consent INTRO screen (C1).
  /// Kept as consent02 for backwards compatibility with existing navigation.
  static const String consent02 = ConsentIntroScreen.routeName;

  /// Alias for clarity - new code should prefer this name.
  static const String consentIntro = ConsentIntroScreen.routeName;
}
