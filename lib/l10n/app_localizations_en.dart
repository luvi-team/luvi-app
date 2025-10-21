// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboarding01Title => 'Tell me about yourself 💜';

  @override
  String onboardingStepSemantic(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboarding01Instruction => 'What should I call you?';

  @override
  String get onboarding01NameInputSemantic => 'Enter your name';

  @override
  String get onboarding02Title => 'When is your\nbirthday?';

  @override
  String get onboarding02CalloutSemantic => 'Note: Your age helps us better understand your hormonal phase.';

  @override
  String get onboarding02CalloutBody => 'Your age helps us better understand your hormonal phase.';

  @override
  String get onboarding02PickerSemantic => 'Select birth date';

  @override
  String get onboarding03Title => 'What are your goals?';

  @override
  String onboardingStepFraction(int current, int total) {
    return '$current/$total';
  }

  @override
  String get onboarding03GoalCycleUnderstanding => 'Understand my cycle & body better';

  @override
  String get onboarding03GoalTrainingAlignment => 'Align training with my cycle';

  @override
  String get onboarding03GoalNutrition => 'Optimize nutrition & discover new recipes';

  @override
  String get onboarding03GoalWeightManagement => 'Manage my weight (lose/maintain)';

  @override
  String get onboarding03GoalMindfulness => 'Reduce stress & boost mindfulness';

  @override
  String get onboarding04Title => 'When did your last period start?';

  @override
  String selectedDateLabel(String date) {
    return 'Selected date: $date';
  }

  @override
  String get onboarding04CalloutSemantics => 'Note: Don\'t worry if you don\'t remember the exact day. A rough estimate is enough to get started.';

  @override
  String get onboarding04CalloutPrefix => 'Don\'t worry if you don\'t remember the ';

  @override
  String get onboarding04CalloutHighlight => 'exact day';

  @override
  String get onboarding04CalloutSuffix => '. A rough estimate is enough to get started.';

  @override
  String get commonContinue => 'Continue';

  @override
  String dashboardGreeting(String name) {
    return 'Hey, $name 💜';
  }

  @override
  String get notificationsWithBadge => 'Notifications, new alerts available';

  @override
  String get notificationsNoBadge => 'Notifications';

  @override
  String get dashboardCategoriesTitle => 'Categories';

  @override
  String get dashboardTopRecommendationTitle => 'Your Top Recommendation';

  @override
  String get dashboardMoreTrainingsTitle => 'More Trainings';

  @override
  String get dashboardTrainingDataTitle => 'Your Training Data';

  @override
  String get dashboardTrainingWeekTitle => 'Your Training for This Week';

  @override
  String get dashboardTrainingWeekSubtitle => 'Created by your LUVI experts';

  @override
  String get dashboardRecommendationsTitle => 'More Recommendations\nfor Your Phase';

  @override
  String get dashboardNutritionTitle => 'Nutrition & Diet';

  @override
  String get dashboardRegenerationTitle => 'Recovery & Mindfulness';

  @override
  String get dashboardNavToday => 'Today';

  @override
  String get dashboardNavCycle => 'Cycle';

  @override
  String get dashboardNavPulse => 'Heart rate';

  @override
  String get dashboardNavProfile => 'Profile';

  @override
  String get dashboardNavSync => 'Sync';

  @override
  String get dashboardCategoryTraining => 'Training';

  @override
  String get dashboardCategoryNutrition => 'Nutrition';

  @override
  String get dashboardCategoryRegeneration => 'Recovery';

  @override
  String get dashboardCategoryMindfulness => 'Mindfulness';

  @override
  String get dashboardViewAll => 'View all';

  @override
  String get dashboardViewMore => 'View more';

  @override
  String get trainingCompleted => 'Completed';

  @override
  String get nutritionRecommendation => 'Nutrition recommendation';

  @override
  String get regenerationRecommendation => 'Recovery recommendation';

  @override
  String get dashboardLuviSyncTitle => 'Luvi Sync Journal';

  @override
  String get dashboardLuviSyncPlaceholder => 'Luvi Sync Journal content coming soon.';

  @override
  String get workoutTitle => 'Workout';

  @override
  String get dashboardWearableConnectMessage => 'Connect your wearable to display your training data.';

  @override
  String get dashboardHeroCtaMore => 'More';

  @override
  String get dashboardRecommendationsEmpty => 'No recommendations for this phase yet.';

  @override
  String get topRecommendation => 'Top recommendation';

  @override
  String get category => 'Category';

  @override
  String get fromLuviSync => 'From LUVI Sync';

  @override
  String get tapToOpenWorkout => 'Tap to open workout.';

  @override
  String get cycleInlineCalendarHint => 'Switch to the cycle overview.';

  @override
  String cycleInlineCalendarLabelToday(String date, String phase) {
    return 'Cycle calendar. Today $date phase: $phase. For orientation only - not a medical prediction or diagnostic tool.';
  }

  @override
  String get cycleInlineCalendarLabelDefault => 'Cycle calendar. Switch to the cycle overview. For orientation only - not a medical prediction or diagnostic tool.';

  @override
  String get cyclePhaseMenstruation => 'Menstruation';

  @override
  String get cyclePhaseFollicular => 'Follicular phase';

  @override
  String get cyclePhaseOvulation => 'Ovulation window';

  @override
  String get cyclePhaseLuteal => 'Luteal phase';

  @override
  String get cycleLengthShort => 'Short (every 21-23 days)';

  @override
  String get cycleLengthLonger => 'A bit longer (every 24-26 days)';

  @override
  String get cycleLengthStandard => 'Standard (every 27-30 days)';

  @override
  String get cycleLengthLong => 'Longer (every 31-35 days)';

  @override
  String get cycleLengthVeryLong => 'Very long (36+ days)';

  @override
  String get onboarding06Title => 'Tell me about yourself 💜';

  @override
  String get onboarding06Question => 'How long does your cycle normally last?';

  @override
  String get onboarding06OptionsSemantic => 'Select cycle length';

  @override
  String get onboarding06Callout => 'Every cycle is unique - just like you!';

  @override
  String get onboarding05Title => 'How long does your\nperiod usually last?';

  @override
  String get onboarding05OptionsSemantic => 'Select period duration';

  @override
  String get onboarding05OptUnder3 => 'Less than 3 days';

  @override
  String get onboarding05Opt3to5 => 'Between 3 and 5 days';

  @override
  String get onboarding05Opt5to7 => 'Between 5 and 7 days';

  @override
  String get onboarding05OptOver7 => 'More than 7 days';

  @override
  String get onboarding05Callout => 'We need this starting point to calculate your current cycle phase. I learn with you and automatically adjust the predictions as soon as you log your next period.';

  @override
  String get onboarding07Title => 'What is your cycle like?';

  @override
  String get onboarding07OptionsSemantic => 'Select cycle regularity';

  @override
  String get onboarding07OptRegular => 'Pretty regular';

  @override
  String get onboarding07OptUnpredictable => 'Mostly unpredictable';

  @override
  String get onboarding07OptUnknown => 'Not sure';

  @override
  String get onboarding07Footnote => 'Clockwork or chaos - I get both!';

  @override
  String get onboardingComplete => 'Onboarding complete';

  @override
  String get cycleTipHeadlineMenstruation => 'Menstruation';

  @override
  String get cycleTipBodyMenstruation => 'Gentle movement, stretching, or a walk are ideal today — everything is allowed, nothing is mandatory.';

  @override
  String get cycleTipHeadlineFollicular => 'Follicular phase';

  @override
  String get cycleTipBodyFollicular => 'You\'re in the follicular phase today. With higher progesterone you may feel more energy. A great time for more intensive training.';

  @override
  String get cycleTipHeadlineOvulation => 'Ovulation window';

  @override
  String get cycleTipBodyOvulation => 'Short, crisp sessions often work best now. Plan a conscious cool down and hydration afterwards.';

  @override
  String get cycleTipHeadlineLuteal => 'Luteal phase';

  @override
  String get cycleTipBodyLuteal => 'Switch to calm strength or mobility work. Extra breaks help you maintain your energy level.';
}
