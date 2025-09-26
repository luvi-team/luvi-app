import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

TextStyle? verifyTitleStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.headlineMedium?.copyWith(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w400,
    color: theme.colorScheme.onSurface,
  );
}

TextStyle? verifySubtitleStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.bodyMedium?.copyWith(
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w400,
    color: theme.colorScheme.onSurface,
  );
}

TextStyle? verifyHelperStyle(BuildContext context, DsTokens tokens) {
  final theme = Theme.of(context);
  return theme.textTheme.bodySmall?.copyWith(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    fontFamily: TypeScale.inter,
    color: tokens.grayscale500,
  );
}

TextStyle? verifyResendStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.bodySmall?.copyWith(
    fontSize: 17,
    height: 25 / 17,
    fontWeight: FontWeight.w500,
    color: theme.colorScheme.onSurface,
    decoration: TextDecoration.underline,
  );
}
