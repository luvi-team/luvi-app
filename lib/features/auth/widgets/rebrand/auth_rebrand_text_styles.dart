import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';

/// Shared text styles for Auth Rebrand v3 screens.
///
/// Extracted from inline definitions to ensure DRY and consistency.
/// Uses design tokens from [AuthRebrandMetrics], [DsColors], [FontFamilies].
class AuthRebrandTextStyles {
  const AuthRebrandTextStyles._();

  /// Headline style for auth card titles.
  ///
  /// Playfair Display SemiBold 20px, line-height 1.2
  /// Used in: LoginScreen, ResetPasswordScreen, CreateNewPasswordScreen, SuccessScreen
  static const TextStyle headline = TextStyle(
    fontFamily: FontFamilies.playfairDisplay,
    fontSize: AuthRebrandMetrics.headlineFontSize,
    fontVariations: [FontVariations.semiBold],
    height: AuthRebrandMetrics.headlineLineHeightRatio,
    color: DsColors.authRebrandTextPrimary,
  );

  /// Shared base style for body text (subtitle, divider).
  /// Figtree Regular 17px, line-height 24/17
  static const TextStyle _bodyBase = TextStyle(
    fontFamily: FontFamilies.figtree,
    fontSize: AuthRebrandMetrics.bodyFontSize,
    fontVariations: [FontVariations.regular],
    height: AuthRebrandMetrics.bodyLineHeightRatio,
    color: DsColors.authRebrandTextPrimary,
  );

  /// Subtitle style for auth success/confirmation screens.
  /// Used in: SuccessScreen
  static const TextStyle subtitle = _bodyBase;

  /// Divider text style (e.g., "or", "oder").
  /// Used in: AuthOAuthSheetContent
  ///
  /// Note: Intentionally separate from [subtitle] to allow independent
  /// style evolution for different UI contexts (dividers vs subtitles).
  static const TextStyle divider = _bodyBase;
}
