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
  String get commonSkip => 'Skip';

  @override
  String get commonStartNow => 'Start now';

  @override
  String dashboardGreeting(String name) {
    return 'Hey, $name 💜';
  }

  @override
  String get notificationsWithBadge => 'Notifications, new alerts available';

  @override
  String notificationsWithBadgeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications, $count new',
      one: 'Notifications, $count new',
    );
    return '$_temp0';
  }

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
  String get dashboardTrainingWeekTitle => 'Your training for this week';

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
  String get trainingsOverviewStubPlaceholder => 'Training overview coming soon';

  @override
  String get trainingsOverviewStubSemantics => 'Training overview is in progress. Use the back button to return to the previous view.';

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

  @override
  String get onboarding08Title => 'How fit do you feel?';

  @override
  String get onboarding08OptionsSemantic => 'Select fitness level';

  @override
  String get onboarding08OptBeginner => 'I\'m just getting started';

  @override
  String get onboarding08OptOccasional => 'I train occasionally';

  @override
  String get onboarding08OptFit => 'I feel pretty fit';

  @override
  String get onboarding08OptUnknown => 'I don\'t know';

  @override
  String get onboarding08Footnote => 'No stress - we\'ll find your perfect starting point!';

  @override
  String get onboardingSuccessTitle => 'You\'re ready to go!';

  @override
  String get welcome01Subtitle => 'Transform your cycle into your strength. Training, nutrition, biohacking — everything perfectly tailored to your hormones.';

  @override
  String get welcome01TitlePrefix => 'In ';

  @override
  String get welcome01TitleAccent => 'harmony';

  @override
  String get welcome01TitleSuffixLine1 => ' with your\n';

  @override
  String get welcome01TitleSuffixLine2 => 'body';

  @override
  String get welcome01PrimaryCta => 'Continue';

  @override
  String get welcome02TitleLine1 => 'Curated by experts for you\n';

  @override
  String get welcome02TitleLine2 => 'refreshed every month';

  @override
  String get welcome02Subtitle => 'Real personalization instead of standard plans. Automatically adapted to your progress, cycle phase, and individual goals.';

  @override
  String get welcome03TitleLine1 => 'Your perfect day\n';

  @override
  String get welcome03TitleLine2 => 'starts here';

  @override
  String get welcome03Subtitle => 'LUVI Sync: Your daily game-changer. Understand the \"why\" behind your hormones. Scientifically grounded.';

  @override
  String get consent02Title => 'Your health,\nyour decision!';

  @override
  String get consent02CardHealth => 'I agree that LUVI processes my personal health data so LUVI can deliver its features.';

  @override
  String get consent02CardTermsPrefix => 'I agree to the ';

  @override
  String get consent02LinkPrivacyLabel => 'Privacy Policy';

  @override
  String get consent02LinkConjunction => ' as well as the ';

  @override
  String get consent02LinkTermsLabel => 'Terms of Service';

  @override
  String get consent02LinkSuffix => '.';

  @override
  String get consent02CardAiJournal => 'I agree that LUVI uses artificial intelligence to summarize my training, nutrition, and recovery recommendations in a personalized journal.';

  @override
  String get consent02CardAnalytics => 'I agree that pseudonymized usage and device data are processed for analytics so LUVI can improve stability and usability.*';

  @override
  String get consent02CardMarketing => 'I agree that LUVI processes my personal data and usage data to send me personalized recommendations for relevant LUVI content as well as offers via in-app notices, email, and/or push notifications.*';

  @override
  String get consent02CardModelTraining => 'I consent to pseudonymized usage and health data being used for quality assurance and to improve recommendations (e.g., verifying cycle prediction accuracy).*';

  @override
  String get consent02LinkError => 'Link could not be opened';

  @override
  String get consent02RevokeHint => 'You can withdraw your consent at any time in the app or by emailing hello@getluvi.com.';

  @override
  String get consent02AcceptAll => 'Accept all';

  @override
  String get consent02DeselectAll => 'Deselect all';

  @override
  String get consent02SemanticSelected => 'Selected';

  @override
  String get consent02SemanticUnselected => 'Not selected';

  @override
  String get authLoginHeadline => 'Welcome back 💜';

  @override
  String get authLoginSubhead => 'We\'re glad you\'re here.';

  @override
  String get authLoginCta => 'Sign in';

  @override
  String get authLoginCtaLoadingSemantic => 'Signing in';

  @override
  String get authLoginCtaLinkPrefix => 'New to LUVI? ';

  @override
  String get authLoginCtaLinkAction => 'Start here';

  @override
  String get authLoginForgot => 'Forgot password?';

  @override
  String get authLoginSocialDivider => 'Or continue with';

  @override
  String get authErrEmailInvalid => 'Please double-check your email.';

  @override
  String get authErrPasswordInvalid => 'Please double-check your password.';

  @override
  String get authErrConfirmEmail => 'Please verify your email (resend the link?).';

  @override
  String get authInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get authErrLoginUnavailable => 'Login is currently unavailable.';

  @override
  String get authEmailHint => 'Your email';

  @override
  String get authPasswordHint => 'Your password';

  @override
  String get authSignupTitle => 'Your journey starts here 💜';

  @override
  String get authSignupSubtitle => 'Quick signup and you\'re ready to go.';

  @override
  String get authSignupCta => 'Sign up';

  @override
  String get authSignupCtaLoadingSemantic => 'Signing up';

  @override
  String get authSignupLinkPrefix => 'Already have an account? ';

  @override
  String get authSignupLinkAction => 'Sign in';

  @override
  String get authSignupHintFirstName => 'Your first name';

  @override
  String get authSignupHintLastName => 'Your last name';

  @override
  String get authSignupHintPhone => 'Your phone number';

  @override
  String get authSignupMissingFields => 'Please enter your email and password.';

  @override
  String get authSignupGenericError => 'Sign up is unavailable right now. Please try again later.';

  @override
  String get authForgotTitle => 'Forgot your password? 💜';

  @override
  String get authForgotSubtitle => 'Enter your email to receive the reset link.';

  @override
  String get authForgotCta => 'Continue';

  @override
  String get authBackSemantic => 'Back';

  @override
  String get authSuccessPwdTitle => 'All done!';

  @override
  String get authSuccessPwdSubtitle => 'Your new password has been saved.';

  @override
  String get authSuccessForgotTitle => 'Email sent!';

  @override
  String get authSuccessForgotSubtitle => 'Please check your inbox.';

  @override
  String get authSuccessCta => 'Done';

  @override
  String get authCreateNewHint1 => 'New password';

  @override
  String get authCreateNewHint2 => 'Confirm new password';

  @override
  String get authCreateNewCta => 'Save';

  @override
  String get authVerifyResetTitle => 'Enter the code 💜';

  @override
  String get authVerifyResetSubtitle => 'We just sent it to your email.';

  @override
  String get authVerifyEmailTitle => 'Confirm your email 💜';

  @override
  String get authVerifyEmailSubtitle => 'Enter the code';

  @override
  String get authVerifyCta => 'Confirm';

  @override
  String get authVerifyHelper => 'Didn\'t receive anything?';

  @override
  String get authVerifyResend => 'Resend';
}
