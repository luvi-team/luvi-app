import 'dart:async' show TimeoutException, Timer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/features/auth/utils/create_new_password_rules.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_back_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_content_card.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_primary_button.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rainbow_background.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_text_field.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// Create new password screen with Auth Rebrand v3 design.
///
/// Features:
/// - Rainbow background with arcs and stripes
/// - Content card with headline
/// - TWO password fields: new password + confirm password
/// - Pink CTA button
/// - Password validation with backoff protection
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
    // Tick every second to update countdown UI, auto-cancel when done
    _backoffTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !_isBackoffActive) {
        t.cancel();
        return;
      }
      setState(() {}); // Trigger rebuild to update countdown
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
        _consecutiveFailures = 0;
        _lastFailureAt = null;
        _newPasswordError = null;
        _confirmPasswordError = null;
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
    final canSubmit = !_isLoading && !_isBackoffActive;

    return Scaffold(
      key: const ValueKey('auth_create_password_screen'),
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
                        key: const ValueKey('backButtonCircle'),
                        onPressed: () {
                          final router = GoRouter.of(context);
                          if (router.canPop()) {
                            router.pop();
                          } else {
                            router.go(AuthSignInScreen.routeName);
                          }
                        },
                        semanticsLabel: l10n.authBackSemantic,
                      ),
                    ),
                  ),

                  const SizedBox(height: AuthRebrandMetrics.contentTopGap),

                  // Content card (SSOT: form screens use 364px width)
                  AuthContentCard(
                    width: AuthRebrandMetrics.cardWidthForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Headline
                        Text(
                          l10n.authNewPasswordTitle,
                          key: const ValueKey('create_new_title'),
                          style: const TextStyle(
                            fontFamily: FontFamilies.playfairDisplay,
                            fontSize: AuthRebrandMetrics.headlineFontSize,
                            fontWeight: FontWeight.w600,
                            height: AuthRebrandMetrics.headlineLineHeight,
                            color: DsColors.authRebrandTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: Spacing.l),

                        // New password field
                        AuthRebrandTextField(
                          key: const ValueKey('AuthPasswordField'),
                          controller: _newPasswordController,
                          hintText: l10n.authNewPasswordHint,
                          errorText: _newPasswordError,
                          hasError: _newPasswordError != null,
                          obscureText: _obscureNewPassword,
                          textInputAction: TextInputAction.next,
                          onChanged: _onNewPasswordChanged,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: DsColors.grayscale500,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscureNewPassword = !_obscureNewPassword);
                            },
                          ),
                        ),

                        const SizedBox(height: AuthRebrandMetrics.cardInputGap),

                        // Confirm password field
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: DsColors.grayscale500,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                        ),

                        const SizedBox(height: Spacing.l),

                        // CTA button (SSOT: "Speichern")
                        AuthPrimaryButton(
                          key: const ValueKey('create_new_cta_button'),
                          label: l10n.authSavePasswordCta,
                          onPressed: canSubmit ? _onCreatePasswordPressed : null,
                          isLoading: _isLoading,
                        ),
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
}
