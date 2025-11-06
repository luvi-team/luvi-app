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

  /// Generic error shown when a legal or markdown document cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load document.'**
  String get documentLoadError;

  /// Label for primary continue CTA buttons.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Label for secondary skip actions in onboarding and consent flows.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// Primary CTA label encouraging the user to begin immediately.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get commonStartNow;

  /// Greeting shown in the dashboard header.
  ///
  /// In en, this message translates to:
  /// **'Hey, {name} 💜'**
  String dashboardGreeting(String name);

  /// Semantics label for the dashboard header notifications icon when unread notifications are present.
  ///
  /// In en, this message translates to:
  /// **'Notifications, new alerts available'**
  String get notificationsWithBadge;

  /// Semantics label for the dashboard header notifications icon when an unread count badge is present.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Notifications, {count} new} other {Notifications, {count} new}}'**
  String notificationsWithBadgeCount(int count);

  /// Semantics label for the dashboard header notifications icon when no unread notifications are present.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsNoBadge;

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

  /// Section header title for weekly training carousel on dashboard.
  ///
  /// In en, this message translates to:
  /// **'Your training for this week'**
  String get dashboardTrainingWeekTitle;

  /// Subtitle below weekly training section header.
  ///
  /// In en, this message translates to:
  /// **'Created by your LUVI experts'**
  String get dashboardTrainingWeekSubtitle;

  /// Section header title for phase-specific recommendations on dashboard.
  ///
  /// In en, this message translates to:
  /// **'More Recommendations\nfor Your Phase'**
  String get dashboardRecommendationsTitle;

  /// Subsection title for nutrition recommendations.
  ///
  /// In en, this message translates to:
  /// **'Nutrition & Diet'**
  String get dashboardNutritionTitle;

  /// Subsection title for regeneration and mindfulness recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recovery & Mindfulness'**
  String get dashboardRegenerationTitle;

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

  /// View more action label for weekly training carousel.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get dashboardViewMore;

  /// Label indicating a training session is completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get trainingCompleted;

  /// Semantic label prefix for nutrition recommendation cards.
  ///
  /// In en, this message translates to:
  /// **'Nutrition recommendation'**
  String get nutritionRecommendation;

  /// Semantic label prefix for regeneration recommendation cards.
  ///
  /// In en, this message translates to:
  /// **'Recovery recommendation'**
  String get regenerationRecommendation;

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

  /// Placeholder message shown while the trainings overview screen is under construction.
  ///
  /// In en, this message translates to:
  /// **'Training overview coming soon'**
  String get trainingsOverviewStubPlaceholder;

  /// Accessibility description for the trainings overview placeholder including navigation guidance.
  ///
  /// In en, this message translates to:
  /// **'Training overview is in progress. Use the back button to return to the previous view.'**
  String get trainingsOverviewStubSemantics;

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
  /// **'No recommendations for this phase yet.'**
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

  /// Phrase appended to semantics when a recommendation originates from LUVI Sync.
  ///
  /// In en, this message translates to:
  /// **'From LUVI Sync'**
  String get fromLuviSync;

  /// Semantics hint telling the user they can tap to open the workout.
  ///
  /// In en, this message translates to:
  /// **'Tap to open workout.'**
  String get tapToOpenWorkout;

  /// Semantics hint for the inline cycle calendar prompting navigation to the cycle overview.
  ///
  /// In en, this message translates to:
  /// **'Switch to the cycle overview.'**
  String get cycleInlineCalendarHint;

  /// Semantics label for the inline cycle calendar when today's date and cycle phase are available.
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

  /// Headline for the cycle tip card during menstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get cycleTipHeadlineMenstruation;

  /// Body text for the cycle tip card during menstruation.
  ///
  /// In en, this message translates to:
  /// **'Gentle movement, stretching, or a walk are ideal today — everything is allowed, nothing is mandatory.'**
  String get cycleTipBodyMenstruation;

  /// Headline for the cycle tip card during the follicular phase.
  ///
  /// In en, this message translates to:
  /// **'Follicular phase'**
  String get cycleTipHeadlineFollicular;

  /// Body text for the cycle tip card during the follicular phase.
  ///
  /// In en, this message translates to:
  /// **'You\'re in the follicular phase today. With higher progesterone you may feel more energy. A great time for more intensive training.'**
  String get cycleTipBodyFollicular;

  /// Headline for the cycle tip card during the ovulation window.
  ///
  /// In en, this message translates to:
  /// **'Ovulation window'**
  String get cycleTipHeadlineOvulation;

  /// Body text for the cycle tip card during the ovulation window.
  ///
  /// In en, this message translates to:
  /// **'Short, crisp sessions often work best now. Plan a conscious cool down and hydration afterwards.'**
  String get cycleTipBodyOvulation;

  /// Headline for the cycle tip card during the luteal phase.
  ///
  /// In en, this message translates to:
  /// **'Luteal phase'**
  String get cycleTipHeadlineLuteal;

  /// Body text for the cycle tip card during the luteal phase.
  ///
  /// In en, this message translates to:
  /// **'Switch to calm strength or mobility work. Extra breaks help you maintain your energy level.'**
  String get cycleTipBodyLuteal;

  /// Header title for onboarding step 8 (fitness level).
  ///
  /// In en, this message translates to:
  /// **'How fit do you feel?'**
  String get onboarding08Title;

  /// Semantics label announcing the fitness level options list on step 8.
  ///
  /// In en, this message translates to:
  /// **'Select fitness level'**
  String get onboarding08OptionsSemantic;

  /// Option label for beginner fitness level on step 8.
  ///
  /// In en, this message translates to:
  /// **'I\'m just getting started'**
  String get onboarding08OptBeginner;

  /// Option label for occasional training on step 8.
  ///
  /// In en, this message translates to:
  /// **'I train occasionally'**
  String get onboarding08OptOccasional;

  /// Option label for feeling fit on step 8.
  ///
  /// In en, this message translates to:
  /// **'I feel pretty fit'**
  String get onboarding08OptFit;

  /// Option label when user is unsure about fitness level on step 8.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get onboarding08OptUnknown;

  /// Footnote reassuring the user regardless of fitness level on step 8.
  ///
  /// In en, this message translates to:
  /// **'No stress - we\'ll find your perfect starting point!'**
  String get onboarding08Footnote;

  /// Title shown on the onboarding success screen.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready to go!'**
  String get onboardingSuccessTitle;

  /// Error shown when user state is unavailable while finalizing onboarding.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete onboarding. Please try again.'**
  String get onboardingSuccessStateUnavailable;

  /// Generic error SnackBar on onboarding success screen when an unexpected failure occurs.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onboardingSuccessGenericError;

  /// Subtitle copy for consent welcome screen 1 (below the title). Prepared for future migration away from hardcoded strings.
  ///
  /// In en, this message translates to:
  /// **'Transform your cycle into your strength. Training, nutrition, biohacking — everything perfectly tailored to your hormones.'**
  String get welcome01Subtitle;

  /// Combined title prefix + accent with translatable order/spacing.
  ///
  /// In en, this message translates to:
  /// **'{prefix} {accent}'**
  String welcome01Title(String prefix, String accent);

  /// Leading text for the consent welcome screen 1 title (appears before the accented span). Include trailing space if needed.
  ///
  /// In en, this message translates to:
  /// **'In '**
  String get welcome01TitlePrefix;

  /// Accented word for the consent welcome screen 1 title. Will be styled with the accent color.
  ///
  /// In en, this message translates to:
  /// **'harmony'**
  String get welcome01TitleAccent;

  /// Middle portion of the consent welcome screen 1 title, ends with a newline. Include preceding/trailing spaces as required.
  ///
  /// In en, this message translates to:
  /// **' with your\n'**
  String get welcome01TitleSuffixLine1;

  /// Final line of the consent welcome screen 1 title.
  ///
  /// In en, this message translates to:
  /// **'body'**
  String get welcome01TitleSuffixLine2;

  /// Primary button label for consent welcome screen 1.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get welcome01PrimaryCta;

  /// First line of the consent welcome step 2 title, includes trailing newline.
  ///
  /// In en, this message translates to:
  /// **'Curated by experts for you\n'**
  String get welcome02TitleLine1;

  /// Second line of the consent welcome step 2 title.
  ///
  /// In en, this message translates to:
  /// **'refreshed every month'**
  String get welcome02TitleLine2;

  /// Subtitle copy for consent welcome screen 2 (below the title). Prepared for future migration away from hardcoded strings.
  ///
  /// In en, this message translates to:
  /// **'Real personalization instead of standard plans. Automatically adapted to your progress, cycle phase, and individual goals.'**
  String get welcome02Subtitle;

  /// First line of the consent welcome step 3 title, includes trailing newline to force a line break.
  ///
  /// In en, this message translates to:
  /// **'Your perfect day\n'**
  String get welcome03TitleLine1;

  /// Second line of the consent welcome step 3 title.
  ///
  /// In en, this message translates to:
  /// **'starts here'**
  String get welcome03TitleLine2;

  /// Subtitle copy for consent welcome screen 3 (below the title). Prepared for future migration away from hardcoded strings.
  ///
  /// In en, this message translates to:
  /// **'LUVI Sync: Your daily game-changer. Understand the \"why\" behind your hormones. Scientifically grounded.'**
  String get welcome03Subtitle;

  /// Headline shown on the consent 02 screen. Contains an explicit "\n" line break that must be preserved in every translation.
  ///
  /// In en, this message translates to:
  /// **'Your health,\nyour decision!'**
  String get consent02Title;

  /// Body copy for the required health-processing consent card.
  ///
  /// In en, this message translates to:
  /// **'I agree that LUVI processes my personal health data so LUVI can deliver its features.'**
  String get consent02CardHealth;

  /// Prefix shown before the privacy/terms links on the required terms consent card. Keep trailing space.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get consent02CardTermsPrefix;

  /// Label for the privacy policy deep link on the consent 02 screen.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get consent02LinkPrivacyLabel;

  /// Connector text placed between the privacy and terms links on the consent 02 screen. Surround with spaces as needed.
  ///
  /// In en, this message translates to:
  /// **' as well as the '**
  String get consent02LinkConjunction;

  /// Label for the terms of service deep link on the consent 02 screen.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get consent02LinkTermsLabel;

  /// Title shown in the in-app viewer when opening the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// Title shown in the in-app viewer when opening the terms of service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// Suffix appended after the terms links sentence.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get consent02LinkSuffix;

  /// Body copy for the required AI journal consent card.
  ///
  /// In en, this message translates to:
  /// **'I agree that LUVI uses artificial intelligence to summarize my training, nutrition, and recovery recommendations in a personalized journal.'**
  String get consent02CardAiJournal;

  /// Body copy for the optional analytics consent card.
  ///
  /// In en, this message translates to:
  /// **'I agree that pseudonymized usage and device data are processed for analytics so LUVI can improve stability and usability.*'**
  String get consent02CardAnalytics;

  /// Body copy for the optional marketing consent card.
  ///
  /// In en, this message translates to:
  /// **'I agree that LUVI processes my personal data and usage data to send me personalized recommendations for relevant LUVI content as well as offers via in-app notices, email, and/or push notifications.*'**
  String get consent02CardMarketing;

  /// Body copy for the optional model-training consent card.
  ///
  /// In en, this message translates to:
  /// **'I consent to pseudonymized usage and health data being used for quality assurance and to improve recommendations (e.g., verifying cycle prediction accuracy).*'**
  String get consent02CardModelTraining;

  /// Snackbar error shown when an external legal link cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Link could not be opened'**
  String get consent02LinkError;

  /// Small print hint explaining how to revoke consent.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw your consent at any time in the app or by emailing hello@getluvi.com.'**
  String get consent02RevokeHint;

  /// Primary CTA label that selects all optional consent scopes.
  ///
  /// In en, this message translates to:
  /// **'Accept all'**
  String get consent02AcceptAll;

  /// Primary CTA label shown when all optional consent scopes are already selected so the user can clear them.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get consent02DeselectAll;

  /// Semantics label announcing a consent card is selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get consent02SemanticSelected;

  /// Semantics label announcing a consent card is not selected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get consent02SemanticUnselected;

  /// Headline shown on the login screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 💜'**
  String get authLoginHeadline;

  /// Subheadline displayed under the login headline.
  ///
  /// In en, this message translates to:
  /// **'We\'re glad you\'re here.'**
  String get authLoginSubhead;

  /// Primary call-to-action label on the login screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginCta;

  /// Semantic description announced while the login request is running.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get authLoginCtaLoadingSemantic;

  /// Prefix text for the sign-up link on the login screen. Keep trailing space.
  ///
  /// In en, this message translates to:
  /// **'New to LUVI? '**
  String get authLoginCtaLinkPrefix;

  /// Action link copy directing new users to the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Start here'**
  String get authLoginCtaLinkAction;

  /// Link label that navigates to the forgot-password flow.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authLoginForgot;

  /// Divider text shown above social auth buttons.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authLoginSocialDivider;

  /// Button text for Google sign-in (social auth button).
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authLoginSocialGoogle;

  /// Validation error shown when the email is malformed.
  ///
  /// In en, this message translates to:
  /// **'Please double-check your email.'**
  String get authErrEmailInvalid;

  /// Validation error shown when the password is malformed.
  ///
  /// In en, this message translates to:
  /// **'Please double-check your password.'**
  String get authErrPasswordInvalid;

  /// Validation error when the password is too short.
  ///
  /// In en, this message translates to:
  /// **'Your password is too short.'**
  String get authErrPasswordTooShort;

  /// Validation error when the password is missing required character types.
  ///
  /// In en, this message translates to:
  /// **'Your password must include letters, numbers, and special characters.'**
  String get authErrPasswordMissingTypes;

  /// Validation error when the password is common or weak.
  ///
  /// In en, this message translates to:
  /// **'Your password is too common or weak.'**
  String get authErrPasswordCommonWeak;

  /// Validation error shown when the email field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get authErrEmailEmpty;

  /// Validation error shown when the password field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get authErrPasswordEmpty;

  /// Error displayed when the user's email has not been confirmed.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email (resend the link?).'**
  String get authErrConfirmEmail;

  /// Error shown when Supabase reports invalid credentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authInvalidCredentials;

  /// Generic error message for temporarily unavailable login service.
  ///
  /// In en, this message translates to:
  /// **'Login is currently unavailable.'**
  String get authErrLoginUnavailable;

  /// Error shown when the entered passwords differ.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordMismatchError;

  /// Error shown when the password update request fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update your password.'**
  String get authPasswordUpdateError;

  /// Snackbar/content message advising the user to wait a number of seconds before trying again.
  ///
  /// In en, this message translates to:
  /// **'Please wait {seconds} seconds before retrying.'**
  String authErrWaitBeforeRetry(int seconds);

  /// Hint text for the email input field.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get authEmailHint;

  /// Hint text for the password input field.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get authPasswordHint;

  /// Headline shown on the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Your journey starts here 💜'**
  String get authSignupTitle;

  /// Subtitle encouraging users to complete sign-up.
  ///
  /// In en, this message translates to:
  /// **'Quick signup and you\'re ready to go.'**
  String get authSignupSubtitle;

  /// Primary call-to-action label on the sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignupCta;

  /// Semantic description announced while the sign-up request is running.
  ///
  /// In en, this message translates to:
  /// **'Signing up'**
  String get authSignupCtaLoadingSemantic;

  /// Prefix text for the sign-in link on the sign-up screen. Keep trailing space.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authSignupLinkPrefix;

  /// Link encouraging users to return to the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignupLinkAction;

  /// Hint text for the first-name input.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get authSignupHintFirstName;

  /// Hint text for the last-name input.
  ///
  /// In en, this message translates to:
  /// **'Your last name'**
  String get authSignupHintLastName;

  /// Hint text for the phone-number input.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get authSignupHintPhone;

  /// Error shown when required fields are missing during sign-up.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get authSignupMissingFields;

  /// Generic error shown when the sign-up request fails.
  ///
  /// In en, this message translates to:
  /// **'Sign up is unavailable right now. Please try again later.'**
  String get authSignupGenericError;

  /// Headline for the forgot-password screen.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password? 💜'**
  String get authForgotTitle;

  /// Subtitle explaining the forgot-password process.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive the reset link.'**
  String get authForgotSubtitle;

  /// Primary CTA label on the forgot-password screen.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authForgotCta;

  /// Semantic label for back buttons used in auth flows.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authBackSemantic;

  /// Title shown when the new password was created successfully.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get authSuccessPwdTitle;

  /// Subtitle shown after successfully storing the new password.
  ///
  /// In en, this message translates to:
  /// **'Your new password has been saved.'**
  String get authSuccessPwdSubtitle;

  /// Title shown after a password reset email was sent.
  ///
  /// In en, this message translates to:
  /// **'Email sent!'**
  String get authSuccessForgotTitle;

  /// Subtitle reminding the user to check their inbox after a reset email is sent.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox.'**
  String get authSuccessForgotSubtitle;

  /// Button label closing the success screen.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get authSuccessCta;

  /// Headline for the create-new-password screen.
  ///
  /// In en, this message translates to:
  /// **'Create a new password 💜'**
  String get authCreateNewTitle;

  /// Subtitle for the create-new-password screen.
  ///
  /// In en, this message translates to:
  /// **'Make it strong.'**
  String get authCreateNewSubtitle;

  /// Hint text for the new password input.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authCreateNewHint1;

  /// Hint text for the confirm password input.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authCreateNewHint2;

  /// Primary CTA label when creating a new password.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get authCreateNewCta;

  /// Headline for the password reset verification screen.
  ///
  /// In en, this message translates to:
  /// **'Enter the code 💜'**
  String get authVerifyResetTitle;

  /// Subtitle explaining that the verification code was emailed.
  ///
  /// In en, this message translates to:
  /// **'We just sent it to your email.'**
  String get authVerifyResetSubtitle;

  /// Headline for the email verification screen.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email 💜'**
  String get authVerifyEmailTitle;

  /// Subtitle prompting users to enter the verification code.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get authVerifyEmailSubtitle;

  /// Primary CTA label on the verification screen.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get authVerifyCta;

  /// Helper text prompting the user to request another verification code.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive anything?'**
  String get authVerifyHelper;

  /// Link label to resend the verification code.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get authVerifyResend;

  /// Snackbar text shown when consent was successfully recorded.
  ///
  /// In en, this message translates to:
  /// **'Consent accepted'**
  String get consentSnackbarAccepted;

  /// Snackbar text shown when consent logging fails. No error details are exposed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your consent. Please try again.'**
  String get consentSnackbarError;
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
