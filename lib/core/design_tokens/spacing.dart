class Spacing {
  static const double l = 24.0; // large (e.g., section gaps)
  static const double m = 16.0; // medium (e.g., between CTAs)
  static const double s = 12.0; // small (title -> subtitle)
  static const double recommendationCardPadding =
      14.0; // aligns with DASHBOARD_spec card padding
  static const double heroInfoCardPadding =
      14.0; // medium-small padding for hero info card rail
  static const double xs = 8.0; // extra small (breathing space)
  static const double goalCardVertical =
      20.0; // dedicated padding for goal cards
  static const double goalCardIconGap =
      20.0; // spacing between icon and text in goal cards

  /// Welcome content bottom padding (Figma: 52px from bottom edge)
  static const double welcomeBottomPadding = 52.0;

  /// Gap between subtitle and CTA on welcome screens (W5)
  static const double welcomeCtaGap = 40.0;

  /// Auth SignIn glass card vertical padding (Figma: 32px = l + xs)
  static const double authGlassCardVertical = l + xs;

  Spacing._();
}
