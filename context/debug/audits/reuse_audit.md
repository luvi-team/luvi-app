# Reuse Audit (Welcome/Auth)

## Widgets – Kandidaten
````
lib/core/theme/app_theme.dart:12:); // Primary color/100 (Button bg)
lib/core/theme/app_theme.dart:39:// Button Label (bold)
lib/core/theme/app_theme.dart:66:// Button global stylen wie Figma
lib/core/theme/app_theme.dart:67:elevatedButtonTheme: _buildElevatedButtonTheme(),
lib/core/theme/app_theme.dart:68:textButtonTheme: _buildTextButtonTheme(),
lib/core/theme/app_theme.dart:87:static ElevatedButtonThemeData _buildElevatedButtonTheme() {
lib/core/theme/app_theme.dart:88:return ElevatedButtonThemeData(
lib/core/theme/app_theme.dart:89:style: ElevatedButton.styleFrom(
lib/core/theme/app_theme.dart:111:static TextButtonThemeData _buildTextButtonTheme() {
lib/core/theme/app_theme.dart:112:return TextButtonThemeData(
lib/core/theme/app_theme.dart:113:style: TextButton.styleFrom(
lib/core/strings/auth_strings.dart:5:static const loginCtaButton = loginCta;
lib/core/strings/auth_strings.dart:20:static const signupSubtitle = 'Schnell registrieren - dann geht\'s los.';
lib/core/strings/auth_strings.dart:28:static const forgotSubtitle = 'E-Mail eingeben für Link.';
lib/core/strings/auth_strings.dart:32:static const successPwdSubtitle = 'Neues Passwort gespeichert.';
lib/core/strings/auth_strings.dart:34:static const successForgotSubtitle = 'Bitte Postfach prüfen.';
lib/core/strings/auth_strings.dart:40:static const verifyResetSubtitle = 'Gerade an deine E-Mail gesendet.';
lib/core/strings/auth_strings.dart:42:static const verifyEmailSubtitle = 'Code eingeben';
lib/features/widgets/README.md:1:BackButtonCircle uses AuthStrings.backSemantic for semantics. Consumers must import AuthStrings.
lib/features/widgets/back_button.dart:5:class BackButtonCircle extends StatelessWidget {
lib/features/widgets/back_button.dart:6:const BackButtonCircle({
lib/core/design_tokens/typography.dart:15:// Button label: 20 / 24 (bold weight)
lib/core/design_tokens/sizes.dart:5:static const double buttonHeight = 50.0; // Figma: Button H=50
lib/core/design_tokens/sizes.dart:7:/// Figma: 40 px Kreisradius (z. B. Social-Button)
lib/features/consent/widgets/welcome_shell.dart:53:// Text + CTAs auf der Wave
lib/features/consent/widgets/welcome_shell.dart:75:// Dots (über dem Button), now reusable
lib/features/consent/widgets/welcome_shell.dart:81:ElevatedButton(
lib/features/consent/widgets/welcome_shell.dart:86:TextButton(
lib/core/design_tokens/spacing.dart:3:static const double m = 16.0; // medium (e.g., between CTAs)
lib/features/consent/widgets/consent_button.dart:4:class ConsentButton extends StatefulWidget {
lib/features/consent/widgets/consent_button.dart:5:const ConsentButton({super.key});
lib/features/consent/widgets/consent_button.dart:8:State<ConsentButton> createState() => _ConsentButtonState();
lib/features/consent/widgets/consent_button.dart:11:class _ConsentButtonState extends State<ConsentButton> {
lib/features/consent/widgets/consent_button.dart:48:return ElevatedButton(
lib/features/consent/screens/consent_02_screen.dart:196:child: BackButtonCircle(
lib/features/consent/screens/consent_02_screen.dart:267:// BOTTOM zone: sticky CTA
lib/features/consent/screens/consent_02_screen.dart:291:child: ElevatedButton(
lib/features/consent/screens/consent_02_screen.dart:302:child: ElevatedButton(
lib/features/auth/widgets/social_auth_row.dart:12:this.dividerToButtonsGap = Spacing.l + Spacing.xs,
lib/features/auth/widgets/social_auth_row.dart:17:final double dividerToButtonsGap;
lib/features/auth/widgets/social_auth_row.dart:35:SizedBox(height: dividerToButtonsGap),
lib/features/auth/widgets/social_auth_row.dart:39:child: _SocialButton(
lib/features/auth/widgets/social_auth_row.dart:47:child: _SocialButton(
lib/features/auth/widgets/social_auth_row.dart:60:class _SocialButton extends StatelessWidget {
lib/features/auth/widgets/social_auth_row.dart:61:const _SocialButton({
lib/features/auth/widgets/social_auth_row.dart:79:child: OutlinedButton(
lib/features/auth/widgets/social_auth_row.dart:81:style: OutlinedButton.styleFrom(
lib/features/auth/widgets/verify_text_styles.dart:15:TextStyle? verifySubtitleStyle(BuildContext context) {
lib/features/auth/widgets/verify_header.dart:6:class VerifyHeader extends StatelessWidget {
lib/features/auth/widgets/verify_header.dart:7:const VerifyHeader({
lib/features/auth/widgets/verify_header.dart:15:required this.backButtonSize,
lib/features/auth/widgets/verify_header.dart:16:required this.backButtonInnerSize,
lib/features/auth/widgets/verify_header.dart:17:required this.backButtonBackgroundColor,
lib/features/auth/widgets/verify_header.dart:18:required this.backButtonIconColor,
lib/features/auth/widgets/verify_header.dart:27:final double backButtonSize;
lib/features/auth/widgets/verify_header.dart:28:final double backButtonInnerSize;
lib/features/auth/widgets/verify_header.dart:29:final Color backButtonBackgroundColor;
lib/features/auth/widgets/verify_header.dart:30:final Color backButtonIconColor;
lib/features/auth/widgets/verify_header.dart:39:BackButtonCircle(
lib/features/auth/widgets/verify_header.dart:41:size: backButtonSize,
lib/features/auth/widgets/verify_header.dart:42:innerSize: backButtonInnerSize,
lib/features/auth/widgets/verify_header.dart:43:backgroundColor: backButtonBackgroundColor,
lib/features/auth/widgets/verify_header.dart:44:iconColor: backButtonIconColor,
lib/features/auth/widgets/verify_header.dart:46:const SizedBox(height: AuthLayout.gapSection),
lib/features/auth/widgets/verify_header.dart:50:const SizedBox(height: AuthLayout.gapSection),
lib/features/consent/screens/consent_01_screen.dart:26:child: BackButtonCircle(
lib/features/consent/screens/consent_01_screen.dart:62:// CTA button (height 50, bottom 44, horizontal 20)
lib/features/consent/screens/consent_01_screen.dart:68:child: ElevatedButton(
lib/features/consent/screens/consent_01_screen.dart:131:// BackButtonCircle moved to lib/features/widgets/back_button.dart
lib/features/cycle/widgets/phase_badge.dart:4:class PhaseBadge extends StatelessWidget {
lib/features/cycle/widgets/phase_badge.dart:9:const PhaseBadge({
lib/features/auth/widgets/login_cta_section.dart:31:child: ElevatedButton(
lib/features/auth/widgets/login_cta_section.dart:36:child: _LoginButtonChild(isLoading: isLoading),
lib/features/auth/widgets/login_cta_section.dart:42:? AuthLayout.ctaLinkGapError
lib/features/auth/widgets/login_cta_section.dart:43:: AuthLayout.ctaLinkGapNormal,
lib/features/auth/widgets/login_cta_section.dart:46:child: TextButton(
lib/features/auth/widgets/login_cta_section.dart:49:style: TextButton.styleFrom(
lib/features/auth/widgets/login_cta_section.dart:86:class _LoginButtonChild extends StatelessWidget {
lib/features/auth/widgets/login_cta_section.dart:87:const _LoginButtonChild({required this.isLoading});
lib/features/auth/widgets/login_cta_section.dart:94:return const Text(AuthStrings.loginCtaButton,
lib/features/auth/widgets/login_header.dart:5:class LoginHeader extends StatelessWidget {
lib/features/auth/widgets/login_header.dart:6:const LoginHeader({super.key});
lib/features/auth/layout/auth_layout.dart:5:class AuthLayout {
lib/features/auth/layout/auth_layout.dart:6:AuthLayout._();
lib/features/auth/layout/auth_layout.dart:10:static const double backButtonTop = 59;
lib/features/auth/layout/auth_layout.dart:11:static const double backButtonTopInset = backButtonTop - figmaSafeTop;
lib/features/auth/layout/auth_layout.dart:12:static const double backButtonToTitle = 105;
lib/features/auth/layout/auth_layout.dart:21:static const double ctaTopAfterCopy = 32; // Subtitle -> CTA spacing (Figma)
lib/features/auth/layout/auth_layout.dart:26:static const double figmaHeaderTop = 112; // Verification header top (Figma)
lib/features/auth/layout/auth_layout.dart:38:static const double backButtonSize = 40;
lib/features/auth/widgets/auth_screen_shell.dart:22:? AuthLayout.ctaBottomInset + safeBottom
lib/features/auth/widgets/auth_screen_shell.dart:25:AuthLayout.horizontalPadding,
lib/features/auth/widgets/auth_screen_shell.dart:27:AuthLayout.horizontalPadding,
lib/features/auth/widgets/verify_footer.dart:34:child: ElevatedButton(
lib/features/auth/widgets/verify_footer.dart:40:const SizedBox(height: AuthLayout.gapSection),
lib/features/auth/widgets/verify_footer.dart:45:TextButton(
lib/features/auth/widgets/verify_footer.dart:47:style: TextButton.styleFrom(
lib/features/auth/widgets/login_header_section.dart:8:class LoginHeaderSection extends StatelessWidget {
lib/features/auth/widgets/login_header_section.dart:9:const LoginHeaderSection({
lib/features/auth/widgets/login_header_section.dart:42:const LoginHeader(),
lib/features/auth/widgets/login_header_section.dart:62:LoginForgotButton(onPressed: onForgotPassword),
lib/features/auth/widgets/login_forgot_button.dart:6:class LoginForgotButton extends StatelessWidget {
lib/features/auth/widgets/login_forgot_button.dart:7:const LoginForgotButton({super.key, required this.onPressed});
lib/features/auth/widgets/login_forgot_button.dart:17:child: TextButton(
lib/features/auth/widgets/login_forgot_button.dart:20:style: TextButton.styleFrom(
lib/features/auth/widgets/login_password_field.dart:84:child: IconButton(
lib/features/auth/widgets/auth_bottom_cta.dart:5:/// Shared bottom CTA wrapper that handles keyboard insets, SafeArea, and
lib/features/auth/widgets/auth_bottom_cta.dart:11:this.topPadding = AuthLayout.ctaTopAfterCopy,
lib/features/auth/widgets/auth_bottom_cta.dart:12:this.horizontalPadding = AuthLayout.horizontalPadding,
lib/features/auth/widgets/verification_code_input.dart:16:this.fieldSize = AuthLayout.otpFieldSize,
lib/features/auth/widgets/verification_code_input.dart:17:this.gap = AuthLayout.otpGap,
lib/features/auth/widgets/verification_code_input.dart:90:borderRadius: BorderRadius.circular(AuthLayout.otpBorderRadius),
lib/features/auth/widgets/verification_code_input.dart:94:borderRadius: BorderRadius.circular(AuthLayout.otpBorderRadius),
lib/features/auth/widgets/verification_code_input.dart:98:borderRadius: BorderRadius.circular(AuthLayout.otpBorderRadius),
lib/features/auth/widgets/login_form_section.dart:27:dividerToButtonsGap: socialGap,
lib/features/auth/widgets/create_new/create_new_form.dart:59:const SizedBox(height: AuthLayout.gapInputToCta),
lib/features/auth/widgets/create_new/create_new_header.dart:4:class CreateNewHeader extends StatelessWidget {
lib/features/auth/widgets/create_new/create_new_header.dart:5:const CreateNewHeader({
lib/features/auth/widgets/create_new/back_button_overlay.dart:5:class CreateNewBackButtonOverlay extends StatelessWidget {
lib/features/auth/widgets/create_new/back_button_overlay.dart:6:const CreateNewBackButtonOverlay({
lib/features/auth/widgets/create_new/back_button_overlay.dart:26:top: safeTop + AuthLayout.backButtonTopInset,
lib/features/auth/widgets/create_new/back_button_overlay.dart:27:left: AuthLayout.horizontalPadding,
lib/features/auth/widgets/create_new/back_button_overlay.dart:28:child: BackButtonCircle(
lib/features/auth/screens/verification_screen.dart:46:AuthLayout.figmaHeaderTop,
lib/features/auth/screens/verification_screen.dart:47:figmaSafeTop: AuthLayout.figmaSafeTop,
lib/features/auth/screens/verification_screen.dart:51:final subtitleStyle = verifySubtitleStyle(context);
lib/features/auth/screens/verification_screen.dart:57:bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
lib/features/auth/screens/verification_screen.dart:70:VerifyHeader(
lib/features/auth/screens/verification_screen.dart:77:backButtonSize: AuthLayout.backButtonSize,
lib/features/auth/screens/verification_screen.dart:78:backButtonInnerSize: AuthLayout.backButtonSize,
lib/features/auth/screens/verification_screen.dart:79:backButtonBackgroundColor: primaryColor,
lib/features/auth/screens/verification_screen.dart:80:backButtonIconColor: onSurfaceColor,
lib/features/auth/screens/verification_screen.dart:92:topPadding: AuthLayout.inputToCta,
lib/features/auth/screens/verification_screen.dart:132:subtitle: AuthStrings.verifyEmailSubtitle,
lib/features/auth/screens/verification_screen.dart:137:subtitle: AuthStrings.verifyResetSubtitle,
lib/features/auth/screens/login_screen.dart:73:// Reserve unterhalb der Felder: CTA + Social-Block + Footer + safeBottom
lib/features/auth/screens/login_screen.dart:74:bottom: AuthLayout.inlineCtaReserveLoginApprox + safeBottom,
lib/features/auth/screens/login_screen.dart:143:LoginHeaderSection(
lib/features/auth/screens/login_screen.dart:170:const SizedBox(height: AuthLayout.ctaTopAfterCopy),
lib/features/auth/screens/create_new_password_screen.dart:38:static const double _backButtonSize = AuthLayout.backButtonSize;
lib/features/auth/screens/create_new_password_screen.dart:53:final backButtonTopSpacing = topOffsetFromSafeArea(
lib/features/auth/screens/create_new_password_screen.dart:55:AuthLayout.backButtonTop,
lib/features/auth/screens/create_new_password_screen.dart:56:figmaSafeTop: AuthLayout.figmaSafeTop,
lib/features/auth/screens/create_new_password_screen.dart:59:backButtonTopSpacing + _backButtonSize + AuthLayout.gapTitleToInputs / 2;
lib/features/auth/screens/create_new_password_screen.dart:69:bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
lib/features/auth/screens/create_new_password_screen.dart:77:topPadding: AuthLayout.inputToCta,
lib/features/auth/screens/create_new_password_screen.dart:81:child: ElevatedButton(
lib/features/auth/screens/create_new_password_screen.dart:165:CreateNewHeader(
lib/features/auth/screens/create_new_password_screen.dart:169:const SizedBox(height: AuthLayout.gapTitleToInputs),
lib/features/auth/screens/create_new_password_screen.dart:186:CreateNewBackButtonOverlay(
lib/features/auth/screens/create_new_password_screen.dart:197:size: _CreateNewPasswordScreenState._backButtonSize,
lib/features/auth/screens/create_new_password_screen.dart:198:iconSize: AuthLayout.backIconSize,
lib/features/auth/screens/reset_password_screen.dart:54:final backButtonTopSpacing = topOffsetFromSafeArea(
lib/features/auth/screens/reset_password_screen.dart:56:AuthLayout.backButtonTop,
lib/features/auth/screens/reset_password_screen.dart:57:figmaSafeTop: AuthLayout.figmaSafeTop,
lib/features/auth/screens/reset_password_screen.dart:62:bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
lib/features/auth/screens/reset_password_screen.dart:84:SizedBox(height: backButtonTopSpacing),
lib/features/auth/screens/reset_password_screen.dart:85:BackButtonCircle(
lib/features/auth/screens/reset_password_screen.dart:93:size: AuthLayout.backButtonSize,
lib/features/auth/screens/reset_password_screen.dart:94:innerSize: AuthLayout.backButtonSize,
lib/features/auth/screens/reset_password_screen.dart:98:const SizedBox(height: AuthLayout.backButtonToTitle),
lib/features/auth/screens/reset_password_screen.dart:105:Text(AuthStrings.forgotSubtitle, style: subtitleStyle),
lib/features/auth/screens/reset_password_screen.dart:106:const SizedBox(height: AuthLayout.titleToInput),
lib/features/auth/screens/reset_password_screen.dart:118:const SizedBox(height: AuthLayout.inputToCta),
lib/features/auth/screens/reset_password_screen.dart:122:child: ElevatedButton(
lib/features/auth/screens/auth_signup_screen.dart:46:bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
lib/features/auth/screens/auth_signup_screen.dart:54:topPadding: AuthLayout.inputToCta,
lib/features/auth/screens/auth_signup_screen.dart:62:const _SignupHeader(),
lib/features/auth/screens/auth_signup_screen.dart:81:class _SignupHeader extends StatelessWidget {
lib/features/auth/screens/auth_signup_screen.dart:82:const _SignupHeader();
lib/features/auth/screens/auth_signup_screen.dart:98:AuthStrings.signupSubtitle,
lib/features/auth/screens/auth_signup_screen.dart:103:const SizedBox(height: AuthLayout.gapTitleToInputs),
lib/features/auth/screens/auth_signup_screen.dart:153:const SizedBox(height: AuthLayout.inputToCta),
lib/features/auth/screens/auth_signup_screen.dart:178:child: ElevatedButton(
lib/features/auth/screens/auth_signup_screen.dart:185:TextButton(
lib/features/auth/screens/auth_signup_screen.dart:305:// TODO: später CTA triggern.
lib/features/auth/screens/success_screen.dart:30:AuthLayout.hPadding40 - AuthLayout.horizontalPadding;
lib/features/auth/screens/success_screen.dart:34:AuthLayout.iconTopSuccess,
lib/features/auth/screens/success_screen.dart:35:figmaSafeTop: AuthLayout.figmaSafeTop,
lib/features/auth/screens/success_screen.dart:60:subtitleText = AuthStrings.successPwdSubtitle;
lib/features/auth/screens/success_screen.dart:64:subtitleText = AuthStrings.successForgotSubtitle;
lib/features/auth/screens/success_screen.dart:87:iconContainerSize: AuthLayout.successIconCircle,
lib/features/auth/screens/success_screen.dart:88:iconSize: AuthLayout.successIconInner,
lib/features/auth/screens/success_screen.dart:174:child: ElevatedButton(

````

## Konstruktoren – Signaturen
````
lib/features/auth/screens/auth_signup_screen.dart:AuthSignupScreen({super.key})
lib/features/auth/widgets/login_header_section.dart:LoginHeaderSection({     super.key,     required this.emailController,     required this.passwordController,     required this.emailError,     required this.passwordError,     required this.obscurePassword,     required this.fieldScrollPadding,     required this.onEmailChanged,     required this.onPasswordChanged,     required this.onToggleObscure,     required this.onForgotPassword,     required this.onSubmit,   })
lib/features/auth/widgets/verify_header.dart:VerifyHeader({     super.key,     required this.topSpacing,     required this.title,     required this.subtitle,     required this.titleStyle,     required this.subtitleStyle,     required this.onBackPressed,     required this.backButtonSize,     required this.backButtonInnerSize,     required this.backButtonBackgroundColor,     required this.backButtonIconColor,   })
lib/features/auth/widgets/auth_text_field.dart:AuthTextField({     super.key,     required this.controller,     required this.hintText,     this.keyboardType = TextInputType.text,     this.textCapitalization = TextCapitalization.none,     this.textInputAction = TextInputAction.next,     this.autofillHints,     this.errorText,     this.obscureText = false,     this.autofocus = false,     this.onChanged,     this.onSubmitted,     this.scrollPadding = EdgeInsets.zero,   })
lib/features/auth/widgets/auth_bottom_cta.dart:AuthBottomCta({     super.key,     required this.child,     this.topPadding = AuthLayout.ctaTopAfterCopy,     this.horizontalPadding = AuthLayout.horizontalPadding,     this.bottomPadding = Spacing.s,     this.animationDuration = const Duration(milliseconds: 200)
lib/features/auth/widgets/verification_code_input.dart:VerificationCodeInput({     super.key,     this.length = 6,     required this.onChanged,     this.onCompleted,     this.controllers,     this.fieldSize = AuthLayout.otpFieldSize,     this.gap = AuthLayout.otpGap,     this.autofocus = false,     this.error = false,     this.inactiveBorderColor,     this.focusedBorderColor,     this.filled = true,     this.fillColor,     this.scrollPadding = EdgeInsets.zero,   })
lib/features/auth/widgets/auth_screen_shell.dart:AuthScreenShell({     super.key,     required this.children,     this.controller,     this.includeBottomReserve = true,   })
lib/features/auth/widgets/login_forgot_button.dart:LoginForgotButton({super.key, required this.onPressed})
lib/features/auth/widgets/login_header.dart:LoginHeader({super.key})
lib/features/auth/widgets/social_auth_row.dart:SocialAuthRow({     super.key,     required this.onGoogle,     required this.onApple,     this.dividerToButtonsGap = Spacing.l + Spacing.xs,   })
lib/features/auth/widgets/create_new/back_button_overlay.dart:CreateNewBackButtonOverlay({     super.key,     required this.safeTop,     required this.onPressed,     required this.backgroundColor,     required this.iconColor,     this.size = 40,     this.iconSize = 20,   })
lib/features/auth/widgets/create_new/create_new_header.dart:CreateNewHeader({     super.key,     required this.headerKey,     required this.topGap,   })
lib/features/cycle/widgets/phase_badge.dart:PhaseBadge({     super.key,     required this.info,     required this.date,     required this.consentGiven,   })
lib/features/consent/widgets/consent_button.dart:ConsentButton({super.key})
lib/features/widgets/back_button.dart:BackButtonCircle({     super.key,     required this.onPressed,     this.size = 44,     this.innerSize,     this.backgroundColor,     this.iconColor,     this.isCircular = true,     this.iconSize = 20,   })
````

## Token-Quellen im Code
````
lib/core/theme/app_theme.dart:3:import '../design_tokens/spacing.dart';
lib/core/theme/app_theme.dart:22:static const TextTheme _textThemeConst = TextTheme(
lib/core/theme/app_theme.dart:63:colorScheme: _buildColorScheme(),
lib/core/theme/app_theme.dart:65:textTheme: _buildTextTheme(),
lib/core/theme/app_theme.dart:69:extensions: const <ThemeExtension<dynamic>>[DsTokens.light],
lib/core/theme/app_theme.dart:73:static ColorScheme _buildColorScheme() {
lib/core/theme/app_theme.dart:74:return ColorScheme.fromSeed(
lib/core/theme/app_theme.dart:85:static TextTheme _buildTextTheme() => _textThemeConst;
lib/core/theme/app_theme.dart:98:borderRadius: BorderRadius.circular(Sizes.radiusM),
lib/core/theme/app_theme.dart:106:elevation: 0,
lib/core/theme/app_theme.dart:126:/// Design System tokens not covered by Material ColorScheme.
lib/core/theme/app_theme.dart:129:class DsTokens extends ThemeExtension<DsTokens> {
lib/core/theme/app_theme.dart:130:const DsTokens({
lib/core/theme/app_theme.dart:146:static const DsTokens light = DsTokens(
lib/core/theme/app_theme.dart:156:DsTokens copyWith({
lib/core/theme/app_theme.dart:163:}) => DsTokens(
lib/core/theme/app_theme.dart:173:DsTokens lerp(ThemeExtension<DsTokens>? other, double t) {
lib/core/theme/app_theme.dart:174:if (other is! DsTokens) return this;
lib/core/theme/app_theme.dart:175:return DsTokens(
lib/core/utils/layout_utils.dart:3:/// Converts an absolute Figma Y-position into the additional spacing needed
lib/core/design_tokens/README.md:9:- spacing/24 → const SizedBox(height: 24)  # dokumentierte Spacing-Skala
lib/core/design_tokens/sizes.dart:3:static const double radiusM = 12.0; // default medium radius
lib/core/design_tokens/sizes.dart:4:static const double radiusL = 20.0; // cards / collage tiles
lib/core/design_tokens/sizes.dart:7:/// Figma: 40 px Kreisradius (z. B. Social-Button)
lib/core/design_tokens/sizes.dart:8:static const double radiusXL = 40.0;

````

## Routen-Referenzen (Consent→Auth)
````
lib/features/consent/widgets/consent_button.dart:2:import 'package:luvi_app/features/consent/state/consent_service.dart';
lib/features/consent/screens/consent_welcome_03_screen.dart:32:onNext: () => context.push('/consent/01'),
lib/features/consent/screens/consent_02_screen.dart:6:import 'package:luvi_app/features/consent/state/consent02_state.dart';
lib/features/consent/screens/consent_02_screen.dart:198:final r = GoRouter.of(context);
lib/features/consent/screens/consent_02_screen.dart:202:context.go('/consent/01');
lib/features/consent/screens/consent_02_screen.dart:305:? () => context.go('/auth/login')
lib/features/consent/screens/consent_01_screen.dart:9:static const String routeName = '/consent/01';
lib/features/consent/screens/consent_01_screen.dart:69:onPressed: () => context.push('/consent/02'),
lib/features/consent/screens/consent_01_screen.dart:88:asset: 'assets/images/consent/consent_02_01_hero_01.png',
lib/features/consent/screens/consent_01_screen.dart:93:asset: 'assets/images/consent/consent_02_01_hero_02.png',
lib/features/consent/screens/consent_01_screen.dart:98:asset: 'assets/images/consent/consent_02_01_hero_03.png',
lib/features/consent/screens/consent_01_screen.dart:103:asset: 'assets/images/consent/consent_02_01_hero_04.png',
lib/features/consent/routes.dart:2:import 'package:luvi_app/features/auth/screens/login_screen.dart';
lib/features/consent/routes.dart:4:import 'screens/consent_01_screen.dart';
lib/features/consent/routes.dart:5:import 'screens/consent_02_screen.dart';
lib/features/consent/routes.dart:6:import 'screens/consent_welcome_01_screen.dart';
lib/features/consent/routes.dart:7:import 'screens/consent_welcome_02_screen.dart';
lib/features/consent/routes.dart:8:import 'screens/consent_welcome_03_screen.dart';
lib/features/consent/routes.dart:10:final consentRoutes = <GoRoute>[
lib/features/consent/routes.dart:11:GoRoute(
lib/features/consent/routes.dart:16:GoRoute(
lib/features/consent/routes.dart:21:GoRoute(
lib/features/consent/routes.dart:26:GoRoute(
lib/features/consent/routes.dart:31:GoRoute(
lib/features/consent/routes.dart:32:path: '/consent/02',
lib/features/consent/routes.dart:36:GoRoute(
lib/features/consent/routes.dart:37:path: '/auth/login',
lib/features/routes.dart:3:import 'package:luvi_app/features/consent/routes.dart' as consent;
lib/features/routes.dart:4:import 'package:luvi_app/features/auth/screens/create_new_password_screen.dart';
lib/features/routes.dart:5:import 'package:luvi_app/features/auth/screens/login_screen.dart';
lib/features/routes.dart:6:import 'package:luvi_app/features/auth/screens/success_screen.dart';
lib/features/routes.dart:7:import 'package:luvi_app/features/auth/screens/verification_screen.dart';
lib/features/routes.dart:8:import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
lib/features/routes.dart:9:import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
lib/features/routes.dart:12:final List<GoRoute> featureRoutes = [
lib/features/routes.dart:14:GoRoute(
lib/features/routes.dart:15:path: '/auth/login',
lib/features/routes.dart:19:GoRoute(
lib/features/routes.dart:20:path: '/auth/forgot',
lib/features/routes.dart:24:GoRoute(
lib/features/routes.dart:25:path: '/auth/forgot/sent',
lib/features/routes.dart:30:GoRoute(
lib/features/routes.dart:31:path: '/auth/password/new',
lib/features/routes.dart:35:GoRoute(
lib/features/routes.dart:36:path: '/auth/password/success',
lib/features/routes.dart:40:GoRoute(
lib/features/routes.dart:41:path: '/auth/verify',
lib/features/routes.dart:51:GoRoute(
lib/features/routes.dart:52:path: '/auth/signup',
lib/features/routes.dart:58:String? supabaseRedirect(BuildContext context, GoRouterState state) {
lib/features/routes.dart:60:final isLoggingIn = state.matchedLocation.startsWith('/auth/login');
lib/features/routes.dart:66:return isLoggingIn ? null : '/auth/login';
lib/features/auth/widgets/login_password_field.dart:5:import 'package:luvi_app/features/auth/widgets/field_error_text.dart';
lib/features/auth/widgets/auth_bottom_cta.dart:3:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/widgets/login_email_field.dart:6:import 'package:luvi_app/features/auth/widgets/field_error_text.dart';
lib/features/auth/widgets/verify_footer.dart:4:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/widgets/verify_header.dart:3:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/widgets/auth_screen_shell.dart:2:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/widgets/verification_code_input.dart:6:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/widgets/login_cta_section.dart:6:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/widgets/auth_text_field.dart:6:import 'package:luvi_app/features/auth/widgets/field_error_text.dart';
lib/features/auth/widgets/login_form_section.dart:2:import 'package:luvi_app/features/auth/widgets/social_auth_row.dart';
lib/features/auth/widgets/login_header_section.dart:3:import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
lib/features/auth/widgets/login_header_section.dart:4:import 'package:luvi_app/features/auth/widgets/login_forgot_button.dart';
lib/features/auth/widgets/login_header_section.dart:5:import 'package:luvi_app/features/auth/widgets/login_header.dart';
lib/features/auth/widgets/login_header_section.dart:6:import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
lib/features/auth/widgets/verify_otp_section.dart:2:import 'package:luvi_app/features/auth/widgets/verification_code_input.dart';
lib/features/auth/screens/verification_screen.dart:6:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/screens/verification_screen.dart:7:import 'package:luvi_app/features/auth/utils/layout_utils.dart';
lib/features/auth/screens/verification_screen.dart:8:import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
lib/features/auth/screens/verification_screen.dart:9:import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
lib/features/auth/screens/verification_screen.dart:10:import 'package:luvi_app/features/auth/widgets/verify_footer.dart';
lib/features/auth/screens/verification_screen.dart:11:import 'package:luvi_app/features/auth/widgets/verify_header.dart';
lib/features/auth/screens/verification_screen.dart:12:import 'package:luvi_app/features/auth/widgets/verify_otp_section.dart';
lib/features/auth/screens/verification_screen.dart:13:import 'package:luvi_app/features/auth/widgets/verify_text_styles.dart';
lib/features/auth/widgets/create_new/back_button_overlay.dart:2:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/screens/auth_signup_screen.dart:6:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/screens/auth_signup_screen.dart:7:import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
lib/features/auth/screens/auth_signup_screen.dart:8:import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
lib/features/auth/screens/auth_signup_screen.dart:9:import 'package:luvi_app/features/auth/widgets/auth_text_field.dart';
lib/features/auth/screens/auth_signup_screen.dart:10:import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
lib/features/auth/screens/auth_signup_screen.dart:11:import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
lib/features/auth/screens/success_screen.dart:7:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/screens/success_screen.dart:8:import 'package:luvi_app/features/auth/utils/layout_utils.dart';
lib/features/auth/screens/success_screen.dart:9:import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
lib/features/auth/screens/success_screen.dart:10:import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
lib/features/auth/screens/reset_password_screen.dart:8:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/screens/reset_password_screen.dart:9:import 'package:luvi_app/features/auth/state/reset_password_state.dart';
lib/features/auth/screens/reset_password_screen.dart:10:import 'package:luvi_app/features/auth/state/reset_submit_provider.dart';
lib/features/auth/screens/reset_password_screen.dart:11:import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
lib/features/auth/screens/reset_password_screen.dart:12:import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
lib/features/auth/widgets/create_new/create_new_form.dart:3:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/widgets/create_new/create_new_form.dart:4:import 'package:luvi_app/features/auth/utils/field_auto_scroller.dart';
lib/features/auth/widgets/create_new/create_new_form.dart:5:import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
lib/features/auth/screens/login_screen.dart:5:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/screens/login_screen.dart:6:import 'package:luvi_app/features/auth/state/login_state.dart';
lib/features/auth/screens/login_screen.dart:7:import 'package:luvi_app/features/auth/state/login_submit_provider.dart';
lib/features/auth/screens/login_screen.dart:8:import 'package:luvi_app/features/auth/widgets/global_error_banner.dart';
lib/features/auth/screens/login_screen.dart:9:import 'package:luvi_app/features/auth/widgets/login_cta_section.dart';
lib/features/auth/screens/login_screen.dart:10:import 'package:luvi_app/features/auth/widgets/login_form_section.dart';
lib/features/auth/screens/login_screen.dart:11:import 'package:luvi_app/features/auth/widgets/login_header_section.dart';
lib/features/auth/screens/create_new_password_screen.dart:6:import 'package:luvi_app/features/auth/layout/auth_layout.dart';
lib/features/auth/screens/create_new_password_screen.dart:7:import 'package:luvi_app/features/auth/utils/layout_utils.dart';
lib/features/auth/screens/create_new_password_screen.dart:8:import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
lib/features/auth/screens/create_new_password_screen.dart:9:import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
lib/features/auth/screens/create_new_password_screen.dart:10:import 'package:luvi_app/features/auth/widgets/create_new/create_new_header.dart';
lib/features/auth/screens/create_new_password_screen.dart:11:import 'package:luvi_app/features/auth/widgets/create_new/create_new_form.dart';
lib/features/auth/screens/create_new_password_screen.dart:12:import 'package:luvi_app/features/auth/widgets/create_new/back_button_overlay.dart';
lib/features/auth/screens/create_new_password_screen.dart:13:import 'package:luvi_app/features/auth/utils/field_auto_scroller.dart';
lib/features/auth/state/login_submit_provider.dart:5:import 'package:luvi_app/features/auth/state/login_state.dart';

````

## Beobachtung
- Recycle vorhandene Buttons/Layout.
- Stelle Token-Mapping Figma→Theme sicher.
- Consent→/auth/entry Route prüfen.
