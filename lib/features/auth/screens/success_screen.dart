import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/core/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';

enum SuccessVariant {
  passwordSaved,
  forgotEmailSent,
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    this.variant = SuccessVariant.passwordSaved,
  });

  static const double _iconContainerSize = 104;
  static const double _iconSize = 48;
  final SuccessVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final horizontalPadding =
        AuthLayout.hPadding40 - AuthLayout.horizontalPadding;

    final topSpacing = topOffsetFromSafeArea(
      context,
      AuthLayout.iconTopSuccess,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );

    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface,
    );

    final subtitleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
      color: tokens.grayscale500,
    );

    final resolvedHorizontalPadding =
        horizontalPadding > 0 ? horizontalPadding : 0.0;

    late final String titleText;
    late final String subtitleText;
    switch (variant) {
      case SuccessVariant.passwordSaved:
        titleText = AuthStrings.successPwdTitle;
        subtitleText = AuthStrings.successPwdSubtitle;
        break;
      case SuccessVariant.forgotEmailSent:
        titleText = AuthStrings.successForgotTitle;
        subtitleText = AuthStrings.successForgotSubtitle;
        break;
    }

    return Scaffold(
      key: const ValueKey('auth_success_screen'),
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.colorScheme.surface,
      body: AuthScreenShell(
        includeBottomReserve: false,
        children: [
          SizedBox(height: topSpacing),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: resolvedHorizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SuccessIcon(
                    size: _iconContainerSize,
                    iconSize: _iconSize,
                    backgroundColor: tokens.successColor,
                    iconColor: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: Spacing.l),
                  Text(
                    titleText,
                    key: variant == SuccessVariant.forgotEmailSent
                        ? const ValueKey('success_title_forgot')
                        : null,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    subtitleText,
                    style: subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AuthLayout.ctaTopAfterCopy),
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
            padding: EdgeInsets.fromLTRB(
              AuthLayout.horizontalPadding,
              AuthLayout.ctaTopAfterCopy,
              AuthLayout.horizontalPadding,
              Spacing.s,
            ),
            child: SizedBox(
              width: double.infinity,
              height: Sizes.buttonHeight,
              child: ElevatedButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text(AuthStrings.successCta),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon({
    required this.size,
    required this.iconSize,
    required this.backgroundColor,
    required this.iconColor,
  });

  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check,
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}
