import 'package:flutter/material.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart' as auth_strings;

class CreateNewHeader extends StatelessWidget {
  const CreateNewHeader({
    super.key,
    required this.headerKey,
    required this.topGap,
  });

  final GlobalKey headerKey;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

    return Column(
      key: headerKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topGap),
        Text(
          // Using canonical authNewPasswordTitle (without emoji) per Auth UI v2
          AppLocalizations.of(context)?.authNewPasswordTitle ??
              auth_strings.AuthStrings.createNewTitle,
          key: const ValueKey(TestKeys.createNewTitle),
          style: titleStyle,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          (AppLocalizations.of(context)?.authCreateNewSubtitle ??
              auth_strings.AuthStrings.createNewSubtitle),
          key: const ValueKey(TestKeys.createNewSubtitle),
          style: subtitleStyle,
        ),
      ],
    );
  }
}
