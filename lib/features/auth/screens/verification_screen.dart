import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/core/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/verification_code_input.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

enum VerificationScreenVariant {
  resetPassword,
  emailConfirmation,
}

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({
    super.key,
    this.variant = VerificationScreenVariant.resetPassword,
  });

  final VerificationScreenVariant variant;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const int _codeLength = 6;
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final colorScheme = theme.colorScheme;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    final copy = _VariantCopy.fromVariant(widget.variant);
    final topSpacing = topOffsetFromSafeArea(
      context,
      AuthLayout.figmaHeaderTop,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );

    final titleStyle = _titleStyle(context);
    final subtitleStyle = _subtitleStyle(context);
    final helperStyle = _helperStyle(context, tokens);
    final resendStyle = _resendStyle(context);

    final isCodeComplete = _code.length == _codeLength;
    final otpScrollPad = EdgeInsets.only(
      bottom: Sizes.buttonHeight + AuthLayout.gapSection + safeBottom,
    );
    final inactiveBorderColor = colorScheme.primary.withValues(alpha: 0.75);

    return Scaffold(
      key: const ValueKey('auth_verify_screen'),
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: _buildBody(
        context: context,
        colorScheme: colorScheme,
        topSpacing: topSpacing,
        copy: copy,
        titleStyle: titleStyle,
        subtitleStyle: subtitleStyle,
        otpScrollPad: otpScrollPad,
        inactiveBorderColor: inactiveBorderColor,
      ),
      bottomNavigationBar: _buildBottomNavigation(
        helperStyle: helperStyle,
        resendStyle: resendStyle,
        helper: copy.helper,
        resend: copy.resend,
        ctaEnabled: isCodeComplete,
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required ColorScheme colorScheme,
    required double topSpacing,
    required _VariantCopy copy,
    required TextStyle? titleStyle,
    required TextStyle? subtitleStyle,
    required EdgeInsets otpScrollPad,
    required Color inactiveBorderColor,
  }) {
    final primaryColor = colorScheme.primary;
    final onSurfaceColor = colorScheme.onSurface;

    return AuthScreenShell(
      includeBottomReserve: false,
      children: [
        _Header(
          topSpacing: topSpacing,
          title: copy.title,
          subtitle: copy.subtitle,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          onBackPressed: () => _onBackPressed(context),
          backButtonSize: AuthLayout.backButtonSize,
          backButtonInnerSize: AuthLayout.backButtonSize,
          backButtonBackgroundColor: primaryColor,
          backButtonIconColor: onSurfaceColor,
        ),
        _OtpSection(
          length: _codeLength,
          scrollPadding: otpScrollPad,
          inactiveBorderColor: inactiveBorderColor,
          focusedBorderColor: primaryColor,
          fieldSize: AuthLayout.otpFieldSize,
          gap: AuthLayout.otpGap,
          onChanged: _onCodeChanged,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation({
    required TextStyle? helperStyle,
    required TextStyle? resendStyle,
    required String helper,
    required String resend,
    required bool ctaEnabled,
  }) {
    return AuthBottomCta(
      topPadding: AuthLayout.inputToCta,
      child: _Footer(
        helper: helper,
        resend: resend,
        helperStyle: helperStyle,
        resendStyle: resendStyle,
        ctaEnabled: ctaEnabled,
        onConfirm: _onConfirm,
        onResend: _onResend,
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.goNamed('login');
    }
  }

  void _onCodeChanged(String value) {
    setState(() => _code = value);
  }

  void _onConfirm() {}

  void _onResend() {}
}

class _Header extends StatelessWidget {
  const _Header({
    required this.topSpacing,
    required this.title,
    required this.subtitle,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.onBackPressed,
    required this.backButtonSize,
    required this.backButtonInnerSize,
    required this.backButtonBackgroundColor,
    required this.backButtonIconColor,
  });

  final double topSpacing;
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final VoidCallback onBackPressed;
  final double backButtonSize;
  final double backButtonInnerSize;
  final Color backButtonBackgroundColor;
  final Color backButtonIconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topSpacing),
        BackButtonCircle(
          onPressed: onBackPressed,
          size: backButtonSize,
          innerSize: backButtonInnerSize,
          backgroundColor: backButtonBackgroundColor,
          iconColor: backButtonIconColor,
        ),
        const SizedBox(height: AuthLayout.gapSection),
        Text(title, style: titleStyle),
        const SizedBox(height: Spacing.xs),
        Text(subtitle, style: subtitleStyle),
        const SizedBox(height: AuthLayout.gapSection),
      ],
    );
  }
}

class _OtpSection extends StatelessWidget {
  const _OtpSection({
    required this.length,
    required this.scrollPadding,
    required this.inactiveBorderColor,
    required this.focusedBorderColor,
    required this.fieldSize,
    required this.gap,
    required this.onChanged,
  });

  final int length;
  final EdgeInsets scrollPadding;
  final Color inactiveBorderColor;
  final Color focusedBorderColor;
  final double fieldSize;
  final double gap;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: VerificationCodeInput(
        length: length,
        fieldSize: fieldSize,
        gap: gap,
        autofocus: true,
        inactiveBorderColor: inactiveBorderColor,
        focusedBorderColor: focusedBorderColor,
        scrollPadding: scrollPadding,
        onChanged: onChanged,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.helper,
    required this.resend,
    required this.helperStyle,
    required this.resendStyle,
    required this.ctaEnabled,
    required this.onConfirm,
    required this.onResend,
  });

  final String helper;
  final String resend;
  final TextStyle? helperStyle;
  final TextStyle? resendStyle;
  final bool ctaEnabled;
  final VoidCallback onConfirm;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: Sizes.buttonHeight,
          child: ElevatedButton(
            key: const ValueKey('verify_confirm_button'),
            onPressed: ctaEnabled ? onConfirm : null,
            child: const Text(AuthStrings.verifyCta),
          ),
        ),
        const SizedBox(height: AuthLayout.gapSection),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(helper, style: helperStyle),
            TextButton(
              onPressed: onResend,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(resend, style: resendStyle),
            ),
          ],
        ),
      ],
    );
  }
}

class _VariantCopy {
  const _VariantCopy({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  String get helper => AuthStrings.verifyHelper;
  String get resend => AuthStrings.verifyResend;

  factory _VariantCopy.fromVariant(VerificationScreenVariant variant) {
    switch (variant) {
      case VerificationScreenVariant.emailConfirmation:
        return const _VariantCopy(
          title: AuthStrings.verifyEmailTitle,
          subtitle: AuthStrings.verifyEmailSubtitle,
        );
      case VerificationScreenVariant.resetPassword:
        return const _VariantCopy(
          title: AuthStrings.verifyResetTitle,
          subtitle: AuthStrings.verifyResetSubtitle,
        );
    }
  }
}

TextStyle? _titleStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.headlineMedium?.copyWith(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w400,
    color: theme.colorScheme.onSurface,
  );
}

TextStyle? _subtitleStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.bodyMedium?.copyWith(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w400,
    color: theme.colorScheme.onSurface,
  );
}

TextStyle? _helperStyle(BuildContext context, DsTokens tokens) {
  final theme = Theme.of(context);
  return theme.textTheme.bodySmall?.copyWith(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    fontFamily: TypeScale.inter,
    color: tokens.grayscale500,
  );
}

TextStyle? _resendStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.bodySmall?.copyWith(
    fontSize: 17,
    height: 25 / 17,
    fontWeight: FontWeight.w500,
    color: theme.colorScheme.onSurface,
    decoration: TextDecoration.underline,
  );
}
