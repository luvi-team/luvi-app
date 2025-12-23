// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboarding01Title => 'Welcome!\nWhat should we call you?';

  @override
  String onboardingStepSemantic(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboarding01Instruction => 'What should I call you?';

  @override
  String get onboarding01NameInputSemantic => 'Enter your name';

  @override
  String get onboarding01NameHint => 'Your first name';

  @override
  String onboarding02Title(String name) {
    return 'Hey $name,\nwhen is your birthday?';
  }

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
  String get initBannerConfigError => 'Configuration error: Supabase credentials invalid. App is running offline.';

  @override
  String initBannerConnecting(int attempts, int maxAttempts) {
    return 'Connecting to server… (attempt $attempts/$maxAttempts)';
  }

  @override
  String get initBannerRetry => 'Retry';

  @override
  String get documentLoadError => 'Failed to load document.';

  @override
  String get legalViewerLoadingLabel => 'Loading document';

  @override
  String get legalViewerFallbackBanner => 'Remote unavailable — showing offline copy.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStartNow => 'Start now';

  @override
  String get commonToday => 'TODAY';

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
  String get onboarding07Title => 'How regular is your cycle?';

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
  String get errorInvalidWorkoutId => 'Invalid workout ID';

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
  String get onboardingSuccessStateUnavailable => 'We couldn\'t complete onboarding. Please try again.';

  @override
  String get onboardingSuccessGenericError => 'Something went wrong. Please try again.';

  @override
  String get welcome01Title => 'Your body. Your rhythm. Every day.';

  @override
  String get welcome01Subtitle => 'Your daily companion for training, nutrition, sleep & more.';

  @override
  String get welcome02Title => 'Know what matters today in seconds.';

  @override
  String get welcome02Subtitle => 'No searching, no guessing. LUVI shows you the next step.';

  @override
  String get welcome03Title => 'Adapts to your cycle.';

  @override
  String get welcome03Subtitle => 'So you work with your body, not against it.';

  @override
  String get welcome04Title => 'Created by experts.';

  @override
  String get welcome04Subtitle => 'No algorithm, but real people.';

  @override
  String get welcome05Title => 'Small steps today. Big impact tomorrow.';

  @override
  String get welcome05Subtitle => 'For now – and your future self.';

  @override
  String get welcome05PrimaryCta => 'Start now';

  @override
  String get consent01IntroTitle => 'Let\'s tailor LUVI\nto you';

  @override
  String get consent01IntroBody => 'You decide what to share. The more we know about you, the better we can support you.';

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
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

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
  String get authLoginTitle => 'Sign in with Email';

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
  String get authLoginSocialGoogle => 'Sign in with Google';

  @override
  String get authErrEmailInvalid => 'Please double-check your email.';

  @override
  String get authErrPasswordInvalid => 'Please double-check your password.';

  @override
  String get authErrPasswordTooShort => 'Your password is too short.';

  @override
  String get authErrPasswordMissingTypes => 'Your password must include letters, numbers, and special characters.';

  @override
  String get authErrPasswordCommonWeak => 'Your password is too common or weak.';

  @override
  String get authErrEmailEmpty => 'Please enter your email.';

  @override
  String get authErrPasswordEmpty => 'Please enter your password.';

  @override
  String get authErrConfirmEmail => 'Please verify your email (resend the link?).';

  @override
  String get authInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get authErrLoginUnavailable => 'Login is currently unavailable.';

  @override
  String get authPasswordMismatchError => 'Passwords do not match.';

  @override
  String get authPasswordUpdateError => 'We couldn\'t update your password.';

  @override
  String authErrWaitBeforeRetry(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '# seconds',
      one: '# second',
    );
    return 'Please wait $_temp0 before retrying.';
  }

  @override
  String get authEmailHint => 'Your email';

  @override
  String get authPasswordHint => 'Your password';

  @override
  String get authSignupTitle => 'Create account';

  @override
  String get authSignupSubtitle => 'Quick signup and you\'re ready to go.';

  @override
  String get authSignupAlreadyMember => 'Already a member? ';

  @override
  String get authSignupLoginLink => 'Sign in';

  @override
  String get authSignupCta => 'Sign up';

  @override
  String get authSignupCtaLoadingSemantic => 'Signing up';

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
  String get authCreateNewSubtitle => 'Make it strong.';

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

  @override
  String get consentSnackbarAccepted => 'Consent accepted';

  @override
  String get consentSnackbarError => 'We couldn\'t save your consent. Please try again.';

  @override
  String get consentErrorSavingConsent => 'We couldn\'t save all your preferences. You can continue and try again later.';

  @override
  String get consentSnackbarRateLimited => 'Too many requests right now. Please wait a moment and try again.';

  @override
  String get consentSnackbarServiceUnavailable => 'The service is temporarily unavailable. Please try again later.';

  @override
  String get consentSnackbarServerError => 'A server error occurred. Please try again later.';

  @override
  String get authSignInHeadline => 'Don\'t miss out on becoming your best self!';

  @override
  String get authSignInEmail => 'Sign in with Email';

  @override
  String get authSignInGoogle => 'Sign in with Google';

  @override
  String get authSignInApple => 'Sign in with Apple';

  @override
  String get authSignInLoading => 'Signing in';

  @override
  String get authSignInOAuthError => 'Sign in failed. Please try again.';

  @override
  String get authSignInAppleError => 'Apple sign in failed. Please try again.';

  @override
  String get authSignInGoogleError => 'Google sign in failed. Please try again.';

  @override
  String get authResetTitle => 'Forgot password?';

  @override
  String get authResetSubtitle => 'Enter your email and we\'ll send you a link to reset it.';

  @override
  String get authResetCta => 'Reset password';

  @override
  String get authResetEmailSent => 'Password reset email sent.';

  @override
  String get authNewPasswordTitle => 'Create new password';

  @override
  String get authNewPasswordHint => 'New password';

  @override
  String get authConfirmPasswordHint => 'Confirm new password';

  @override
  String get authCreatePasswordCta => 'Reset password';

  @override
  String get authSuccessBackToLogin => 'Back to sign in';

  @override
  String get authSignupSuccess => 'Registration successful! You can now sign in.';

  @override
  String get interestStrengthTraining => 'Strength training & muscle building';

  @override
  String get interestCardio => 'Cardio & endurance';

  @override
  String get interestMobility => 'Flexibility & mobility';

  @override
  String get interestNutrition => 'Nutrition & supplements';

  @override
  String get interestMindfulness => 'Mindfulness & recovery';

  @override
  String get interestHormonesCycle => 'Hormones & cycle';

  @override
  String onboarding02AgeTooYoung(int minAge) {
    return 'You must be at least $minAge years old.';
  }

  @override
  String onboarding02AgeTooOld(int maxAge) {
    return 'Maximum age is $maxAge years.';
  }

  @override
  String get fitnessLevelBeginner => 'Not fit';

  @override
  String get fitnessLevelOccasional => 'Fit';

  @override
  String get fitnessLevelFit => 'Very fit';

  @override
  String get consentIntroTitle => 'Let\'s personalize LUVI for you';

  @override
  String get consentIntroBody => 'To personalize LUVI for you, we first need your okay.';

  @override
  String get consentIntroCtaLabel => 'Continue';

  @override
  String get consentIntroIllustrationSemantic => 'Illustration: Hand holding a pen to sign';

  @override
  String get consentIntroCtaSemantic => 'Continue to privacy consent';

  @override
  String get consentOptionsTitle => 'Your Privacy Choices';

  @override
  String get consentOptionsSubtitle => 'Securely stored, strictly protected. GDPR, EU hosting';

  @override
  String get consentOptionsSectionRequired => 'REQUIRED';

  @override
  String get consentOptionsSectionOptional => 'OPTIONAL';

  @override
  String get consentOptionsHealthText => 'I agree that LUVI processes my health and cycle data to give me cycle-aware recommendations.';

  @override
  String get consentOptionsTermsPrefix => 'I accept the ';

  @override
  String get consentOptionsTermsLink => 'Terms of Service';

  @override
  String get consentOptionsTermsConjunction => ' and the ';

  @override
  String get consentOptionsPrivacyLink => 'Privacy Policy';

  @override
  String get consentOptionsTermsSuffix => '.';

  @override
  String get consentOptionsAnalyticsText => 'I agree that LUVI processes pseudonymized usage and device data (e.g. crash info, performance, features used) to fix bugs and improve the app.';

  @override
  String get consentOptionsAnalyticsRevoke => 'Revoke anytime under Profile → Privacy.';

  @override
  String get consentOptionsCtaContinue => 'Continue';

  @override
  String get consentOptionsCtaAcceptAll => 'Accept all';

  @override
  String consentOptionsCheckboxSelectedSemantic(String section, String text) {
    return '$section: $text. Selected';
  }

  @override
  String consentOptionsCheckboxUnselectedSemantic(String section, String text) {
    return '$section: $text. Not selected';
  }

  @override
  String get consentOptionsShieldSemantic => 'Shield icon for data protection';

  @override
  String get consentBlockingTitle => 'Your consent makes LUVI possible';

  @override
  String get consentBlockingBody => 'LUVI needs your cycle and health data to show you cycle-based content and recommendations. Without this processing, we cannot provide the service.';

  @override
  String get consentBlockingCtaBack => 'Back & Agree';

  @override
  String get consentBlockingCtaSemantic => 'Back to consent';

  @override
  String get consentBlockingShieldSemantic => 'Shield icon for data protection';

  @override
  String onboarding03FitnessTitle(String name) {
    return '$name, how fit do you feel?';
  }

  @override
  String get onboarding03FitnessSubtitle => 'So we can choose the right intensity for you.';

  @override
  String get onboarding03FitnessSemantic => 'Select fitness level';

  @override
  String get onboarding04GoalsTitle => 'What are your goals?';

  @override
  String get onboarding04GoalsSubtitle => 'You can select multiple.';

  @override
  String get onboarding04GoalsSemantic => 'Select goals';

  @override
  String get onboarding05InterestsTitle => 'What interests you?';

  @override
  String get onboarding05InterestsSubtitle => 'Choose 3–5 so your feed fits right away.';

  @override
  String get onboarding05InterestsSemantic => 'Select interests';

  @override
  String get onboarding06PeriodTitle => 'Tap the day your last period started.';

  @override
  String get onboarding06PeriodUnknown => 'I don\'t remember';

  @override
  String get onboarding06PeriodSubheader => 'You can change this later.';

  @override
  String get onboarding07DurationTitle => 'Does this look right?';

  @override
  String get onboarding07DurationSubtitle => 'We\'ve estimated the duration. Tap a day to adjust.';

  @override
  String get onboarding08SuccessLoading => 'We\'re putting your results together...';

  @override
  String onboardingProgressLabel(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get onboardingDefaultName => 'you';

  @override
  String get weekdayMondayShort => 'Mo';

  @override
  String get weekdayTuesdayShort => 'Tu';

  @override
  String get weekdayWednesdayShort => 'We';

  @override
  String get weekdayThursdayShort => 'Th';

  @override
  String get weekdayFridayShort => 'Fr';

  @override
  String get weekdaySaturdayShort => 'Sa';

  @override
  String get weekdaySundayShort => 'Su';

  @override
  String get periodCalendarSemanticToday => 'Today';

  @override
  String get periodCalendarSemanticSelected => 'selected';

  @override
  String get periodCalendarSemanticPeriodDay => 'period day';

  @override
  String get onboardingCycleIntroTitle => 'To personalize LUVI for you, we need your cycle start.';

  @override
  String get onboardingCycleIntroButton => 'Okay, let\'s go';

  @override
  String get onboardingSuccessLoading => 'We\'re putting together your plans...';

  @override
  String get onboardingSuccessSaving => 'Saving...';

  @override
  String get onboardingSuccessComplete => 'Done!';

  @override
  String get onboardingSaveError => 'Save failed. Please try again.';

  @override
  String get onboardingRetryButton => 'Try again';

  @override
  String get onboardingContentCard1 => 'Do I need more iron during my period?';

  @override
  String get onboardingContentCard2 => 'How do I train during ovulation?';

  @override
  String get onboardingContentCard3 => 'How can I reduce my stress?';

  @override
  String get goalFitter => 'Get fitter & stronger';

  @override
  String get goalEnergy => 'More energy in daily life';

  @override
  String get goalSleep => 'Better sleep and stress reduction';

  @override
  String get goalCycle => 'Understand cycle & hormones';

  @override
  String get goalLongevity => 'Long-term health and longevity';

  @override
  String get goalWellbeing => 'Simply feel good';

  @override
  String get commonBack => 'Back';

  @override
  String get semanticCalendarPreview => 'Calendar preview for cycle tracking';

  @override
  String get semanticLoadingProgress => 'Loading progress';

  @override
  String semanticProgressPercent(int percent) {
    return '$percent percent';
  }

  @override
  String get splashGateUnknownTitle => 'Brief interruption';

  @override
  String get splashGateUnknownBody => 'To continue, we need an internet connection. Please check your connection.';

  @override
  String get splashGateRetryCta => 'Try again';

  @override
  String get splashGateSignOutCta => 'Sign out';

  @override
  String get signOutErrorRetry => 'Sign out failed. Please try again.';

  @override
  String get signOutFailed => 'Sign out failed. You can log in again.';

  @override
  String get retry => 'Retry';
}
