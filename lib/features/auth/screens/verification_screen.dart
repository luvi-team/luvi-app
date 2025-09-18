import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/utils/layout_utils.dart';
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

    final copy = _VariantCopy.fromVariant(widget.variant);
    final topSpacing = topOffsetFromSafeArea(
      context,
      AuthLayout.figmaHeaderTop,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );

    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface,
    );
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 20,
      height: 24 / 20,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface,
    );
    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w400,
      fontFamily: TypeScale.inter,
      color: tokens.grayscale500,
    );
    final resendStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 17,
      height: 25 / 17,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
      decoration: TextDecoration.underline,
    );

    final isCodeComplete = _code.length == _codeLength;

    return Scaffold(
      key: const ValueKey('auth_verify_screen'),
      backgroundColor: theme.colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: AuthScreenShell(
        children: [
          SizedBox(height: topSpacing),
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
          ),
          const SizedBox(height: AuthLayout.gapSection),
          Text(copy.title, style: titleStyle),
          const SizedBox(height: Spacing.xs),
          Text(copy.subtitle, style: subtitleStyle),
          const SizedBox(height: AuthLayout.gapSection),
          Center(
            child: VerificationCodeInput(
              length: _codeLength,
              fieldSize: 51,
              gap: 16,
              autofocus: true,
              inactiveBorderColor:
                  theme.colorScheme.primary.withValues(alpha: 0.75),
              focusedBorderColor: theme.colorScheme.primary,
              onChanged: (value) => setState(() => _code = value),
            ),
          ),
          const SizedBox(height: AuthLayout.gapSection),
        ],
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AuthLayout.horizontalPadding,
              AuthLayout.gapSection,
              AuthLayout.horizontalPadding,
              Spacing.s,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: Sizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: isCodeComplete ? () {} : null,
                    child: const Text('Bestätigen'),
                  ),
                ),
                const SizedBox(height: AuthLayout.gapSection),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(copy.helper, style: helperStyle),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(copy.resend, style: resendStyle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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

  String get helper => 'Nichts angekommen?';
  String get resend => 'Erneut senden';

  factory _VariantCopy.fromVariant(VerificationScreenVariant variant) {
    switch (variant) {
      case VerificationScreenVariant.emailConfirmation:
        return const _VariantCopy(
          title: 'E-Mail bestätigen 💜',
          subtitle: 'Code eingeben',
        );
      case VerificationScreenVariant.resetPassword:
        return const _VariantCopy(
          title: 'Code eingeben 💜',
          subtitle: 'Gerade an deine E-Mail gesendet.',
        );
    }
  }
}
