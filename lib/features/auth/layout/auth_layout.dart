import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';

/// Shared spacing constants for the auth flows, derived from Figma specs.
class AuthLayout {
  AuthLayout._();

  static const double horizontalPadding = Spacing.l - Spacing.xs / 2; // 20
  static const double figmaSafeTop = 47;
  static const double backButtonTop = 59;
  static const double backButtonTopInset = backButtonTop - figmaSafeTop;
  static const double backButtonToTitle = 105;
  static const double titleToInput = 92;
  static const double inputToCta = 40;
  static const double ctaBottomInset = 92;
  static const double gapSection = 63; // Verification section grid (Figma)
  static const double gapTitleToInputs =
      74; // CreateNew title -> inputs (Figma)
  static const double gapInputToCta =
      inputToCta; // MVP: tighter gap for keyboard
  static const double ctaTopAfterCopy = 32; // Subtitle -> CTA spacing (Figma)
  static const double iconTopSuccess = 325; // Success icon top offset (Figma)
  static const double successIconCircle = 104.0;
  static const double successIconInner = 48.0;
  static const double hPadding40 = 40; // Full-bleed horizontal padding (Figma)
  static const double figmaHeaderTop = 112; // Verification header top (Figma)
  static const double ctaLinkGapNormal =
      31; // Link gap when no validation error
  static const double ctaLinkGapError =
      29; // Link gap when validation error shown
  /// Reserve below form when keyboard shows:
  /// button (50) + double vertical spacing (2×24) + social block (~180) +
  /// signup link gap (≈31). safeBottom gets added at the call site.
  // TODO(ui): Replace magic number with dynamic measurement (GlobalKey + RenderBox).
  // Current value (180dp) has ~7dp buffer for vertical layout (173dp actual).
  // Risk: Breaks with textScaleFactor > 1.04, long translations, or package updates.
  static const double socialBlockReserveApprox = 180;
  static const double inlineCtaReserveLoginApprox =
      Sizes.buttonHeight + Spacing.l * 2 + socialBlockReserveApprox + Spacing.m;
  static const double backButtonSize = 40;
  static const double backIconSize = 20.0;
  static const double otpFieldSize = 51;
  static const double otpGap = 16;
  static const double otpBorderRadius = 8;
}
