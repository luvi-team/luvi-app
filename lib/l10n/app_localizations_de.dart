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
  String get commonStartNow => 'Starte jetzt';

  @override
  String dashboardGreeting(String name) {
    return 'Hey, $name 💜';
  }

  @override
  String get notificationsWithBadge => 'Benachrichtigungen – neue Hinweise verfügbar';

  @override
  String notificationsWithBadgeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Benachrichtigungen – $count neu',
      one: 'Benachrichtigungen – $count neu',
    );
    return '$_temp0';
  }

  @override
  String get notificationsNoBadge => 'Benachrichtigungen';

  @override
  String get dashboardCategoriesTitle => 'Kategorien';

  @override
  String get dashboardTopRecommendationTitle => 'Deine Top-Empfehlung';

  @override
  String get dashboardMoreTrainingsTitle => 'Weitere Trainings';

  @override
  String get dashboardTrainingDataTitle => 'Deine Trainingsdaten';

  @override
  String get dashboardTrainingWeekTitle => 'Dein Training für diese Woche';

  @override
  String get dashboardTrainingWeekSubtitle => 'Erstellt von deinen LUVI-Expert:innen';

  @override
  String get dashboardRecommendationsTitle => 'Weitere Empfehlungen für dich';

  @override
  String get dashboardNutritionTitle => 'Ernährung & Biohacking';

  @override
  String get dashboardRegenerationTitle => 'Regeneration & Achtsamkeit';

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
  String get dashboardViewMore => 'Mehr sehen';

  @override
  String get trainingCompleted => 'Erledigt';

  @override
  String get nutritionRecommendation => 'Ernährungsempfehlung';

  @override
  String get regenerationRecommendation => 'Regenerationsempfehlung';

  @override
  String get dashboardLuviSyncTitle => 'Luvi Sync Journal';

  @override
  String get dashboardLuviSyncPlaceholder => 'Luvi Sync Journal Inhalte folgen bald.';

  @override
  String get trainingsOverviewStubPlaceholder => 'Trainingsübersicht folgt bald';

  @override
  String get trainingsOverviewStubSemantics => 'Trainingsübersicht in Vorbereitung. Tippe auf Zurück, um zur vorherigen Ansicht zu wechseln.';

  @override
  String get workoutTitle => 'Workout';

  @override
  String get dashboardWearableConnectMessage => 'Verbinde dein Wearable, um deine Trainingsdaten anzeigen zu lassen.';

  @override
  String get dashboardHeroCtaMore => 'Mehr';

  @override
  String get dashboardRecommendationsEmpty => 'Für diese Phase liegen noch keine Empfehlungen vor.';

  @override
  String get topRecommendation => 'Top-Empfehlung';

  @override
  String get category => 'Kategorie';

  @override
  String get fromLuviSync => 'Von LUVI Sync';

  @override
  String get tapToOpenWorkout => 'Tippe, um das Workout zu öffnen.';

  @override
  String get cycleInlineCalendarHint => 'Zur Zyklusübersicht wechseln.';

  @override
  String cycleInlineCalendarLabelToday(String date, String phase) {
    return 'Zykluskalender. Heute $date Phase: $phase. Nur zur Orientierung – kein medizinisches Vorhersage- oder Diagnosetool.';
  }

  @override
  String get cycleInlineCalendarLabelDefault => 'Zykluskalender. Zur Zyklusübersicht wechseln. Nur zur Orientierung – kein medizinisches Vorhersage- oder Diagnosetool.';

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

  @override
  String get cycleTipHeadlineMenstruation => 'Menstruation';

  @override
  String get cycleTipBodyMenstruation => 'Sanfte Bewegung, Stretching oder ein Spaziergang sind heute ideale Begleiter - alles darf, nichts muss.';

  @override
  String get cycleTipHeadlineFollicular => 'Follikelphase';

  @override
  String get cycleTipBodyFollicular => 'Du bist heute in der Follikelphase. Aufgrund des steigenden Östrogenspiegels hast du mehr Energie. Beste Zeit für ein intensiveres Training.';

  @override
  String get cycleTipHeadlineOvulation => 'Ovulationsfenster';

  @override
  String get cycleTipBodyOvulation => 'Kurze, knackige Sessions funktionieren jetzt meist am besten. Plane danach bewusst Cool-down & Hydration ein.';

  @override
  String get cycleTipHeadlineLuteal => 'Lutealphase';

  @override
  String get cycleTipBodyLuteal => 'Wechsle auf ruhige Kraft- oder Mobility-Einheiten. Zusätzliche Pausen helfen dir, das Energielevel zu halten.';

  @override
  String get onboarding08Title => 'Wie fit fühlst du dich?';

  @override
  String get onboarding08OptionsSemantic => 'Fitnesslevel auswählen';

  @override
  String get onboarding08OptBeginner => 'Ich fange gerade erst an';

  @override
  String get onboarding08OptOccasional => 'Trainiere ab und zu';

  @override
  String get onboarding08OptFit => 'Fühle mich ziemlich fit';

  @override
  String get onboarding08OptUnknown => 'Weiß ich nicht';

  @override
  String get onboarding08Footnote => 'Kein Stress - wir finden deinen perfekten Einstieg!';

  @override
  String get onboardingSuccessTitle => 'Du bist startklar!';

  @override
  String get onboardingSuccessButton => 'Los geht\'s!';

  @override
  String get welcome01Subtitle => 'Verwandle deinen Zyklus in deine Stärke. Training, Ernährung, Biohacking – alles perfekt auf deine Hormone abgestimmt.';

  @override
  String get welcome02Subtitle => 'Echte Personalisierung statt Standard‑Pläne. Automatisch angepasst an deine Fortschritte, Zyklusphase und individuellen Ziele.';

  @override
  String get welcome03Subtitle => 'LUVI Sync: Dein täglicher Game‑Changer. Verstehe das \'Warum\' hinter deinen Hormonen. Wissenschaftlich fundiert.';

  @override
  String get consent02Title => 'Deine Gesundheit,\ndeine Entscheidung!';

  @override
  String get consent02CardHealth => 'Ich bin damit einverstanden, dass LUVI meine persönlichen Gesundheitsdaten verarbeitet, damit LUVI ihre Funktionen bereitstellen kann.';

  @override
  String get consent02CardTermsPrefix => 'Ich erkläre mich mit der ';

  @override
  String get consent02LinkPrivacyLabel => 'Datenschutzerklärung';

  @override
  String get consent02LinkConjunction => ' sowie den ';

  @override
  String get consent02LinkTermsLabel => 'Nutzungsbedingungen';

  @override
  String get consent02LinkSuffix => ' einverstanden.';

  @override
  String get consent02CardAiJournal => 'Ich bin damit einverstanden, dass LUVI künstliche Intelligenz nutzt, um meine Trainings-, Ernährungs- und Regenerationsempfehlungen in einem personalisierten Journal für mich zusammenzufassen.';

  @override
  String get consent02CardAnalytics => 'Ich bin damit einverstanden, dass pseudonymisierte Nutzungs- und Gerätedaten zu Analysezwecken verarbeitet werden, damit LUVI Stabilität und Benutzerfreundlichkeit verbessern kann.*';

  @override
  String get consent02CardMarketing => 'Ich stimme zu, dass LUVI meine persönlichen Daten und Nutzungsdaten verarbeitet, um mir personalisierte Empfehlungen zu relevanten LUVI-Inhalten und Informationen zu Angeboten per In-App-Hinweisen, E-Mail und/oder Push-Mitteilungen zuzusenden.*';

  @override
  String get consent02CardModelTraining => 'Ich willige ein, dass pseudonymisierte Nutzungs- und Gesundheitsdaten zur Qualitätssicherung und Verbesserung von Empfehlungen verwendet werden (z. B. Überprüfung der Genauigkeit von Zyklusvorhersagen).*';

  @override
  String get consent02LinkError => 'Link konnte nicht geöffnet werden';

  @override
  String get consent02RevokeHint => 'Deine Zustimmung kannst du jederzeit in der App oder unter hello@getluvi.com widerrufen.';

  @override
  String get consent02AcceptAll => 'Alle akzeptieren';

  @override
  String get consent02SemanticSelected => 'Ausgewählt';

  @override
  String get consent02SemanticUnselected => 'Nicht ausgewählt';
}
