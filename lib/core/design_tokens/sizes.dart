class Sizes {
  static const double radiusM = 12.0; // default medium radius
  static const double radiusL = 20.0; // cards / collage tiles
  static const double buttonHeight = 50.0; // Figma: Button H=50
  static const double touchTargetMin = 44.0; // iOS HIG / WCAG minimum tap target

  /// Icon size 24 px (Figma: Goal card icon)
  static const double iconM = 24.0;

  /// Figma: 40 px Kreisradius (z. B. Social-Button)
  static const double radiusXL = 40.0;

  /// Welcome Button Radius - Pill Shape (Figma: 40px)
  /// Semantically references radiusXL to avoid value duplication.
  static const double radiusWelcomeButton = radiusXL;

  /// Welcome Button Vertical Padding (Figma: 12px)
  static const double welcomeButtonPaddingVertical = 12.0;

  // ─── Auth Flow Specific (Figma Auth UI v2) ───

  /// Auth CTA Button Height (Figma: 56px)
  /// Note: Standard buttonHeight is 50px, Auth screens use 56px.
  static const double buttonHeightL = 56.0;

  /// Auth Glass Card Border Radius (Figma: 40px)
  static const double glassCardRadius = 40.0;

  Sizes._();
}
