import 'package:flutter/material.dart';
import 'dart:async' show TimeoutException, Timer;
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/core/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/create_new/create_new_header.dart';
import 'package:luvi_app/features/auth/widgets/create_new/create_new_form.dart';
import 'package:luvi_app/features/auth/widgets/create_new/back_button_overlay.dart';
import 'package:luvi_app/features/auth/utils/field_auto_scroller.dart';
import 'package:luvi_app/features/auth/utils/create_new_password_rules.dart';
import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

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
  final FieldAutoScroller _autoScroller = FieldAutoScroller(ScrollController());

  final _headerKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  final _confirmFieldKey = GlobalKey();

  ScrollController get _scrollController => _autoScroller.controller;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Simple client-side rate limiting with exponential backoff
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

  // Consolidated failure handling for password update attempts.
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

  static const double _backButtonSize = AuthLayout.backButtonSize;

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

  Future<void> _onCreatePasswordPressed(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final newPw = _newPasswordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();
    final validation = validateNewPassword(newPw, confirmPw);
    if (!validation.isValid && validation.error != null) {
      if (!context.mounted) return;
      final message = _validationMessageFor(validation.error!, l10n);
      if (message != null) {
        _showValidationError(context, message);
      }
      return;
    }

    await _runPasswordUpdate(context, l10n, newPw);
  }

  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _runPasswordUpdate(
    BuildContext context,
    AppLocalizations l10n,
    String newPassword,
  ) async {
    setState(() => _isLoading = true);
    try {
      await supa.Supabase.instance.client.auth
          .updateUser(
        supa.UserAttributes(password: newPassword),
      )
          .timeout(
        const Duration(seconds: 30),
      );
      if (!context.mounted) return;
      setState(() {
        _consecutiveFailures = 0;
        _lastFailureAt = null;
      });
      _backoffTicker?.cancel();
      context.goNamed(
        SuccessScreen.passwordSavedRouteName,
      );
    } on supa.AuthException catch (error) {
      debugPrint('[auth.updatePassword] ${error.runtimeType}');
      if (!context.mounted) return;
      _handlePasswordUpdateFailure(context, l10n);
    } on TimeoutException catch (error) {
      debugPrint('[auth.updatePassword] ${error.runtimeType}');
      if (!context.mounted) return;
      _handlePasswordUpdateFailure(context, l10n);
    } catch (error) {
      debugPrint('[auth.updatePassword] ${error.runtimeType}');
      if (!context.mounted) return;
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
    _scrollController.dispose();
    _backoffTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>();
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context) ??
        lookupAppLocalizations(AppLocalizations.supportedLocales.first);

    final backButtonTopSpacing = topOffsetFromSafeArea(
      AuthLayout.backButtonTop,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );
    final headerTopGap =
        backButtonTopSpacing +
        _backButtonSize +
        AuthLayout.gapTitleToInputs / 2;
    final confirmTextStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final confirmHintColor =
        tokens?.grayscale500 ??
        theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final confirmHintStyle = theme.textTheme.bodySmall?.copyWith(
      color: confirmHintColor,
    );

    final safeBottom = mediaQuery.padding.bottom;
    final fieldScrollPadding = EdgeInsets.only(
      bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: AuthBottomCta(
        topPadding: AuthLayout.inputToCta,
        child: SizedBox(
          height: Sizes.buttonHeight,
          width: double.infinity,
            child: ElevatedButton(
            key: const ValueKey('create_new_cta_button'),
            onPressed: (_isLoading || _isBackoffActive)
                ? null
                : () => _onCreatePasswordPressed(context, l10n),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.authCreateNewCta),
          ),
        ),
      ),
      body: _CreateNewBody(
        scrollController: _scrollController,
        headerKey: _headerKey,
        headerTopGap: headerTopGap,
        autoScroller: _autoScroller,
        newPasswordController: _newPasswordController,
        confirmPasswordController: _confirmPasswordController,
        passwordFieldKey: _passwordFieldKey,
        confirmFieldKey: _confirmFieldKey,
        isNewPasswordObscured: _obscureNewPassword,
        isConfirmPasswordObscured: _obscureConfirmPassword,
        onToggleNewPassword: () {
          setState(() => _obscureNewPassword = !_obscureNewPassword);
        },
        onToggleConfirmPassword: () {
          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
        },
        fieldScrollPadding: fieldScrollPadding,
        confirmTextStyle: confirmTextStyle,
        confirmHintStyle: confirmHintStyle,
        safeTop: mediaQuery.padding.top,
        backgroundColor: theme.colorScheme.primary,
        iconColor: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _CreateNewBody extends StatelessWidget {
  const _CreateNewBody({
    required this.scrollController,
    required this.headerKey,
    required this.headerTopGap,
    required this.autoScroller,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.passwordFieldKey,
    required this.confirmFieldKey,
    required this.isNewPasswordObscured,
    required this.isConfirmPasswordObscured,
    required this.onToggleNewPassword,
    required this.onToggleConfirmPassword,
    required this.fieldScrollPadding,
    required this.confirmTextStyle,
    required this.confirmHintStyle,
    required this.safeTop,
    required this.backgroundColor,
    required this.iconColor,
  });

  final ScrollController scrollController;
  final GlobalKey headerKey;
  final double headerTopGap;
  final FieldAutoScroller autoScroller;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey passwordFieldKey;
  final GlobalKey confirmFieldKey;
  final bool isNewPasswordObscured;
  final bool isConfirmPasswordObscured;
  final VoidCallback onToggleNewPassword;
  final VoidCallback onToggleConfirmPassword;
  final EdgeInsets fieldScrollPadding;
  final TextStyle? confirmTextStyle;
  final TextStyle? confirmHintStyle;
  final double safeTop;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AuthScreenShell(
          includeBottomReserve: false,
          controller: scrollController,
          children: [
            CreateNewHeader(headerKey: headerKey, topGap: headerTopGap),
            const SizedBox(height: AuthLayout.gapTitleToInputs),
            CreateNewForm(
              autoScroller: autoScroller,
              newPasswordController: newPasswordController,
              confirmPasswordController: confirmPasswordController,
              passwordFieldKey: passwordFieldKey,
              confirmFieldKey: confirmFieldKey,
              isNewPasswordObscured: isNewPasswordObscured,
              isConfirmPasswordObscured: isConfirmPasswordObscured,
              onToggleNewPassword: onToggleNewPassword,
              onToggleConfirmPassword: onToggleConfirmPassword,
              fieldScrollPadding: fieldScrollPadding,
              confirmTextStyle: confirmTextStyle,
              confirmHintStyle: confirmHintStyle,
            ),
          ],
        ),
        CreateNewBackButtonOverlay(
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              context.goNamed(RouteNames.login);
            }
          },
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          size: _CreateNewPasswordScreenState._backButtonSize,
          iconSize: AuthLayout.backIconSize,
        ),
      ],
    );
  }
}
