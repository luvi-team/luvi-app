import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/shared/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/verify_footer.dart';
import 'package:luvi_app/features/auth/widgets/verify_header.dart';
import 'package:luvi_app/features/auth/widgets/verify_otp_section.dart';
import 'package:luvi_app/features/auth/widgets/verify_text_styles.dart';

enum VerificationScreenVariant { resetPassword, emailConfirmation }

class VerificationScreen extends StatefulWidget {
  static const String routeName = '/auth/verify';

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

    final titleStyle = verifyTitleStyle(context);
    final subtitleStyle = verifySubtitleStyle(context);
    final helperStyle = verifyHelperStyle(context, tokens);
    final resendStyle = verifyResendStyle(context);

    final isCodeComplete = _code.length == _codeLength;
    final otpScrollPad = EdgeInsets.only(
      bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
    );
    final inactiveBorderColor = colorScheme.primary.withValues(alpha: 0.75);
    final primaryColor = colorScheme.primary;
    final onSurfaceColor = colorScheme.onSurface;

    return Scaffold(
      key: const ValueKey('auth_verify_screen'),
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: AuthScreenShell(
        includeBottomReserve: false,
        children: [
          VerifyHeader(
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
          VerifyOtpSection(
            length: _codeLength,
            scrollPadding: otpScrollPad,
            inactiveBorderColor: inactiveBorderColor,
            focusedBorderColor: primaryColor,
            onChanged: (value) => setState(() => _code = value),
          ),
        ],
      ),
      bottomNavigationBar: AuthBottomCta(
        topPadding: AuthLayout.inputToCta,
        child: VerifyFooter(
          helper: copy.helper,
          resend: copy.resend,
          helperStyle: helperStyle,
          resendStyle: resendStyle,
          ctaEnabled: isCodeComplete,
          onConfirm: () {},
          onResend: () {},
        ),
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
}

class _VariantCopy {
  const _VariantCopy({required this.title, required this.subtitle});

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
