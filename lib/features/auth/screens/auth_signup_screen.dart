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
    // Email-Validierung (nicht von validateNewPassword abgedeckt)
    final isEmailEmpty = email.isEmpty;

    // NIST-compliant Validation via shared rules
    final passwordValidation = validateNewPassword(password, confirmPassword);

    // Sammle alle Error-Flags zuerst
    bool passwordError = false;
    bool confirmError = false;
    String? errorMessage;

    if (!passwordValidation.isValid) {
      switch (passwordValidation.error!) {
        case AuthPasswordValidationError.emptyFields:
          // Spezifische Flags basierend auf tatsächlich leeren Feldern
          passwordError = password.isEmpty;
          confirmError = confirmPassword.isEmpty;
          errorMessage = l10n.authSignupMissingFields;
        case AuthPasswordValidationError.mismatch:
          confirmError = true;
          errorMessage = l10n.authPasswordMismatchError;
        case AuthPasswordValidationError.tooShort:
          passwordError = true;
          errorMessage = l10n.authErrPasswordTooShort;
        case AuthPasswordValidationError.commonWeak:
          passwordError = true;
          errorMessage = l10n.authErrPasswordCommonWeak;
      }
    }

    // Email-Error zusätzlich prüfen (nicht statt!)
    // Wenn Email leer UND Password-Error: zeige spezifischen Password-Error
    // Wenn NUR Email leer: zeige Missing Fields
    if (isEmailEmpty && errorMessage == null) {
      errorMessage = l10n.authSignupMissingFields;
    }

    // Setze alle Flags einmalig
    setState(() {
      _emailError = isEmailEmpty;
      _passwordError = passwordError;
      _confirmPasswordError = confirmError;
    });

    return errorMessage;
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

        // Clear both flags first
        _emailError = false;
        _passwordError = false;

        // Use error.code for field attribution (more robust than message parsing)
        final code = error.code?.toLowerCase();
        if (code != null) {
          if (code == 'weak_password') {
            _passwordError = true;
          } else if (code == 'over_request_rate_limit' ||
                     code == 'signup_disabled') {
            // Ambiguous codes: no field-specific flags
            // _errorMessage already shows the error in the banner
          } else {
            // email_address_invalid, email_exists, user_already_exists, etc.
            _emailError = true;
          }
        } else {
          // Fallback: message pattern matching when code is null
          final message = error.message.toLowerCase();
          if (message.contains('password')) {
            _passwordError = true;
          } else if (message.contains('email') ||
                     message.contains('address') ||
                     message.contains('user')) {
            _emailError = true;
          }
          // Ambiguous errors (network, rate-limit, unknown): no field flags
          // _errorMessage already shows the error in the banner
        }
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
    final code = error.code?.toLowerCase();

    // Primary: Check error.code (robust, structured)
    if (code != null) {
      switch (code) {
        case 'email_address_invalid':
        case 'validation_failed':
          return l10n.authErrEmailInvalid;
        case 'weak_password':
          return l10n.authErrPasswordTooShort;
        case 'email_exists':
        case 'user_already_exists':
          return l10n.authErrConfirmEmail;
        case 'signup_disabled':
        case 'over_request_rate_limit':
          return l10n.authSignupGenericError;
      }
    }

    // Fallback: Message pattern matching (when code is null)
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

  void _onConfirmPasswordChanged(String value) {
    final password = _passwordController.text;

    setState(() {
      // Immer globale Fehlermeldung bei Änderung löschen
      _errorMessage = null;

      // Logik für _confirmPasswordError:
      // - Leeres Feld: Error löschen (User tippt noch)
      // - Beide non-empty und gleich: Error löschen (Match!)
      // - Beide non-empty und ungleich: Error NICHT setzen während Tippen
      //   (das macht _validateInputs bei Submit)
      if (value.isEmpty || (password.isNotEmpty && value == password)) {
        _confirmPasswordError = false;
      }
      // Hinweis: Wir setzen _confirmPasswordError NICHT auf true hier,
      // um nerviges Flackern während des Tippens zu vermeiden.
      // Mismatch wird erst bei Submit geprüft.
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthRebrandScaffold(
      scaffoldKey: const ValueKey('auth_signup_screen'),
      onBack: () => handleAuthBackNavigation(context),
      child: _buildContent(l10n),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
        _buildFormCard(l10n),
      ],
    );
  }

  Widget _buildFormCard(AppLocalizations l10n) {
    return AuthContentCard(
      width: AuthRebrandMetrics.cardWidthForm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeadline(l10n),
          const SizedBox(height: Spacing.m),
          _buildEmailField(l10n),
          const SizedBox(height: AuthRebrandMetrics.cardInputGap),
          _buildPasswordField(l10n),
          const SizedBox(height: AuthRebrandMetrics.cardInputGap),
          _buildConfirmPasswordField(l10n),
          const SizedBox(height: Spacing.m),
          _buildCtaButton(l10n),
        ],
      ),
    );
  }

  Widget _buildHeadline(AppLocalizations l10n) {
    return Text(
      l10n.authRegisterEmailTitle,
      style: const TextStyle(
        fontFamily: FontFamilies.playfairDisplay,
        fontSize: AuthRebrandMetrics.headlineFontSize,
        fontWeight: FontWeight.w600,
        height: AuthRebrandMetrics.headlineLineHeight,
        color: DsColors.authRebrandTextPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return AuthRebrandTextField(
      key: const ValueKey('signup_email_field'),
      controller: _emailController,
      hintText: l10n.authEmailPlaceholderLong,
      errorText: _emailError ? l10n.authErrorEmailCheck : null,
      hasError: _emailError,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: _onEmailChanged,
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return AuthRebrandTextField(
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
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    final confirmErrorText = _confirmPasswordError
        ? (_confirmPasswordController.text.isEmpty
            ? l10n.authErrPasswordInvalid
            : l10n.authPasswordMismatchError)
        : null;

    return AuthRebrandTextField(
      key: const ValueKey('signup_password_confirm_field'),
      controller: _confirmPasswordController,
      hintText: l10n.authNewPasswordConfirmHint,
      errorText: confirmErrorText,
      hasError: _confirmPasswordError,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onChanged: _onConfirmPasswordChanged,
      onSubmitted: (_) {
        if (!_isSubmitting) _handleSignup();
      },
      suffixIcon: PasswordVisibilityToggleButton(
        obscured: _obscureConfirmPassword,
        onPressed: () => setState(
          () => _obscureConfirmPassword = !_obscureConfirmPassword,
        ),
        color: DsColors.grayscale500,
        size: AuthRebrandMetrics.passwordToggleIconSize,
      ),
    );
  }

  Widget _buildCtaButton(AppLocalizations l10n) {
    return AuthPrimaryButton(
      key: const ValueKey('signup_cta_button'),
      loadingKey: const ValueKey('signup_cta_loading'),
      label: l10n.authEntryCta,
      onPressed: _isSubmitting ? null : _handleSignup,
      isLoading: _isSubmitting,
    );
  }
}
