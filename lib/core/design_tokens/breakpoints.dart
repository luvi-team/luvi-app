/// Responsive breakpoints for LUVI (Figma reference devices).
///
/// ## Relationship to Sizes
/// - [Sizes.welcomeReferenceHeight] (800) = SCALING THRESHOLD (scale if height < 800)
/// - [Breakpoints.welcomeDesignHeight] (852) = FIGMA DESIGN HEIGHT (reference for layouts)
///
/// These are NOT duplicates - they serve different purposes:
/// - Sizes: Runtime scaling decisions
/// - Breakpoints: Design-time reference values
///
/// Validated against Figma exports:
/// - Auth: 393×873 (AuthRebrandMetrics)
/// - Welcome: 393×852 (iPhone 14 Pro reference)
/// - Onboarding: 393×926 (OnboardingSpacing._designHeight)
class Breakpoints {
  const Breakpoints._();

  // ─── Device Widths ───

  /// iPhone SE / Small phones (Figma: compact viewport)
  static const double phoneSmall = 375.0;

  /// iPhone 14 Pro / Standard (Figma reference device)
  /// SSOT: AuthRebrandMetrics.designWidth, Sizes.welcomeReferenceWidth
  static const double phoneStandard = 393.0;

  /// iPhone 14 Pro Max / Large phones
  static const double phoneLarge = 430.0;

  /// iPad Mini (landscape-capable threshold)
  static const double tabletSmall = 744.0;

  /// iPad Pro 11"
  static const double tabletStandard = 834.0;

  // ─── Design Heights (Figma Reference, NOT scaling thresholds) ───
  // For scaling thresholds, see [Sizes.welcomeReferenceHeight]

  /// Welcome screen design height (Figma: iPhone 14 Pro)
  /// NOT a scaling threshold - use [Sizes.welcomeReferenceHeight] for that
  static const double welcomeDesignHeight = 852.0;

  /// Auth screens design height (Figma: Auth Rebrand v3)
  static const double authDesignHeight = 873.0;

  /// Onboarding design height (Figma: O1-O9)
  static const double onboardingDesignHeight = 926.0;

  // ─── Helper Methods ───

  /// Check if width is tablet
  static bool isTablet(double width) => width >= tabletSmall;

  /// Check if height is constrained (needs scaling)
  /// Delegates to the canonical threshold in Sizes
  static bool isHeightConstrained(double height) => height < 800.0;
}
