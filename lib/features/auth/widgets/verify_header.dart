import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class VerifyHeader extends StatelessWidget {
  const VerifyHeader({
    super.key,
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
          semanticLabel:
              (AppLocalizations.of(context)?.authBackSemantic) ?? 'Back',
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
