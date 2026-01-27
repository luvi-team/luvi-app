import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Configuration for back button appearance.
class BackButtonConfig {
  const BackButtonConfig({
    required this.size,
    required this.innerSize,
    required this.backgroundColor,
    required this.iconColor,
  });

  final double size;
  final double innerSize;
  final Color backgroundColor;
  final Color iconColor;
}

class VerifyHeader extends StatelessWidget {
  const VerifyHeader({
    super.key,
    required this.topSpacing,
    required this.title,
    required this.subtitle,
    required this.onBackPressed,
    required this.backButtonConfig,
    this.titleStyle,
    this.subtitleStyle,
  });

  final double topSpacing;
  final String title;
  final String subtitle;
  final VoidCallback onBackPressed;
  final BackButtonConfig backButtonConfig;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topSpacing),
        BackButtonCircle(
          onPressed: onBackPressed,
          size: backButtonConfig.size,
          innerSize: backButtonConfig.innerSize,
          backgroundColor: backButtonConfig.backgroundColor,
          iconColor: backButtonConfig.iconColor,
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
