import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

class CreateNewPasswordScreen extends StatefulWidget {
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
  int? _activeFieldIndex;

  static const EdgeInsets _newPasswordScrollPadding = EdgeInsets.only(
    bottom: Sizes.buttonHeight + Spacing.l * 2,
  );

  static const EdgeInsets _confirmPasswordScrollPadding = EdgeInsets.only(
    bottom: Sizes.buttonHeight + Spacing.l,
  );

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus, int index) {
    if (hasFocus) {
      if (_activeFieldIndex != index) {
        setState(() => _activeFieldIndex = index);
      }
    } else if (_activeFieldIndex == index) {
      setState(() => _activeFieldIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;

    final backButtonTopSpacing = topOffsetFromSafeArea(
      context,
      AuthLayout.backButtonTop,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );

    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface,
    );

    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 17,
      height: 25 / 17,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );

    final confirmTextStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    final confirmHintStyle = theme.textTheme.bodySmall?.copyWith(
      color: tokens.grayscale500,
    );

    final mediaQuery = MediaQuery.of(context);
    final safeBottomInset = mediaQuery.padding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final keyboardOverlap = keyboardInset > safeBottomInset
        ? keyboardInset - safeBottomInset
        : 0.0;
    final isKeyboardVisible = keyboardOverlap > 0;
    const double ctaTopGapCollapsed = Spacing.s;
    const double ctaTopGapExpanded = AuthLayout.gapTitleToInputs;
    const double ctaTopGapConfirmField = AuthLayout.gapInputToCta;
    final double ctaTopPadding;
    if (!isKeyboardVisible) {
      ctaTopPadding = ctaTopGapExpanded;
    } else if (_activeFieldIndex == 0) {
      ctaTopPadding = ctaTopGapExpanded;
    } else if (_activeFieldIndex == 1) {
      ctaTopPadding = ctaTopGapConfirmField;
    } else {
      ctaTopPadding = ctaTopGapCollapsed;
    }

    return Scaffold(
      key: const ValueKey('auth_create_new_screen'),
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.colorScheme.surface,
      body: AuthScreenShell(
        children: [
          SizedBox(height: backButtonTopSpacing),
          BackButtonCircle(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/auth/login');
              }
            },
            size: 40,
            innerSize: 40,
            backgroundColor: theme.colorScheme.primary,
            iconColor: theme.colorScheme.onSurface,
            iconSize: 20,
          ),
          const SizedBox(height: AuthLayout.gapTitleToInputs),
          Text('Neues Passwort erstellen 💜', style: titleStyle),
          const SizedBox(height: Spacing.xs),
          Text('Mach es stark.', style: subtitleStyle),
          const SizedBox(height: AuthLayout.gapTitleToInputs),
          Focus(
            onFocusChange: (hasFocus) => _handleFocusChange(hasFocus, 0),
            child: LoginPasswordField(
              controller: _newPasswordController,
              errorText: null,
              onChanged: (_) {},
              obscure: _obscureNewPassword,
              onToggleObscure: () {
                setState(() => _obscureNewPassword = !_obscureNewPassword);
              },
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              scrollPadding: _newPasswordScrollPadding,
              hintText: 'Neues Passwort',
            ),
          ),
          const SizedBox(height: AuthLayout.gapInputToCta),
          Focus(
            onFocusChange: (hasFocus) => _handleFocusChange(hasFocus, 1),
            child: LoginPasswordField(
              controller: _confirmPasswordController,
              errorText: null,
              onChanged: (_) {},
              obscure: _obscureConfirmPassword,
              onToggleObscure: () {
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              scrollPadding: _confirmPasswordScrollPadding,
              hintText: 'Neues Passwort bestätigen',
              textStyle: confirmTextStyle,
              hintStyle: confirmHintStyle,
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardOverlap),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AuthLayout.horizontalPadding,
              ctaTopPadding,
              AuthLayout.horizontalPadding,
              Spacing.s,
            ),
            child: SizedBox(
              height: Sizes.buttonHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Speichern'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
