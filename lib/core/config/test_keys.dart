/// Centralized test keys for widget testing.
///
/// Keys are organized by feature area. Use these constants in widgets
/// via `Key(TestKeys.keyName)` or `ValueKey(TestKeys.keyName)` to ensure
/// consistency between production code and tests.
///
/// Dashboard keys are intentionally excluded from this file (separate scope).
abstract final class TestKeys {
  TestKeys._();

  // ─── Auth ───

  /// SignIn entry screen (glassmorphism card)
  static const authSigninScreen = 'auth_signin_screen';

  /// Login screen with email/password form
  static const authLoginScreen = 'auth_login_screen';

  /// Signup screen
  static const authSignupScreen = 'auth_signup_screen';

  /// Reset password screen
  static const authResetScreen = 'auth_reset_screen';

  /// Create new password screen
  static const authCreatePasswordScreen = 'auth_create_password_screen';

  /// Success screen (post-password-reset)
  static const authSuccessScreen = 'auth_success_screen';

  /// Auth entry hero image/video
  static const authEntryHero = 'auth_entry_hero';

  /// Auth entry CTA button
  static const authEntryCta = 'auth_entry_cta';

  /// Teal dot accent on auth entry
  static const authTealDot = 'tealDot';

  /// Login email input field
  static const loginEmailField = 'login_email_field';

  /// Login password input field
  static const loginPasswordField = 'login_password_field';

  /// Login CTA button
  static const loginCtaButton = 'login_cta_button';

  /// Login CTA loading indicator
  static const loginCtaLoading = 'login_cta_loading';

  /// Login CTA loading semantics wrapper
  static const loginCtaLoadingSemantics = 'login_cta_loading_semantics';

  /// Login CTA label text
  static const loginCtaLabel = 'login_cta_label';

  /// Login "forgot password" link
  static const loginForgotLink = 'login_forgot_link';

  /// Login "forgot password" button
  static const loginForgotButton = 'login_forgot_button';

  /// Login "sign up" link
  static const loginSignupLink = 'login_signup_link';

  /// Signup email input field
  static const signupEmailField = 'signup_email_field';

  /// Signup password input field
  static const signupPasswordField = 'signup_password_field';

  /// Signup password confirmation field
  static const signupPasswordConfirmField = 'signup_password_confirm_field';

  /// Signup CTA button
  static const signupCtaButton = 'signup_cta_button';

  /// Signup CTA loading indicator
  static const signupCtaLoading = 'signup_cta_loading';

  /// Reset email input field
  static const resetEmailField = 'reset_email_field';

  /// Reset CTA button
  static const resetCta = 'reset_cta';

  /// Create new password title
  static const createNewTitle = 'create_new_title';

  /// Create new password subtitle
  static const createNewSubtitle = 'create_new_subtitle';

  /// Create new password CTA button
  static const createNewCtaButton = 'create_new_cta_button';

  /// Auth password input field
  static const authPasswordField = 'AuthPasswordField';

  /// Auth confirm password input field
  static const authConfirmPasswordField = 'AuthConfirmPasswordField';

  /// Verify confirm button
  static const verifyConfirmButton = 'verify_confirm_button';

  /// Back button circle (auth shell)
  static const backButtonCircle = 'backButtonCircle';

  // ─── Welcome ───

  /// Welcome page indicators row
  static const welcomePageIndicators = 'welcome_page_indicators';

  /// Welcome hero frame container
  static const welcomeHeroFrame = 'welcome_hero_frame';

  /// Welcome headline block
  static const welcomeHeadlineBlock = 'welcome_headline_block';

  /// Welcome CTA button
  static const welcomeCtaButton = 'welcome_cta_button';

  /// Welcome video loading placeholder
  static const welcomeVideoLoading = 'welcome_video_loading';

  // ─── Onboarding ───

  /// Generic onboarding CTA button
  static const onbCta = 'onb_cta';

  /// Circular progress ring container
  static const circularProgressRingContainer = 'circular_progress_ring_container';

  // ─── Consent ───

  /// Consent health checkbox
  static const consentOptionsHealth = 'consent_options_health';

  /// Consent terms checkbox
  static const consentOptionsTerms = 'consent_options_terms';

  /// Consent analytics checkbox
  static const consentOptionsAnalytics = 'consent_options_analytics';

  /// Consent button gap
  static const consentOptionsButtonGap = 'consent_options_button_gap';

  /// Consent continue button
  static const consentBtnContinue = 'consent_options_btn_continue';

  /// Consent accept all button
  static const consentBtnAcceptAll = 'consent_options_btn_accept_all';

  // ─── Cycle ───

  /// Phase text display
  static const phaseText = 'phase-text';

  /// Cycle inline calendar semantics wrapper
  static const cycleInlineCalendarSemantics = 'cycle_inline_calendar_semantics';

  // ─── Splash ───

  /// Splash video loading placeholder
  static const splashVideoLoading = 'splash_video_loading';
}
