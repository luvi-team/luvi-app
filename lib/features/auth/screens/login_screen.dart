import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/reset_password_screen.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/login_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_back_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rainbow_background.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_field.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Login screen with Auth Rebrand v3 design.
///
/// Features:
/// - Rainbow background with arcs and stripes
/// - Content card with headline and form
/// - Email + Password fields with error states
/// - Pink CTA button
/// - "Passwort vergessen?" link
/// - "Neu bei LUVI? Hier starten" link
///
/// Route: /auth/login
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
    final l10n = AppLocalizations.of(context)!;

    final loginAsync = ref.watch(loginProvider);
    final loginState = loginAsync.value ?? LoginState.initial();
    final emailError = loginState.emailError;
    final passwordError = loginState.passwordError;
    final globalError = loginState.globalError;
    final submitState = ref.watch(loginSubmitProvider);
    final isLoading = submitState.isLoading;
    final hasEmailError = emailError != null;
    final hasPasswordError = passwordError != null;

    return Scaffold(
      key: const ValueKey('auth_login_screen'),
      backgroundColor: DsColors.authRebrandBackground,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Rainbow background
          const Positioned.fill(
            child: AuthRainbowBackground(),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AuthRebrandMetrics.backButtonLeft,
                        top: AuthRebrandMetrics.backButtonTop,
                      ),
                      child: AuthBackButton(
                        onPressed: () {
                          final router = GoRouter.of(context);
                          if (router.canPop()) {
                            router.pop();
                          } else {
                            context.go(AuthSignInScreen.routeName);
                          }
                        },
                        semanticsLabel: l10n.authBackSemantic,
                      ),
                    ),
                  ),

                  const SizedBox(height: AuthRebrandMetrics.contentTopGap),

                  // Global error banner
                  if (globalError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                      child: Container(
                        padding: const EdgeInsets.all(Spacing.s),
                        margin: const EdgeInsets.only(bottom: Spacing.m),
                        decoration: BoxDecoration(
                          color: DsColors.authRebrandError.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Sizes.radiusS),
                          border: Border.all(
                            color: DsColors.authRebrandError,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          globalError,
                          style: const TextStyle(
                            fontFamily: FontFamilies.figtree,
                            fontSize: AuthRebrandMetrics.errorTextFontSize,
                            color: DsColors.authRebrandError,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Content card (SSOT: form screens use 364px width)
                  AuthContentCard(
                    width: AuthRebrandMetrics.cardWidthForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Headline
                        Text(
                          l10n.authLoginTitle,
                          style: const TextStyle(
                            fontFamily: FontFamilies.playfairDisplay,
                            fontSize: AuthRebrandMetrics.headlineFontSize,
                            fontWeight: FontWeight.w600,
                            height: AuthRebrandMetrics.headlineLineHeight,
                            color: DsColors.authRebrandTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Spacing.m),

                        // Email field
                        AuthRebrandTextField(
                          key: const ValueKey('login_email_field'),
                          controller: _emailController,
                          hintText: l10n.authEmailPlaceholderLong,
                          errorText: hasEmailError ? l10n.authErrorEmailCheck : null,
                          hasError: hasEmailError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: _onEmailChanged,
                        ),

                        const SizedBox(height: AuthRebrandMetrics.cardInputGap),

                        // Password field
                        AuthRebrandTextField(
                          key: const ValueKey('login_password_field'),
                          controller: _passwordController,
                          hintText: l10n.authPasswordPlaceholder,
                          errorText: hasPasswordError ? l10n.authErrorPasswordCheck : null,
                          hasError: hasPasswordError,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onChanged: _onPasswordChanged,
                          onSubmitted: (_) => _submit(),
                          suffixIcon: Semantics(
                            button: true,
                            label: _obscurePassword
                                ? l10n.authShowPassword
                                : l10n.authHidePassword,
                            child: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: DsColors.grayscale500,
                                size: AuthRebrandMetrics.passwordToggleIconSize,
                              ),
                              onPressed: _toggleObscurePassword,
                            ),
                          ),
                        ),

                        const SizedBox(height: Spacing.m),

                        // CTA button
                        AuthPrimaryButton(
                          key: const ValueKey('login_cta_button'),
                          loadingKey: const ValueKey('login_cta_loading'),
                          label: l10n.authEntryCta,
                          onPressed: isLoading ? null : _submit,
                          isLoading: isLoading,
                        ),

                        const SizedBox(height: Spacing.m),

                        // Forgot password link (only link per SSOT)
                        _buildForgotLink(l10n),
                      ],
                    ),
                  ),

                  const SizedBox(height: AuthRebrandMetrics.contentBottomGap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotLink(AppLocalizations l10n) {
    return Semantics(
      button: true,
      label: l10n.authLoginForgot,
      child: GestureDetector(
        key: const ValueKey('login_forgot_link'),
        onTap: () => context.push(ResetPasswordScreen.routeName),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Text(
            l10n.authLoginForgot,
            style: TextStyle(
              fontFamily: FontFamilies.figtree,
              fontSize: AuthRebrandMetrics.dividerTextFontSize,
              fontWeight: FontWeight.w600,
              color: DsColors.grayscale500,
            ),
          ),
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
