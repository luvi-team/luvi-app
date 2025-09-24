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
  static const double hPadding40 = 40; // Full-bleed horizontal padding (Figma)
  static const double figmaHeaderTop = 112; // Verification header top (Figma)
  static const double ctaLinkGapNormal =
      31; // Link gap when no validation error
  static const double ctaLinkGapError =
      29; // Link gap when validation error shown
  /// Reserve below form when keyboard shows:
  /// button (50) + double vertical spacing (2×24) + social block (~160) +
  /// signup link gap (≈31). safeBottom gets added at the call site.
  static const double socialBlockReserveApprox = 160;
  // TODO(ui): Measure actual social block height and replace approximation.
  static const double inlineCtaReserveLoginApprox =
      Sizes.buttonHeight + Spacing.l * 2 + socialBlockReserveApprox + Spacing.m;
}
