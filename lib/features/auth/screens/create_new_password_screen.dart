import 'dart:async' show TimeoutException, Timer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/utils/create_new_password_rules.dart';
import 'package:luvi_app/features/auth/widgets/auth_linear_gradient_background.dart';
import 'package:luvi_app/features/auth/widgets/auth_shell.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// CreateNewPasswordScreen with Figma Auth UI v2 design.
///
/// Figma Node: 68919:8814
/// Route: /auth/password/new
///
/// Features:
/// - Linear gradient background
/// - Back button navigation
/// - Title: "Neues Passwort erstellen"
/// - Two password fields (new + confirm)
/// - Pink CTA button (56px height)
/// - Password validation with backoff protection
class CreateNewPasswordScreen extends StatefulWidget {
  static const String routeName = '/auth/password/new';

  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Inline validation error states for per-field feedback
  String? _newPasswordError;
  String? _confirmPasswordError;

  // Rate limiting with exponential backoff
  int _consecutiveFailures = 0;
  DateTime? _lastFailureAt;
  Timer? _backoffTicker;

  int get _backoffRemainingSeconds {
    if (_consecutiveFailures <= 0 || _lastFailureAt == null) return 0;
    final delay = computePasswordBackoffDelay(_consecutiveFailures);
    final end = _lastFailureAt!.add(delay);
    final now = DateTime.now();
    final remaining = end.difference(now).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  bool get _isBackoffActive => _backoffRemainingSeconds > 0;

  void _startBackoffTicker() {
    _backoffTicker?.cancel();
    if (!_isBackoffActive) return;
    _backoffTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isBackoffActive) {
        t.cancel();
      }
      setState(() {});
    });
  }

  void _handlePasswordUpdateFailure(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    setState(() {
      _consecutiveFailures = (_consecutiveFailures + 1).clamp(0, 16);
      _lastFailureAt = DateTime.now();
    });
    _startBackoffTicker();
    final wait = _backoffRemainingSeconds;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.authPasswordUpdateError} ${l10n.authErrWaitBeforeRetry(wait)}',
        ),
      ),
    );
  }

  String? _validationMessageFor(
    AuthPasswordValidationError error,
    AppLocalizations l10n,
  ) {
    switch (error) {
      case AuthPasswordValidationError.emptyFields:
        return l10n.authErrPasswordInvalid;
      case AuthPasswordValidationError.mismatch:
        return l10n.authPasswordMismatchError;
      case AuthPasswordValidationError.tooShort:
        return l10n.authErrPasswordTooShort;
      case AuthPasswordValidationError.missingTypes:
        return l10n.authErrPasswordMissingTypes;
      case AuthPasswordValidationError.commonWeak:
        return l10n.authErrPasswordCommonWeak;
    }
  }

  /// Validates the new password field inline and updates error state.
  /// Returns the error message if invalid, null if valid.
  String? _validateNewPasswordField(String value, AppLocalizations l10n) {
    if (value.isEmpty) return null; // Don't show error for empty field on typing
    if (value.length < 8) return l10n.authErrPasswordTooShort;

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#\$%\^&*()_\+\-=\{\}\[\]:;,.<>/?`~|\\]').hasMatch(value);
    if (!(hasLetter && hasNumber && hasSpecial)) {
      return l10n.authErrPasswordMissingTypes;
    }
    return null;
  }

  /// Validates the confirm password field inline and updates error state.
  /// Returns the error message if passwords don't match, null if they match.
  String? _validateConfirmPasswordField(
    String newPassword,
    String confirmPassword,
    AppLocalizations l10n,
  ) {
    if (confirmPassword.isEmpty) return null; // Don't show error for empty field
    if (newPassword != confirmPassword) return l10n.authPasswordMismatchError;
    return null;
  }

  void _onNewPasswordChanged(String value) {
    final l10n = AppLocalizations.of(context)!;
    final confirmPw = _confirmPasswordController.text;
    setState(() {
      _newPasswordError = _validateNewPasswordField(value, l10n);
      // Re-validate confirm field when new password changes
      if (confirmPw.isNotEmpty) {
        _confirmPasswordError =
            _validateConfirmPasswordField(value, confirmPw, l10n);
      }
    });
  }

  void _onConfirmPasswordChanged(String value) {
    final l10n = AppLocalizations.of(context)!;
    final newPw = _newPasswordController.text;
    setState(() {
      _confirmPasswordError =
          _validateConfirmPasswordField(newPw, value, l10n);
    });
  }

  Future<void> _onCreatePasswordPressed() async {
    final l10n = AppLocalizations.of(context)!;
    // Use raw values without trimming - users may intentionally include
    // leading/trailing whitespace in passwords. Trimming would silently
    // alter user intent and cause password mismatch issues on login.
    final newPw = _newPasswordController.text;
    final confirmPw = _confirmPasswordController.text;
    final validation = validateNewPassword(newPw, confirmPw);

    if (!validation.isValid && validation.error != null) {
      if (!context.mounted) return;
      final message = _validationMessageFor(validation.error!, l10n);

      // Set inline errors based on validation failure type
      setState(() {
        switch (validation.error!) {
          case AuthPasswordValidationError.emptyFields:
            _newPasswordError = newPw.isEmpty ? l10n.authErrPasswordEmpty : null;
            _confirmPasswordError =
                confirmPw.isEmpty ? l10n.authErrPasswordEmpty : null;
          case AuthPasswordValidationError.mismatch:
            _newPasswordError = null;
            _confirmPasswordError = l10n.authPasswordMismatchError;
          case AuthPasswordValidationError.tooShort:
          case AuthPasswordValidationError.missingTypes:
          case AuthPasswordValidationError.commonWeak:
            _newPasswordError = message;
            _confirmPasswordError = null;
        }
      });

      // Also show snackbar for visibility
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }

    // Clear any inline errors before submission
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    await _runPasswordUpdate(newPw, l10n);
  }

  Future<void> _runPasswordUpdate(String newPassword, AppLocalizations l10n) async {
    setState(() => _isLoading = true);

    try {
      await supa.Supabase.instance.client.auth
          .updateUser(supa.UserAttributes(password: newPassword))
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;
      setState(() {
        _consecutiveFailures = 0;
        _lastFailureAt = null;
      });
      _backoffTicker?.cancel();
      context.goNamed(SuccessScreen.passwordSavedRouteName);
    } on supa.AuthException catch (error, stackTrace) {
      log.w(
        'auth_update_password_auth_exception',
        tag: 'create_new_password',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      _handlePasswordUpdateFailure(context, l10n);
    } on TimeoutException catch (error, stackTrace) {
      log.w(
        'auth_update_password_timeout',
        tag: 'create_new_password',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      _handlePasswordUpdateFailure(context, l10n);
    } catch (error, stackTrace) {
      log.e(
        'auth_update_password_unexpected',
        tag: 'create_new_password',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      _handlePasswordUpdateFailure(context, l10n);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _backoffTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final canSubmit = !_isLoading && !_isBackoffActive;

    // Figma: Title style - Playfair Display Bold, 24px
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: AuthTypography.titleFontSize,
      height: AuthTypography.titleLineHeight,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      key: const ValueKey('auth_create_password_screen'),
      resizeToAvoidBottomInset: true,
      body: AuthShell(
        background: const AuthLinearGradientBackground(),
        showBackButton: true,
        onBackPressed: () {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            // Fallback: navigate to sign-in or another appropriate route
            router.go(AuthSignInScreen.routeName);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gap after back button
            const SizedBox(height: AuthLayout.backButtonToTitle),

            // Title: "Neues Passwort erstellen"
            Text(
              key: const ValueKey('create_new_title'),
              l10n.authNewPasswordTitle,
              style: titleStyle,
            ),

            // Gap between title and inputs (Figma: 32px)
            const SizedBox(height: Spacing.authGlassCardVertical),

            // New password field with inline validation
            LoginPasswordField(
              key: const ValueKey('AuthPasswordField'),
              controller: _newPasswordController,
              errorText: _newPasswordError,
              obscure: _obscureNewPassword,
              onToggleObscure: () {
                setState(() => _obscureNewPassword = !_obscureNewPassword);
              },
              onChanged: _onNewPasswordChanged,
              hintText: l10n.authNewPasswordHint,
              textInputAction: TextInputAction.next,
            ),

            // Figma: Gap between inputs = 20px
            const SizedBox(height: AuthLayout.inputGap),

            // Confirm password field with inline mismatch validation
            LoginPasswordField(
              key: const ValueKey('AuthConfirmPasswordField'),
              controller: _confirmPasswordController,
              errorText: _confirmPasswordError,
              obscure: _obscureConfirmPassword,
              onToggleObscure: () {
                setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
              onChanged: _onConfirmPasswordChanged,
              hintText: l10n.authConfirmPasswordHint,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (canSubmit) _onCreatePasswordPressed();
              },
            ),

            // Gap before CTA (Figma: 40px)
            const SizedBox(height: AuthLayout.inputToCta),

            // CTA Button - Figma: h=56px
            SizedBox(
              width: double.infinity,
              height: Sizes.buttonHeightL,
              child: WelcomeButton(
                key: const ValueKey('create_new_cta_button'),
                onPressed: canSubmit ? _onCreatePasswordPressed : null,
                isLoading: _isLoading,
                label: l10n.authCreatePasswordCta,
              ),
            ),

            // Bottom padding
            const SizedBox(height: Spacing.l),
          ],
        ),
      ),
    );
  }
}
