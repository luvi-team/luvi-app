import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// Header title for onboarding step 1.
  ///
  /// In en, this message translates to:
  /// **'Tell me about yourself 💜'**
  String get onboarding01Title;

  /// Spoken step indicator for onboarding progress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepSemantic(int current, int total);

  /// Instruction copy asking the user for their preferred name on step 1.
  ///
  /// In en, this message translates to:
  /// **'What should I call you?'**
  String get onboarding01Instruction;

  /// Semantics label for the name input field on step 1.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get onboarding01NameInputSemantic;

  /// Header title for onboarding step 2 (birthday). Includes a forced line break to match the Figma layout; keep the newline when translating.
  ///
  /// In en, this message translates to:
  /// **'When is your\nbirthday?'**
  String get onboarding02Title;

  /// Accessibility announcement for the onboarding 02 callout info box.
  ///
  /// In en, this message translates to:
  /// **'Note: Your age helps us better understand your hormonal phase.'**
  String get onboarding02CalloutSemantic;

  /// Body text displayed inside the onboarding 02 callout card.
  ///
  /// In en, this message translates to:
  /// **'Your age helps us better understand your hormonal phase.'**
  String get onboarding02CalloutBody;

  /// Semantics label for the birth date picker on onboarding step 2.
  ///
  /// In en, this message translates to:
  /// **'Select birth date'**
  String get onboarding02PickerSemantic;

  /// Header title for onboarding step 3 (goals multi-select).
  ///
  /// In en, this message translates to:
  /// **'What are your goals?'**
  String get onboarding03Title;

  /// Short progress indicator displaying the current and total onboarding steps.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String onboardingStepFraction(int current, int total);

  /// Goal option: understand the user's cycle and body better on onboarding step 3.
  ///
  /// In en, this message translates to:
  /// **'Understand my cycle & body better'**
  String get onboarding03GoalCycleUnderstanding;

  /// Goal option: align training with the user's cycle on onboarding step 3.
  ///
  /// In en, this message translates to:
  /// **'Align training with my cycle'**
  String get onboarding03GoalTrainingAlignment;

  /// Goal option: optimize nutrition and find new recipes on onboarding step 3.
  ///
  /// In en, this message translates to:
  /// **'Optimize nutrition & discover new recipes'**
  String get onboarding03GoalNutrition;

  /// Goal option: manage weight on onboarding step 3.
  ///
  /// In en, this message translates to:
  /// **'Manage my weight (lose/maintain)'**
  String get onboarding03GoalWeightManagement;

  /// Goal option: reduce stress and strengthen mindfulness on onboarding step 3.
  ///
  /// In en, this message translates to:
  /// **'Reduce stress & boost mindfulness'**
  String get onboarding03GoalMindfulness;

  /// No description provided for @onboarding04Title.
  ///
  /// In en, this message translates to:
  /// **'When did your last period start?'**
  String get onboarding04Title;

  /// Semantics label announcing the currently selected date on onboarding step 4.
  ///
  /// In en, this message translates to:
  /// **'Selected date: {date}'**
  String selectedDateLabel(String date);

  /// Accessibility announcement for the onboarding 04 callout info box.
  ///
  /// In en, this message translates to:
  /// **'Note: Don\'t worry if you don\'t remember the exact day. A rough estimate is enough to get started.'**
  String get onboarding04CalloutSemantics;

  /// Prefix text displayed before the emphasized part of the onboarding 04 callout.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry if you don\'t remember the '**
  String get onboarding04CalloutPrefix;

  /// Emphasized substring within the onboarding 04 callout text.
  ///
  /// In en, this message translates to:
  /// **'exact day'**
  String get onboarding04CalloutHighlight;

  /// Suffix text displayed after the emphasized part of the onboarding 04 callout.
  ///
  /// In en, this message translates to:
  /// **'. A rough estimate is enough to get started.'**
  String get onboarding04CalloutSuffix;

  /// Label for primary continue CTA buttons.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Greeting shown in the dashboard header.
  ///
  /// In en, this message translates to:
  /// **'Hey, {name} 💜'**
  String dashboardGreeting(String name);

  /// Section header title for the dashboard categories grid.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get dashboardCategoriesTitle;

  /// Section header title for the dashboard top recommendation.
  ///
  /// In en, this message translates to:
  /// **'Your Top Recommendation'**
  String get dashboardTopRecommendationTitle;

  /// Section header title for the additional trainings list.
  ///
  /// In en, this message translates to:
  /// **'More Trainings'**
  String get dashboardMoreTrainingsTitle;

  /// Section header title for the dashboard training stats scroller.
  ///
  /// In en, this message translates to:
  /// **'Your Training Data'**
  String get dashboardTrainingDataTitle;

  /// Label for the Today tab in the bottom navigation dock.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardNavToday;

  /// Label for the Cycle tab in the bottom navigation dock.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get dashboardNavCycle;

  /// Label for the Heart Rate tab in the bottom navigation dock.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get dashboardNavPulse;

  /// Label for the Profile tab in the bottom navigation dock.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get dashboardNavProfile;

  /// Label for the floating Luvi Sync button on the dashboard bottom dock.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get dashboardNavSync;

  /// Label for the Training category chip on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get dashboardCategoryTraining;

  /// Label for the Nutrition category chip on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get dashboardCategoryNutrition;

  /// Label for the Recovery category chip on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get dashboardCategoryRegeneration;

  /// Label for the Mindfulness category chip on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get dashboardCategoryMindfulness;

  /// "View all" trailing action label in dashboard section headers.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dashboardViewAll;

  /// App bar title for the Luvi Sync Journal stub screen.
  ///
  /// In en, this message translates to:
  /// **'Luvi Sync Journal'**
  String get dashboardLuviSyncTitle;

  /// Placeholder copy for the Luvi Sync Journal stub screen body.
  ///
  /// In en, this message translates to:
  /// **'Luvi Sync Journal content coming soon.'**
  String get dashboardLuviSyncPlaceholder;

  /// App bar title for the workout detail stub screen.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutTitle;

  /// Fallback message shown when no wearable is connected to sync stats.
  ///
  /// In en, this message translates to:
  /// **'Connect your wearable to display your training data.'**
  String get dashboardWearableConnectMessage;

  /// CTA label on dashboard hero card to see more content.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get dashboardHeroCtaMore;

  /// Placeholder text shown when there are no dashboard recommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations available'**
  String get dashboardRecommendationsEmpty;

  /// Semantics prefix describing the dashboard top recommendation tile.
  ///
  /// In en, this message translates to:
  /// **'Top recommendation'**
  String get topRecommendation;

  /// Label used when announcing the category in a semantics description.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Phrase appended when a recommendation originates from LUVI Sync.
  ///
  /// In en, this message translates to:
  /// **'From LUVI Sync'**
  String get fromLuviSync;

  /// Semantics hint instructing the user to tap to open the workout.
  ///
  /// In en, this message translates to:
  /// **'Tap to open workout.'**
  String get tapToOpenWorkout;

  /// Semantics hint for the inline cycle calendar prompting navigation to the cycle overview.
  ///
  /// In en, this message translates to:
  /// **'Switch to the cycle overview.'**
  String get cycleInlineCalendarHint;

  /// Semantics label for the inline cycle calendar when today's date and phase are available.
  ///
  /// In en, this message translates to:
  /// **'Cycle calendar. Today {date} phase: {phase}. For orientation only - not a medical prediction or diagnostic tool.'**
  String cycleInlineCalendarLabelToday(String date, String phase);

  /// Semantics label for the inline cycle calendar when today's information is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Cycle calendar. Switch to the cycle overview. For orientation only - not a medical prediction or diagnostic tool.'**
  String get cycleInlineCalendarLabelDefault;

  /// Display name for the menstruation phase.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get cyclePhaseMenstruation;

  /// Display name for the follicular phase.
  ///
  /// In en, this message translates to:
  /// **'Follicular phase'**
  String get cyclePhaseFollicular;

  /// Display name for the ovulation window.
  ///
  /// In en, this message translates to:
  /// **'Ovulation window'**
  String get cyclePhaseOvulation;

  /// Display name for the luteal phase.
  ///
  /// In en, this message translates to:
  /// **'Luteal phase'**
  String get cyclePhaseLuteal;

  /// Cycle length option describing short cycles.
  ///
  /// In en, this message translates to:
  /// **'Short (every 21-23 days)'**
  String get cycleLengthShort;

  /// Cycle length option describing slightly longer cycles.
  ///
  /// In en, this message translates to:
  /// **'A bit longer (every 24-26 days)'**
  String get cycleLengthLonger;

  /// Cycle length option describing standard cycles.
  ///
  /// In en, this message translates to:
  /// **'Standard (every 27-30 days)'**
  String get cycleLengthStandard;

  /// Cycle length option describing longer cycles.
  ///
  /// In en, this message translates to:
  /// **'Longer (every 31-35 days)'**
  String get cycleLengthLong;

  /// Cycle length option describing very long cycles.
  ///
  /// In en, this message translates to:
  /// **'Very long (36+ days)'**
  String get cycleLengthVeryLong;

  /// Header title for onboarding step 6.
  ///
  /// In en, this message translates to:
  /// **'Tell me about yourself 💜'**
  String get onboarding06Title;

  /// Question text for onboarding step 6 (cycle length).
  ///
  /// In en, this message translates to:
  /// **'How long does your cycle normally last?'**
  String get onboarding06Question;

  /// Semantics label announcing the cycle length options list on step 6.
  ///
  /// In en, this message translates to:
  /// **'Select cycle length'**
  String get onboarding06OptionsSemantic;

  /// Supporting callout text shown below the cycle length options on step 6.
  ///
  /// In en, this message translates to:
  /// **'Every cycle is unique - just like you!'**
  String get onboarding06Callout;

  /// Header title for onboarding step 5 (period duration).
  ///
  /// In en, this message translates to:
  /// **'How long does your\nperiod usually last?'**
  String get onboarding05Title;

  /// Semantics label announcing the period duration options list on step 5.
  ///
  /// In en, this message translates to:
  /// **'Select period duration'**
  String get onboarding05OptionsSemantic;

  /// Option label for periods shorter than three days.
  ///
  /// In en, this message translates to:
  /// **'Less than 3 days'**
  String get onboarding05OptUnder3;

  /// Option label for periods lasting three to five days.
  ///
  /// In en, this message translates to:
  /// **'Between 3 and 5 days'**
  String get onboarding05Opt3to5;

  /// Option label for periods lasting five to seven days.
  ///
  /// In en, this message translates to:
  /// **'Between 5 and 7 days'**
  String get onboarding05Opt5to7;

  /// Option label for periods longer than seven days.
  ///
  /// In en, this message translates to:
  /// **'More than 7 days'**
  String get onboarding05OptOver7;

  /// Callout copy explaining why period duration is needed on step 5.
  ///
  /// In en, this message translates to:
  /// **'We need this starting point to calculate your current cycle phase. I learn with you and automatically adjust the predictions as soon as you log your next period.'**
  String get onboarding05Callout;

  /// Header title for onboarding step 7 (cycle regularity).
  ///
  /// In en, this message translates to:
  /// **'What is your cycle like?'**
  String get onboarding07Title;

  /// Semantics label announcing the cycle regularity options list on step 7.
  ///
  /// In en, this message translates to:
  /// **'Select cycle regularity'**
  String get onboarding07OptionsSemantic;

  /// Option label for regular cycles on step 7.
  ///
  /// In en, this message translates to:
  /// **'Pretty regular'**
  String get onboarding07OptRegular;

  /// Option label for unpredictable cycles on step 7.
  ///
  /// In en, this message translates to:
  /// **'Mostly unpredictable'**
  String get onboarding07OptUnpredictable;

  /// Option label when the user is unsure about their cycle regularity on step 7.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get onboarding07OptUnknown;

  /// Footnote reassuring the user regardless of cycle regularity on step 7.
  ///
  /// In en, this message translates to:
  /// **'Clockwork or chaos - I get both!'**
  String get onboarding07Footnote;

  /// Completion message shown on the onboarding done route.
  ///
  /// In en, this message translates to:
  /// **'Onboarding complete'**
  String get onboardingComplete;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
