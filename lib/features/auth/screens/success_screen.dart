import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/shared/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';

enum SuccessVariant { passwordSaved, forgotEmailSent }

class SuccessScreen extends StatelessWidget {
  static const String passwordSavedRoutePath = '/auth/password/success';
  static const String passwordSavedRouteName = 'password_saved';
  static const String forgotEmailSentRoutePath = '/auth/forgot/sent';
  static const String forgotEmailSentRouteName = 'forgot_sent';

  const SuccessScreen({super.key, this.variant = SuccessVariant.passwordSaved});

  final SuccessVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final horizontalPadding =
        AuthLayout.hPadding40 - AuthLayout.horizontalPadding;

    final topSpacing = topOffsetFromSafeArea(
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

    final resolvedHorizontalPadding = horizontalPadding > 0
        ? horizontalPadding
        : 0.0;

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
              child: _SuccessCopy(
                variant: variant,
                titleText: titleText,
                subtitleText: subtitleText,
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                iconContainerSize: AuthLayout.successIconCircle,
                iconSize: AuthLayout.successIconInner,
                iconBackgroundColor: tokens.successColor,
                iconColor: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AuthBottomCta(
        child: _BottomCta(
          onPressed: () => context.go(HeuteScreen.routeName),
          isLoading: false,
        ),
      ),
    );
  }
}

class _SuccessCopy extends StatelessWidget {
  const _SuccessCopy({
    required this.variant,
    required this.titleText,
    required this.subtitleText,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.iconContainerSize,
    required this.iconSize,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final SuccessVariant variant;
  final String titleText;
  final String subtitleText;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double iconContainerSize;
  final double iconSize;
  final Color iconBackgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SuccessIcon(
          size: iconContainerSize,
          iconSize: iconSize,
          backgroundColor: iconBackgroundColor,
          iconColor: iconColor,
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
        Text(subtitleText, style: subtitleStyle, textAlign: TextAlign.center),
      ],
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.onPressed, required this.isLoading});

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        key: const ValueKey('success_cta_button'),
        onPressed: onPressed,
        child: Text(AuthStrings.successCta),
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
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(Icons.check, size: iconSize, color: iconColor),
    );
  }
}
