import 'package:luvi_app/core/design_tokens/spacing.dart';

/// Shared spacing constants for the auth flows, derived from Figma specs.
class AuthLayout {
  AuthLayout._();

  static const double horizontalPadding = Spacing.l - Spacing.xs / 2; // 20
  static const double figmaSafeTop = 47;
  static const double backButtonTop = 59;
  static const double backButtonToTitle = 105;
  static const double titleToInput = 92;
  static const double inputToCta = 40;
  static const double ctaBottomInset = 92;
}
