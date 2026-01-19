import 'dart:async' show TimeoutException;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/utils/auth_navigation_helpers.dart';
import 'package:luvi_app/features/auth/utils/create_new_password_rules.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_scaffold.dart';
import 'package:luvi_app/features/auth/widgets/password_visibility_toggle_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_field.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_styles.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// Create new password screen with Auth Rebrand v3 design.
///
/// Features:
/// - Rainbow background with arcs and stripes
/// - Content card with headline
/// - TWO password fields: new password + confirm password
/// - Pink CTA button
/// - Password validation (length + blocklist check)
///
/// Route: /auth/password/new
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

  String? _newPasswordError;
  String? _confirmPasswordError;

  void _showPasswordUpdateError(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.authPasswordUpdateError)),
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
      case AuthPasswordValidationError.commonWeak:
        return l10n.authErrPasswordCommonWeak;
    }
  }

  String? _validateNewPasswordField(String value, AppLocalizations l10n) {
    if (value.isEmpty) return null;
    if (value.length < 8) return l10n.authErrPasswordTooShort;
    return null;
  }

  String? _validateConfirmPasswordField(
    String newPassword,
    String confirmPassword,
    AppLocalizations l10n,
  ) {
    if (confirmPassword.isEmpty) return null;
    if (newPassword != confirmPassword) return l10n.authPasswordMismatchError;
    return null;
  }

  void _onNewPasswordChanged(String value) {
    final l10n = AppLocalizations.of(context)!;
    final confirmPw = _confirmPasswordController.text;
    setState(() {
      _newPasswordError = _validateNewPasswordField(value, l10n);
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

  void _toggleObscureNewPassword() {
    setState(() => _obscureNewPassword = !_obscureNewPassword);
  }

  void _toggleObscureConfirmPassword() {
    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  }

  Future<void> _onCreatePasswordPressed() async {
    final l10n = AppLocalizations.of(context)!;
    final newPw = _newPasswordController.text;
    final confirmPw = _confirmPasswordController.text;
    final validation = validateNewPassword(newPw, confirmPw);

    if (!validation.isValid && validation.error != null) {
      if (!context.mounted) return;
      final message = _validationMessageFor(validation.error!, l10n);

      setState(() {
        switch (validation.error!) {
          case AuthPasswordValidationError.emptyFields:
            _newPasswordError = newPw.isEmpty ? l10n.authErrPasswordInvalid : null;
            _confirmPasswordError =
                confirmPw.isEmpty ? l10n.authErrPasswordInvalid : null;
          case AuthPasswordValidationError.mismatch:
            _newPasswordError = null;
            _confirmPasswordError = l10n.authPasswordMismatchError;
          case AuthPasswordValidationError.tooShort:
          case AuthPasswordValidationError.commonWeak:
            _newPasswordError = message;
            _confirmPasswordError = null;
        }
      });

      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }

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
        _newPasswordError = null;
        _confirmPasswordError = null;
      });
      context.goNamed(SuccessScreen.passwordSavedRouteName);
    } on supa.AuthException catch (error, stackTrace) {
      log.w(
        'auth_update_password_auth_exception',
        tag: 'create_new_password',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      _showPasswordUpdateError(context, l10n);
    } on TimeoutException catch (error, stackTrace) {
      log.w(
        'auth_update_password_timeout',
        tag: 'create_new_password',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      _showPasswordUpdateError(context, l10n);
    } catch (error, stackTrace) {
      log.e(
        'auth_update_password_unexpected',
        tag: 'create_new_password',
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      if (!mounted) return;
      _showPasswordUpdateError(context, l10n);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSubmit = !_isLoading;

    return AuthRebrandScaffold(
      scaffoldKey: const ValueKey('auth_create_password_screen'),
      compactKeyboard: true, // Fewer fields = compact padding
      onBack: () => handleAuthBackNavigation(context),
      child: _buildFormCard(l10n: l10n, canSubmit: canSubmit),
    );
  }

  Widget _buildFormCard({
    required AppLocalizations l10n,
    required bool canSubmit,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AuthContentCard(
          width: AuthRebrandMetrics.cardWidthForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.authNewPasswordTitle,
                key: const ValueKey('create_new_title'),
                style: AuthRebrandTextStyles.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.l),
              AuthRebrandTextField(
                key: const ValueKey('AuthPasswordField'),
                controller: _newPasswordController,
                hintText: l10n.authNewPasswordHint,
                errorText: _newPasswordError,
                hasError: _newPasswordError != null,
                obscureText: _obscureNewPassword,
                textInputAction: TextInputAction.next,
                onChanged: _onNewPasswordChanged,
                suffixIcon: PasswordVisibilityToggleButton(
                  obscured: _obscureNewPassword,
                  onPressed: _toggleObscureNewPassword,
                  color: DsColors.grayscale500,
                  size: AuthRebrandMetrics.passwordToggleIconSize,
                ),
              ),
              const SizedBox(height: AuthRebrandMetrics.cardInputGap),
              AuthRebrandTextField(
                key: const ValueKey('AuthConfirmPasswordField'),
                controller: _confirmPasswordController,
                hintText: l10n.authNewPasswordConfirmHint,
                errorText: _confirmPasswordError,
                hasError: _confirmPasswordError != null,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onChanged: _onConfirmPasswordChanged,
                onSubmitted: (_) {
                  if (canSubmit) _onCreatePasswordPressed();
                },
                suffixIcon: PasswordVisibilityToggleButton(
                  obscured: _obscureConfirmPassword,
                  onPressed: _toggleObscureConfirmPassword,
                  color: DsColors.grayscale500,
                  size: AuthRebrandMetrics.passwordToggleIconSize,
                ),
              ),
              const SizedBox(height: Spacing.l),
              AuthPrimaryButton(
                key: const ValueKey('create_new_cta_button'),
                label: l10n.authSavePasswordCta,
                onPressed: canSubmit ? _onCreatePasswordPressed : null,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
