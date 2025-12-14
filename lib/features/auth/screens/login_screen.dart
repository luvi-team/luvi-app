import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/auth_signup_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/login_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/auth_linear_gradient_background.dart';
import 'package:luvi_app/features/auth/widgets/auth_shell.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// LoginScreen with Figma Auth UI v2 design.
///
/// Figma Node: 68919:8853
/// Route: /auth/login
///
/// Features:
/// - Linear gradient background
/// - Back button navigation
/// - Email + Password form
/// - Pink CTA button (56px height)
/// - "Passwort vergessen?" link
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/auth/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final loginNotifier = ref.read(loginProvider.notifier);
    final initialState = loginNotifier.currentState;
    if (_emailController.text != initialState.email) {
      _emailController.value = _emailController.value.copyWith(
        text: initialState.email,
        selection: TextSelection.collapsed(offset: initialState.email.length),
      );
    }
    if (_passwordController.text != initialState.password) {
      _passwordController.value = _passwordController.value.copyWith(
        text: initialState.password,
        selection: TextSelection.collapsed(
          offset: initialState.password.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    assert(
      localizations != null,
      'AppLocalizations not configured. Ensure localizationsDelegates '
      'include AppLocalizations.delegate in MaterialApp.',
    );
    final l10n = localizations!;
    final theme = Theme.of(context);
    final tokensNullable = theme.extension<DsTokens>();
    assert(
      tokensNullable != null,
      'DsTokens not configured. Ensure AppTheme includes DsTokens extension.',
    );
    final tokens = tokensNullable!;

    final loginAsync = ref.watch(loginProvider);
    final loginState = loginAsync.value ?? LoginState.initial();
    final emailError = loginState.emailError;
    final passwordError = loginState.passwordError;
    final submitState = ref.watch(loginSubmitProvider);
    final isLoading = submitState.isLoading;
    final hasValidationError = emailError != null || passwordError != null;

    // Figma: Title style - Playfair Display Bold, 24px
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: Sizes.authTitleFontSize,
      height: Sizes.authTitleLineHeight,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );

    // Figma: Forgot link style - Figtree Bold, 20px, #696969
    final forgotLinkStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: Sizes.authLinkFontSize,
      height: Sizes.authLinkLineHeight,
      fontWeight: FontWeight.bold,
      color: tokens.grayscale500,
    );

    // Signup link style - uses authSubtitle tokens for consistency
    final signupLinkStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: Sizes.authSubtitleFontSize,
      height: Sizes.authSubtitleLineHeight,
      color: theme.colorScheme.onSurface,
    );

    final signupLinkActionStyle = signupLinkStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: tokens.cardBorderSelected,
      decoration: TextDecoration.underline,
    );

    return Scaffold(
      key: const ValueKey('auth_login_screen'),
      resizeToAvoidBottomInset: true,
      body: AuthShell(
        background: const AuthLinearGradientBackground(),
        showBackButton: true,
        onBackPressed: () {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            // Navigate to sign-in using SSOT route constant
            context.go(AuthSignInScreen.routeName);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Figma: Gap after back button
            const SizedBox(height: AuthLayout.backButtonToTitle),

            // Title: "Anmelden mit E-Mail"
            Text(
              l10n.authLoginTitle,
              style: titleStyle,
            ),

            // Figma: Gap between title and inputs (32px)
            const SizedBox(height: AuthLayout.ctaTopAfterCopy),

            // Email field
            // Auth-Flow Bugfix: Keyboard öffnet nicht automatisch
            LoginEmailField(
              key: const ValueKey('login_email_field'),
              controller: _emailController,
              errorText: emailError,
              autofocus: false,
              onChanged: _onEmailChanged,
            ),

            // Figma: Gap between inputs = 20px
            const SizedBox(height: AuthLayout.inputGap),

            // Password field
            LoginPasswordField(
              key: const ValueKey('login_password_field'),
              controller: _passwordController,
              errorText: passwordError,
              obscure: _obscurePassword,
              onToggleObscure: _toggleObscurePassword,
              onChanged: _onPasswordChanged,
              onSubmitted: (_) => _submit(),
            ),

            // Figma: Gap before CTA (40px)
            const SizedBox(height: AuthLayout.inputToCta),

            // CTA Button - Figma: h=56px
            SizedBox(
              width: double.infinity,
              height: Sizes.buttonHeightL, // 56px
              child: WelcomeButton(
                key: const ValueKey('login_cta_button'),
                onPressed: (isLoading || hasValidationError) ? null : _submit,
                isLoading: isLoading,
                label: l10n.authLoginCta,
                loadingKey: const ValueKey('login_cta_loading'),
                labelKey: const ValueKey('login_cta_label'),
              ),
            ),

            // Figma: Gap before forgot link
            const SizedBox(height: Spacing.l), // 24px

            // "Passwort vergessen?" link - centered
            Center(
              child: TextButton(
                key: const ValueKey('login_forgot_link'),
                onPressed: () => context.push(ResetPasswordScreen.routeName),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(Sizes.touchTargetMin, Sizes.touchTargetMin),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.authLoginForgot,
                  style: forgotLinkStyle,
                ),
              ),
            ),

            // Spacing zwischen Forgot und Signup Link
            const SizedBox(height: Spacing.m), // 16px

            // "Neu bei LUVI? Hier starten" link - centered
            // Pattern aus auth_signup_screen.dart:256-284
            Center(
              child: Semantics(
                button: true,
                label: '${l10n.authLoginCtaLinkPrefix}${l10n.authLoginCtaLinkAction}',
                child: TextButton(
                  key: const ValueKey('login_signup_link'),
                  onPressed: () => context.push(AuthSignupScreen.routeName),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize:
                        const Size(Sizes.touchTargetMin, Sizes.touchTargetMin),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: l10n.authLoginCtaLinkPrefix,
                          style: signupLinkStyle,
                        ),
                        TextSpan(
                          text: l10n.authLoginCtaLinkAction,
                          style: signupLinkActionStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom padding for keyboard
            const SizedBox(height: Spacing.l),
          ],
        ),
      ),
    );
  }

  void _onEmailChanged(String value) {
    final notifier = ref.read(loginProvider.notifier);
    notifier.setEmail(value);
    final state = ref.read(loginProvider).value;
    if (state?.globalError != null) {
      notifier.clearGlobalError();
    }
  }

  void _onPasswordChanged(String value) {
    final notifier = ref.read(loginProvider.notifier);
    notifier.setPassword(value);
    final state = ref.read(loginProvider).value;
    if (state?.globalError != null) {
      notifier.clearGlobalError();
    }
  }

  void _toggleObscurePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _submit() {
    final submitNotifier = ref.read(loginSubmitProvider.notifier);
    if (ref.read(loginSubmitProvider).isLoading) return;
    submitNotifier.submit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}
