// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get onboarding01Title => 'Erzähl mir von dir 💜';

  @override
  String onboardingStepSemantic(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get onboarding01Instruction => 'Wie soll ich dich nennen?';

  @override
  String get onboarding01NameInputSemantic => 'Name eingeben';

  @override
  String get onboarding02Title => 'Wann hast du\nGeburtstag?';

  @override
  String get onboarding02CalloutSemantic => 'Hinweis: Dein Alter hilft uns, deine hormonelle Phase besser einzuschätzen.';

  @override
  String get onboarding02CalloutBody => 'Dein Alter hilft uns, deine hormonelle Phase besser einzuschätzen.';

  @override
  String get onboarding02PickerSemantic => 'Geburtsdatum auswählen';

  @override
  String get onboarding03Title => 'Was sind deine Ziele?';

  @override
  String onboardingStepFraction(int current, int total) {
    return '$current/$total';
  }

  @override
  String get onboarding03GoalCycleUnderstanding => 'Meinen Zyklus & Körper besser verstehen';

  @override
  String get onboarding03GoalTrainingAlignment => 'Training an meinen Zyklus anpassen';

  @override
  String get onboarding03GoalNutrition => 'Ernährung optimieren & neue Rezepte entdecken';

  @override
  String get onboarding03GoalWeightManagement => 'Gewicht managen (Abnehmen/Halten)';

  @override
  String get onboarding03GoalMindfulness => 'Stress reduzieren & Achtsamkeit stärken';

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
  String dashboardGreeting(String name) {
    return 'Hey, $name 💜';
  }

  @override
  String get dashboardCategoriesTitle => 'Kategorien';

  @override
  String get dashboardTopRecommendationTitle => 'Deine Top-Empfehlung';

  @override
  String get dashboardMoreTrainingsTitle => 'Weitere Trainings';

  @override
  String get dashboardTrainingDataTitle => 'Deine Trainingsdaten';

  @override
  String get dashboardNavToday => 'Heute';

  @override
  String get dashboardNavCycle => 'Zyklus';

  @override
  String get dashboardNavPulse => 'Puls';

  @override
  String get dashboardNavProfile => 'Profil';

  @override
  String get dashboardNavSync => 'Sync';

  @override
  String get dashboardCategoryTraining => 'Training';

  @override
  String get dashboardCategoryNutrition => 'Ernährung';

  @override
  String get dashboardCategoryRegeneration => 'Regeneration';

  @override
  String get dashboardCategoryMindfulness => 'Achtsamkeit';

  @override
  String get dashboardViewAll => 'Alle';

  @override
  String get dashboardLuviSyncTitle => 'Luvi Sync Journal';

  @override
  String get dashboardLuviSyncPlaceholder => 'Luvi Sync Journal Inhalte folgen bald.';

  @override
  String get workoutTitle => 'Workout';

  @override
  String get dashboardWearableConnectMessage => 'Verbinde dein Wearable, um deine Trainingsdaten anzeigen zu lassen.';

  @override
  String get dashboardRecommendationsEmpty => 'Keine Empfehlungen verfügbar';

  @override
  String get cyclePhaseMenstruation => 'Menstruation';

  @override
  String get cyclePhaseFollicular => 'Follikelphase';

  @override
  String get cyclePhaseOvulation => 'Ovulationsfenster';

  @override
  String get cyclePhaseLuteal => 'Lutealphase';

  @override
  String get cycleLengthShort => 'Kurz (alle 21-23 Tage)';

  @override
  String get cycleLengthLonger => 'Etwas länger (alle 24-26 Tage)';

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
  String get onboarding06OptionsSemantic => 'Zykluslänge auswählen';

  @override
  String get onboarding06Callout => 'Jeder Zyklus ist einzigartig - wie du auch!';

  @override
  String get onboarding05Title => 'Wie lange dauert deine\nPeriode normalerweise?';

  @override
  String get onboarding05OptionsSemantic => 'Periodendauer auswählen';

  @override
  String get onboarding05OptUnder3 => 'Weniger als 3 Tage';

  @override
  String get onboarding05Opt3to5 => 'Zwischen 3 und 5 Tagen';

  @override
  String get onboarding05Opt5to7 => 'Zwischen 5 und 7 Tagen';

  @override
  String get onboarding05OptOver7 => 'Mehr als 7 Tage';

  @override
  String get onboarding05Callout => 'Wir brauchen diesen Ausgangspunkt, um deine aktuelle Zyklusphase zu berechnen. Ich lerne mit dir mit und passe die Prognosen automatisch an, sobald du deine nächste Periode einträgst.';

  @override
  String get onboarding07Title => 'Wie ist dein Zyklus so?';

  @override
  String get onboarding07OptionsSemantic => 'Zyklusregelmäßigkeit auswählen';

  @override
  String get onboarding07OptRegular => 'Ziemlich regelmäßig';

  @override
  String get onboarding07OptUnpredictable => 'Eher unberechenbar';

  @override
  String get onboarding07OptUnknown => 'Keine Ahnung';

  @override
  String get onboarding07Footnote => 'Ob Uhrwerk oder Chaos - ich verstehe beides!';

  @override
  String get onboardingComplete => 'Onboarding abgeschlossen';
}
