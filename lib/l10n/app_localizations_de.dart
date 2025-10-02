// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get onboarding04Title => 'Wann hat deine letzte Periode angefangen?';

  @override
  String selectedDateLabel(String date) {
    return 'Ausgewähltes Datum: $date';
  }

  @override
  String get onboarding04CalloutSemantics => 'Hinweis: Mach dir keine Sorgen, wenn du den exakten Tag nicht mehr weißt. Eine ungefähre Schätzung reicht für den Start völlig aus.';

  @override
  String get onboarding04CalloutPrefix => 'Mach dir keine Sorgen, wenn du den ';

  @override
  String get onboarding04CalloutHighlight => 'exakten Tag nicht mehr weißt';

  @override
  String get onboarding04CalloutSuffix => '. Eine ungefähre Schätzung reicht für den Start völlig aus.';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get cycleLengthShort => 'Kurz (alle 21-23 Tage)';

  @override
  String get cycleLengthLonger => 'Etwas kürzer (alle 24-26 Tage)';

  @override
  String get cycleLengthStandard => 'Standard (alle 27-30 Tage)';

  @override
  String get cycleLengthLong => 'Länger (alle 31-35 Tage)';

  @override
  String get cycleLengthVeryLong => 'Sehr lang (36+ Tage)';

  @override
  String get onboarding06Title => 'Erzähl mir von dir 💜';

  @override
  String get onboarding06Question => 'Wie lange dauert dein Zyklus normalerweise?';

  @override
  String get onboarding06Callout => 'Jeder Zyklus ist einzigartig - wie du auch!';
}
