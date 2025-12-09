import 'dart:async' show TimeoutException, Timer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
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

  Future<void> _onCreatePasswordPressed() async {
    final l10n = AppLocalizations.of(context)!;
    final newPw = _newPasswordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();
    final validation = validateNewPassword(newPw, confirmPw);

    if (!validation.isValid && validation.error != null) {
      if (!context.mounted) return;
      final message = _validationMessageFor(validation.error!, l10n);
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }

    await _runPasswordUpdate(newPw);
  }

  Future<void> _runPasswordUpdate(String newPassword) async {
    final l10n = AppLocalizations.of(context)!;
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
      fontSize: 24,
      height: 32 / 24,
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

            // Gap between title and inputs
            const SizedBox(height: Spacing.l + Spacing.xs), // 32px

            // New password field
            LoginPasswordField(
              key: const ValueKey('AuthPasswordField'),
              controller: _newPasswordController,
              errorText: null,
              obscure: _obscureNewPassword,
              onToggleObscure: () {
                setState(() => _obscureNewPassword = !_obscureNewPassword);
              },
              onChanged: (_) {},
              hintText: l10n.authNewPasswordHint,
              textInputAction: TextInputAction.next,
            ),

            // Figma: Gap between inputs = 20px
            const SizedBox(height: Spacing.goalCardVertical),

            // Confirm password field
            LoginPasswordField(
              key: const ValueKey('AuthConfirmPasswordField'),
              controller: _confirmPasswordController,
              errorText: null,
              obscure: _obscureConfirmPassword,
              onToggleObscure: () {
                setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
              onChanged: (_) {},
              hintText: l10n.authConfirmPasswordHint,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (canSubmit) _onCreatePasswordPressed();
              },
            ),

            // Gap before CTA
            const SizedBox(height: Spacing.l + Spacing.m), // 40px

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
