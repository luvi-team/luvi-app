import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/features/auth/screens/success_screen.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/shared/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/create_new/create_new_header.dart';
import 'package:luvi_app/features/auth/widgets/create_new/create_new_form.dart';
import 'package:luvi_app/features/auth/widgets/create_new/back_button_overlay.dart';
import 'package:luvi_app/features/auth/utils/field_auto_scroller.dart';
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

  // Common weak password patterns extracted for reuse and testability
  static final List<RegExp> _commonWeakPatterns = <RegExp>[
    RegExp(r'^password\d*$', caseSensitive: false),
    RegExp(r'^123456(78|789)?$'),
    RegExp(r'^qwerty\d*$', caseSensitive: false),
    RegExp(r'^letmein\d*$', caseSensitive: false),
    // Expanded weak/common patterns (conservative MVP set)
    RegExp(r'^abc123$', caseSensitive: false),
    RegExp(r'^admin\d*$', caseSensitive: false),
    RegExp(r'^welcome\d*$', caseSensitive: false),
    RegExp(r'^monkey\d*$', caseSensitive: false),
    RegExp(r'^dragon\d*$', caseSensitive: false),
    RegExp(r'^zxcvbn\d*$', caseSensitive: false),
    RegExp(r'^asdfgh\d*$', caseSensitive: false),
    RegExp(r'^abcdef$', caseSensitive: false),
    RegExp(r'^654321$'),
  ];

  static const double _backButtonSize = AuthLayout.backButtonSize;
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
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
            onPressed: _isLoading
                ? null
                : () async {
                    final newPw = _newPasswordController.text.trim();
                    final confirmPw = _confirmPasswordController.text.trim();

                    // Basic empty check
                    if (newPw.isEmpty || confirmPw.isEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.authErrPasswordInvalid)),
                      );
                      return;
                    }

                    // Confirm match
                    if (newPw != confirmPw) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.authPasswordMismatchError),
                        ),
                      );
                      return;
                    }

                    // Strength validation
                    final pw = newPw;
                    final hasMinLen = pw.length >= 8;
                    final hasLetter = RegExp(r"[A-Za-z]").hasMatch(pw);
                    final hasNumber = RegExp(r"\d").hasMatch(pw);
                    final hasSpecial = RegExp(
                      r'[!@#\$%\^&*()_\+\-=\{\}\[\]:;,.<>/?`~|\\]',
                    ).hasMatch(pw);
                    final isCommonWeak =
                        _commonWeakPatterns.any((r) => r.hasMatch(pw.trim()));

                    String? validationError;
                    if (!hasMinLen) {
                      validationError = l10n.authErrPasswordTooShort;
                    } else if (!(hasLetter && hasNumber && hasSpecial)) {
                      validationError = l10n.authErrPasswordMissingTypes;
                    } else if (isCommonWeak) {
                      validationError = l10n.authErrPasswordCommonWeak;
                    }

                    if (validationError != null) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(validationError)),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    try {
                      await supa.Supabase.instance.client.auth.updateUser(
                        supa.UserAttributes(password: newPw),
                      );
                      if (!context.mounted) return;
                      context.goNamed(
                        SuccessScreen.passwordSuccessRouteName,
                      );
                    } catch (error) {
                      // Log only error type to avoid leaking PII.
                      debugPrint('[auth.updatePassword] ${error.runtimeType}');
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.authPasswordUpdateError),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
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
              context.goNamed('login');
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
