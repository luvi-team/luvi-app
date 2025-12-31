// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get onboarding01Title => 'Willkommen!\nWie dürfen wir dich nennen?';

  @override
  String onboardingStepSemantic(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get onboarding01Instruction => 'Wie soll ich dich nennen?';

  @override
  String get onboarding01NameInputSemantic => 'Name eingeben';

  @override
  String get onboarding01NameHint => 'Dein Vorname';

  @override
  String onboarding02Title(String name) {
    return 'Hey $name,\nwann hast du Geburtstag?';
  }

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
  String get initBannerConfigError => 'Konfigurationsfehler: Supabase-Zugangsdaten ungültig. App läuft offline.';

  @override
  String initBannerConnecting(int attempts, int maxAttempts) {
    return 'Verbindung zum Server… (Versuch $attempts/$maxAttempts)';
  }

  @override
  String get initBannerRetry => 'Erneut versuchen';

  @override
  String get documentLoadError => 'Dokument konnte nicht geladen werden.';

  @override
  String get legalViewerLoadingLabel => 'Dokument wird geladen';

  @override
  String get legalViewerFallbackBanner => 'Remote nicht verfügbar — Offline-Kopie wird angezeigt.';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonSkip => 'Überspringen';

  @override
  String get commonStartNow => 'Los geht\'s!';

  @override
  String get commonToday => 'HEUTE';

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
  String get onboarding07Title => 'Wie regelmäßig ist dein Zyklus?';

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
  String get errorInvalidWorkoutId => 'Ungültige Workout-ID';

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
  String get onboardingSuccessStateUnavailable => 'Onboarding konnte nicht abgeschlossen werden. Bitte versuche es erneut.';

  @override
  String get onboardingSuccessGenericError => 'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get welcome01Title => 'Dein Körper. Dein Rhythmus. Jeden Tag.';

  @override
  String get welcome01Subtitle => 'Dein täglicher Begleiter für Training, Ernährung, Schlaf & mehr.';

  @override
  String get welcome02Title => 'In Sekunden wissen, was heute zählt.';

  @override
  String get welcome02Subtitle => 'Kein Suchen, kein Raten. LUVI zeigt dir den nächsten Schritt.';

  @override
  String get welcome03Title => 'Passt sich deinem Zyklus an.';

  @override
  String get welcome03Subtitle => 'Damit du mit deinem Körper arbeitest, nicht gegen ihn.';

  @override
  String get welcome04Title => 'Von Expert:innen erstellt.';

  @override
  String get welcome04Subtitle => 'Kein Algorithmus, sondern echte Menschen.';

  @override
  String get welcome05Title => 'Kleine Schritte heute. Große Wirkung morgen.';

  @override
  String get welcome05Subtitle => 'Für jetzt – und dein zukünftiges Ich.';

  @override
  String get welcome05PrimaryCta => 'Jetzt loslegen';

  @override
  String get consent01IntroTitle => 'Lass uns LUVI\nauf dich abstimmen';

  @override
  String get consent01IntroBody => 'Du entscheidest, was du teilen möchtest. Je mehr wir über dich wissen, desto besser können wir dich unterstützen.';

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
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String get termsOfServiceTitle => 'Nutzungsbedingungen';

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
  String get consent02DeselectAll => 'Alle abwählen';

  @override
  String get consent02SemanticSelected => 'Ausgewählt';

  @override
  String get consent02SemanticUnselected => 'Nicht ausgewählt';

  @override
  String get authLoginHeadline => 'Willkommen zurück 💜';

  @override
  String get authLoginTitle => 'Anmelden mit E-Mail';

  @override
  String get authLoginSubhead => 'Schön, dass du da bist.';

  @override
  String get authLoginCta => 'Anmelden';

  @override
  String get authLoginCtaLoadingSemantic => 'Wird angemeldet';

  @override
  String get authLoginCtaLinkPrefix => 'Neu bei LUVI? ';

  @override
  String get authLoginCtaLinkAction => 'Hier starten';

  @override
  String get authLoginCtaLinkSemantic => 'Neu bei LUVI? Hier starten';

  @override
  String get authLoginForgot => 'Passwort vergessen?';

  @override
  String get authLoginSocialDivider => 'Oder weiter mit';

  @override
  String get authLoginSocialGoogle => 'Mit Google anmelden';

  @override
  String get authErrEmailInvalid => 'Bitte überprüfe deine E-Mail.';

  @override
  String get authErrPasswordInvalid => 'Bitte überprüfe dein Passwort.';

  @override
  String get authErrPasswordTooShort => 'Dein Passwort ist zu kurz.';

  @override
  String get authErrPasswordMissingTypes => 'Dein Passwort muss Buchstaben, Zahlen und Sonderzeichen enthalten.';

  @override
  String get authErrPasswordCommonWeak => 'Dein Passwort ist zu häufig oder zu schwach.';

  @override
  String get authErrEmailEmpty => 'Bitte gib deine E-Mail ein.';

  @override
  String get authErrPasswordEmpty => 'Bitte gib dein Passwort ein.';

  @override
  String get authErrConfirmEmail => 'Bitte bestätige deine E-Mail (Link erneut senden?).';

  @override
  String get authInvalidCredentials => 'E-Mail oder Passwort ist falsch.';

  @override
  String get authErrLoginUnavailable => 'Anmeldung ist derzeit nicht verfügbar.';

  @override
  String get authPasswordMismatchError => 'Passwörter stimmen nicht überein.';

  @override
  String get authPasswordUpdateError => 'Wir konnten dein Passwort nicht aktualisieren.';

  @override
  String authErrWaitBeforeRetry(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '# Sekunden',
      one: '# Sekunde',
    );
    return 'Bitte warte $_temp0, bevor du es erneut versuchst.';
  }

  @override
  String get authEmailHint => 'Deine E-Mail';

  @override
  String get authPasswordHint => 'Dein Passwort';

  @override
  String get authSignupTitle => 'Konto erstellen';

  @override
  String get authSignupSubtitle => 'Schnell registrieren und loslegen.';

  @override
  String get authSignupAlreadyMember => 'Schon dabei? ';

  @override
  String get authSignupLoginLink => 'Anmelden';

  @override
  String get authSignupCta => 'Registrieren';

  @override
  String get authSignupCtaLoadingSemantic => 'Wird registriert';

  @override
  String get authSignupHintFirstName => 'Dein Vorname';

  @override
  String get authSignupHintLastName => 'Dein Nachname';

  @override
  String get authSignupHintPhone => 'Deine Telefonnummer';

  @override
  String get authSignupMissingFields => 'Bitte E-Mail und Passwort eingeben.';

  @override
  String get authSignupGenericError => 'Registrierung ist gerade nicht verfügbar. Bitte später erneut versuchen.';

  @override
  String get authForgotTitle => 'Passwort vergessen? 💜';

  @override
  String get authForgotSubtitle => 'Gib deine E-Mail ein, um den Reset-Link zu erhalten.';

  @override
  String get authForgotCta => 'Weiter';

  @override
  String get authBackSemantic => 'Zurück';

  @override
  String get authSuccessPwdTitle => 'Geschafft!';

  @override
  String get authSuccessPwdSubtitle => 'Dein neues Passwort wurde gespeichert.';

  @override
  String get authSuccessForgotTitle => 'E-Mail gesendet!';

  @override
  String get authSuccessForgotSubtitle => 'Bitte prüfe deinen Posteingang.';

  @override
  String get authSuccessCta => 'Fertig';

  @override
  String get authCreateNewSubtitle => 'Mach es stark.';

  @override
  String get authVerifyResetTitle => 'Code eingeben 💜';

  @override
  String get authVerifyResetSubtitle => 'Wir haben ihn gerade an deine E-Mail gesendet.';

  @override
  String get authVerifyEmailTitle => 'E-Mail bestätigen 💜';

  @override
  String get authVerifyEmailSubtitle => 'Code eingeben';

  @override
  String get authVerifyCta => 'Bestätigen';

  @override
  String get authVerifyHelper => 'Nichts erhalten?';

  @override
  String get authVerifyResend => 'Erneut senden';

  @override
  String get consentSnackbarAccepted => 'Einwilligung akzeptiert';

  @override
  String get consentSnackbarError => 'Wir konnten deine Einwilligung nicht speichern. Bitte versuche es erneut.';

  @override
  String get consentErrorSavingConsent => 'Wir konnten nicht alle deine Einstellungen speichern. Du kannst trotzdem fortfahren und es später erneut versuchen.';

  @override
  String get consentSnackbarRateLimited => 'Zu viele Anfragen gerade. Bitte warte kurz und versuche es erneut.';

  @override
  String get consentSnackbarServiceUnavailable => 'Der Dienst ist vorübergehend nicht erreichbar. Bitte versuche es später erneut.';

  @override
  String get consentSnackbarServerError => 'Ein Serverfehler ist aufgetreten. Bitte versuche es später erneut.';

  @override
  String get authSignInHeadline => 'Verpasse es nicht, das Beste aus dir zu machen!';

  @override
  String get authSignInEmail => 'Anmelden mit E-Mail';

  @override
  String get authSignInGoogle => 'Anmelden mit Google';

  @override
  String get authSignInApple => 'Anmelden mit Apple';

  @override
  String get authSignInLoading => 'Anmeldung läuft';

  @override
  String get authSignInOAuthError => 'Anmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authSignInAppleError => 'Apple-Anmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authSignInGoogleError => 'Google-Anmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authResetTitle => 'Passwort vergessen?';

  @override
  String get authResetSubtitle => 'Gib deine E-Mail ein und wir schicken dir einen Link zum Zurücksetzen zu.';

  @override
  String get authResetCta => 'Passwort zurücksetzen';

  @override
  String get authResetEmailSent => 'E-Mail zum Zurücksetzen wurde gesendet.';

  @override
  String get authNewPasswordTitle => 'Neues Passwort erstellen';

  @override
  String get authNewPasswordHint => 'Neues Passwort';

  @override
  String get authConfirmPasswordHint => 'Neues Passwort bestätigen';

  @override
  String get authCreatePasswordCta => 'Passwort zurücksetzen';

  @override
  String get authSuccessBackToLogin => 'Zurück zur Anmeldung';

  @override
  String get authSignupSuccess => 'Registrierung erfolgreich! Du kannst dich jetzt anmelden.';

  @override
  String get interestStrengthTraining => 'Krafttraining & Muskelaufbau';

  @override
  String get interestCardio => 'Cardio & Ausdauer';

  @override
  String get interestMobility => 'Beweglichkeit & Mobilität';

  @override
  String get interestNutrition => 'Ernährung & Supplements';

  @override
  String get interestMindfulness => 'Achtsamkeit & Regeneration';

  @override
  String get interestHormonesCycle => 'Hormone & Zyklus';

  @override
  String onboarding02AgeTooYoung(int minAge) {
    return 'Du musst mindestens $minAge Jahre alt sein.';
  }

  @override
  String onboarding02AgeTooOld(int maxAge) {
    return 'Das maximale Alter beträgt $maxAge Jahre.';
  }

  @override
  String get fitnessLevelBeginner => 'Gerade gestartet';

  @override
  String get fitnessLevelOccasional => 'Gelegentlich aktiv';

  @override
  String get fitnessLevelFit => 'Sehr aktiv';

  @override
  String get consentIntroTitle => 'Lass uns LUVI für dich personalisieren';

  @override
  String get consentIntroBody => 'Um LUVI für dich zu personalisieren, brauchen wir zuerst dein Okay.';

  @override
  String get consentIntroCtaLabel => 'Weiter';

  @override
  String get consentIntroIllustrationSemantic => 'Illustration: Hand hält Stift zum Unterschreiben';

  @override
  String get consentIntroCtaSemantic => 'Weiter zur Datenschutz-Einwilligung';

  @override
  String get consentOptionsTitle => 'Deine Datenschutz-Einstellungen';

  @override
  String get consentOptionsSubtitle => 'Sicher gespeichert, streng geschützt. DSGVO, EU-Hosting';

  @override
  String get consentOptionsSectionRequired => 'ERFORDERLICH';

  @override
  String get consentOptionsSectionOptional => 'OPTIONAL';

  @override
  String get consentOptionsHealthText => 'Ich bin damit einverstanden, dass LUVI meine Gesundheits- und Zyklusdaten verarbeitet, um mir zyklusbewusste Empfehlungen zu geben.';

  @override
  String get consentOptionsTermsPrefix => 'Ich akzeptiere die ';

  @override
  String get consentOptionsTermsLink => 'Nutzungsbedingungen';

  @override
  String get consentOptionsTermsConjunction => ' und habe die ';

  @override
  String get consentOptionsPrivacyLink => 'Datenschutzerklärung';

  @override
  String get consentOptionsTermsSuffix => ' zur Kenntnis genommen.';

  @override
  String get consentOptionsAnalyticsText => 'Ich bin damit einverstanden, dass LUVI pseudonymisierte Nutzungs- und Gerätedaten (z.B. Crash-Infos, Performance, genutzte Funktionen) verarbeitet, um Fehler zu beheben und die App zu verbessern.';

  @override
  String get consentOptionsAnalyticsRevoke => 'Widerruf jederzeit unter Profil → Datenschutz.';

  @override
  String get consentOptionsCtaContinue => 'Weiter';

  @override
  String get consentOptionsCtaAcceptAll => 'Alles akzeptieren';

  @override
  String consentOptionsCheckboxSelectedSemantic(String section, String text) {
    return '$section: $text. Ausgewählt';
  }

  @override
  String consentOptionsCheckboxUnselectedSemantic(String section, String text) {
    return '$section: $text. Nicht ausgewählt';
  }

  @override
  String get consentOptionsShieldSemantic => 'Schild-Symbol für Datenschutz';

  @override
  String get consentBlockingTitle => 'Deine Zustimmung macht LUVI möglich';

  @override
  String get consentBlockingBody => 'LUVI braucht deine Zyklus- und Gesundheitsangaben, um dir zyklusbasierte Inhalte und Empfehlungen anzuzeigen. Ohne diese Verarbeitung können wir den Dienst nicht bereitstellen.';

  @override
  String get consentBlockingCtaBack => 'Zurück & Zustimmen';

  @override
  String get consentBlockingCtaSemantic => 'Zurück zur Einwilligung';

  @override
  String get consentBlockingShieldSemantic => 'Schild-Symbol für Datenschutz';

  @override
  String onboarding03FitnessTitle(String name) {
    return '$name, wie fit fühlst du dich?';
  }

  @override
  String get onboarding03FitnessSubtitle => 'Damit wir die Intensität passend wählen.';

  @override
  String get onboarding03FitnessSemantic => 'Fitnesslevel auswählen';

  @override
  String get onboarding04GoalsTitle => 'Was sind deine Ziele?';

  @override
  String get onboarding04GoalsSubtitle => 'Du kannst mehrere auswählen.';

  @override
  String get onboarding04GoalsSemantic => 'Ziele auswählen';

  @override
  String get onboarding05InterestsTitle => 'Was interessiert dich?';

  @override
  String get onboarding05InterestsSubtitle => 'Wähle 3–5, damit dein Feed direkt passt.';

  @override
  String get onboarding05InterestsSemantic => 'Interessen auswählen';

  @override
  String get onboarding06PeriodTitle => 'Tippe auf den Tag, an dem deine letzte Periode begann.';

  @override
  String get onboarding06PeriodUnknown => 'Ich weiß es nicht mehr';

  @override
  String get onboarding06PeriodSubheader => 'Du kannst das später ändern.';

  @override
  String get onboarding07DurationTitle => 'Sieht das richtig aus?';

  @override
  String get onboarding07DurationSubtitle => 'Wir haben die Dauer geschätzt. Tippe auf den Tag, um anzupassen.';

  @override
  String get onboarding08SuccessLoading => 'Wir stellen deine Ergebnisse zusammen...';

  @override
  String onboardingProgressLabel(int current, int total) {
    return 'Frage $current von $total';
  }

  @override
  String get onboardingDefaultName => 'Du';

  @override
  String get weekdayMondayShort => 'Mo';

  @override
  String get weekdayTuesdayShort => 'Di';

  @override
  String get weekdayWednesdayShort => 'Mi';

  @override
  String get weekdayThursdayShort => 'Do';

  @override
  String get weekdayFridayShort => 'Fr';

  @override
  String get weekdaySaturdayShort => 'Sa';

  @override
  String get weekdaySundayShort => 'So';

  @override
  String get periodCalendarSemanticToday => 'Heute';

  @override
  String get periodCalendarSemanticSelected => 'ausgewählt';

  @override
  String get periodCalendarSemanticPeriodDay => 'Periodentag';

  @override
  String get onboardingCycleIntroTitle => 'Damit LUVI für dich passt, brauchen wir noch deinen Zyklusstart.';

  @override
  String get onboardingCycleIntroButton => 'Okay, los';

  @override
  String get onboardingSuccessLoading => 'Wir stellen deine Pläne zusammen...';

  @override
  String get onboardingSuccessSaving => 'Wird gespeichert...';

  @override
  String get onboardingSuccessComplete => 'Fertig!';

  @override
  String get onboardingSaveError => 'Speichern fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get onboardingRetryButton => 'Erneut versuchen';

  @override
  String get onboardingContentCard1 => 'Brauche ich mehr Eisen während meiner Blutung?';

  @override
  String get onboardingContentCard2 => 'Wie trainiere ich während meiner Ovulation?';

  @override
  String get onboardingContentCard3 => 'Wie kann ich meinen Stress reduzieren?';

  @override
  String get goalFitter => 'Fitter & stärker werden';

  @override
  String get goalEnergy => 'Mehr Energie im Alltag';

  @override
  String get goalSleep => 'Besser schlafen und Stress reduzieren';

  @override
  String get goalCycle => 'Zyklus & Hormone verstehen';

  @override
  String get goalLongevity => 'Langfristige Gesundheit und Longevity';

  @override
  String get goalWellbeing => 'Mich einfach wohlfühlen';

  @override
  String get commonBack => 'Zurück';

  @override
  String get semanticCalendarPreview => 'Kalendervorschau für Zyklustracking';

  @override
  String get semanticLoadingProgress => 'Ladefortschritt';

  @override
  String semanticProgressPercent(int percent) {
    return '$percent Prozent';
  }

  @override
  String get splashGateUnknownTitle => 'Kurze Unterbrechung';

  @override
  String get splashGateUnknownBody => 'Um weiterzumachen, brauchen wir eine Internetverbindung. Prüfe kurz deine Verbindung.';

  @override
  String get splashGateRetryCta => 'Nochmal probieren';

  @override
  String get splashGateSignOutCta => 'Abmelden';

  @override
  String get signOutErrorRetry => 'Abmeldung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get signOutFailed => 'Abmeldung fehlgeschlagen. Du kannst dich erneut anmelden.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get authLoginHeaderSemantic => 'Willkommen zurück';
}
