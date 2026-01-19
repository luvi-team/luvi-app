import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/timing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart';
import 'package:luvi_app/features/auth/screens/login_screen.dart';
import 'package:luvi_app/features/auth/utils/auth_navigation_helpers.dart';
import 'package:luvi_app/features/auth/utils/create_new_password_rules.dart';
import 'package:luvi_app/features/auth/state/auth_controller.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_error_banner.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_scaffold.dart';
import 'package:luvi_app/features/auth/widgets/password_visibility_toggle_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_field.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Signup screen with Auth Rebrand v3 design.
///
/// Features:
/// - Rainbow background with arcs and stripes
/// - Content card with headline and form
/// - Email + Password + Confirm Password fields
/// - Pink CTA button
/// - CTA button only (no login link per SSOT P0.6)
///
/// Route: /auth/signup
class AuthSignupScreen extends ConsumerStatefulWidget {
  const AuthSignupScreen({super.key});

  static const String routeName = '/auth/signup';

  @override
  ConsumerState<AuthSignupScreen> createState() => _AuthSignupScreenState();
}

class _AuthSignupScreenState extends ConsumerState<AuthSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Timer? _signupNavTimer;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _signupNavTimer?.cancel();
    super.dispose();
  }

  /// Validates signup form inputs using NIST SP 800-63B compliant rules.
  /// Returns error message if validation fails, null if valid.
  String? _validateInputs({
    required String email,
    required String password,
    required String confirmPassword,
    required AppLocalizations l10n,
  }) {
    // Check for empty email first (password validation handles empty password)
    if (email.isEmpty) {
      setState(() => _emailError = true);
      return l10n.authSignupMissingFields;
    }

    // Use NIST-compliant validation from shared rules
    final passwordValidation = validateNewPassword(password, confirmPassword);

    if (!passwordValidation.isValid) {
      switch (passwordValidation.error!) {
        case AuthPasswordValidationError.emptyFields:
          setState(() {
            _passwordError = password.isEmpty;
            _confirmPasswordError = confirmPassword.isEmpty;
          });
          return l10n.authSignupMissingFields;
        case AuthPasswordValidationError.mismatch:
          setState(() => _confirmPasswordError = true);
          return l10n.authPasswordMismatchError;
        case AuthPasswordValidationError.tooShort:
          setState(() => _passwordError = true);
          return l10n.authErrPasswordTooShort;
        case AuthPasswordValidationError.commonWeak:
          setState(() => _passwordError = true);
          return l10n.authErrPasswordCommonWeak;
      }
    }

    return null;
  }

  /// Performs the actual signup API call and handles success/error states.
  Future<void> _submitSignup({
    required String email,
    required String password,
    required AppLocalizations l10n,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.signUp(email: email, password: password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authSignupSuccess),
          duration: Timing.snackBarBrief,
        ),
      );

      _signupNavTimer?.cancel();
      _signupNavTimer = Timer(Timing.snackBarBrief, () {
        if (!mounted) return;
        context.go(LoginScreen.routeName);
      });
    } on AuthException catch (error, stackTrace) {
      log.e(
        'signup_failed_auth',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapAuthError(error, l10n);
        _emailError = true;
      });
    } catch (error, stackTrace) {
      log.e(
        'signup_failed',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      setState(() => _errorMessage = l10n.authSignupGenericError);
    }
  }

  Future<void> _handleSignup() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final l10n = AppLocalizations.of(context)!;

    final validationError = _validateInputs(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      l10n: l10n,
    );
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _emailError = false;
      _passwordError = false;
      _confirmPasswordError = false;
    });

    await _submitSignup(email: email, password: password, l10n: l10n);

    if (mounted) setState(() => _isSubmitting = false);
  }

  String _mapAuthError(AuthException error, AppLocalizations l10n) {
    // Map common Supabase auth errors to user-friendly messages
    final message = error.message.toLowerCase();
    if (message.contains('email') && message.contains('invalid')) {
      return l10n.authErrEmailInvalid;
    }
    if (message.contains('password') && message.contains('short')) {
      return l10n.authErrPasswordTooShort;
    }
    if (message.contains('already') || message.contains('exists')) {
      return l10n.authErrConfirmEmail;
    }
    return l10n.authSignupGenericError;
  }

  void _onEmailChanged(String _) {
    if (_errorMessage != null || _emailError) {
      setState(() {
        _errorMessage = null;
        _emailError = false;
      });
    }
  }

  void _onPasswordChanged(String _) {
    if (_errorMessage != null || _passwordError) {
      setState(() {
        _errorMessage = null;
        _passwordError = false;
      });
    }
  }

  void _onConfirmPasswordChanged(String _) {
    if (_errorMessage != null || _confirmPasswordError) {
      setState(() {
        _errorMessage = null;
        _confirmPasswordError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthRebrandScaffold(
      scaffoldKey: const ValueKey('auth_signup_screen'),
      onBack: () => handleAuthBackNavigation(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Global error banner
          if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),

          // Content card (SSOT: form screens use 364px width)
          AuthContentCard(
            width: AuthRebrandMetrics.cardWidthForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Headline
                Text(
                  l10n.authRegisterEmailTitle,
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
                  key: const ValueKey('signup_email_field'),
                  controller: _emailController,
                  hintText: l10n.authEmailPlaceholderLong,
                  errorText: _emailError ? l10n.authErrorEmailCheck : null,
                  hasError: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: _onEmailChanged,
                ),

                const SizedBox(height: AuthRebrandMetrics.cardInputGap),

                // Password field
                AuthRebrandTextField(
                  key: const ValueKey('signup_password_field'),
                  controller: _passwordController,
                  hintText: l10n.authPasswordPlaceholder,
                  errorText: _passwordError ? l10n.authErrorPasswordCheck : null,
                  hasError: _passwordError,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onChanged: _onPasswordChanged,
                  suffixIcon: PasswordVisibilityToggleButton(
                    obscured: _obscurePassword,
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    color: DsColors.grayscale500,
                    size: AuthRebrandMetrics.passwordToggleIconSize,
                  ),
                ),

                const SizedBox(height: AuthRebrandMetrics.cardInputGap),

                // Confirm password field
                AuthRebrandTextField(
                  key: const ValueKey('signup_password_confirm_field'),
                  controller: _confirmPasswordController,
                  hintText: l10n.authNewPasswordConfirmHint,
                  errorText: _confirmPasswordError
                      ? l10n.authPasswordMismatchError
                      : null,
                  hasError: _confirmPasswordError,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onChanged: _onConfirmPasswordChanged,
                  onSubmitted: (_) {
                    if (!_isSubmitting) _handleSignup();
                  },
                  suffixIcon: PasswordVisibilityToggleButton(
                    obscured: _obscureConfirmPassword,
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    color: DsColors.grayscale500,
                    size: AuthRebrandMetrics.passwordToggleIconSize,
                  ),
                ),

                const SizedBox(height: Spacing.m),

                // CTA button (no login link per SSOT)
                AuthPrimaryButton(
                  key: const ValueKey('signup_cta_button'),
                  loadingKey: const ValueKey('signup_cta_loading'),
                  label: l10n.authEntryCta,
                  onPressed: _isSubmitting ? null : _handleSignup,
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
