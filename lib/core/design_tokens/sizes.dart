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
  static const double glassCardRadius = radiusXL;

  /// Auth Glass Card Blur Sigma (Figma: blur 10)
  static const double glassBlurSigma = 10.0;

  /// Auth Glass Card Border Width (Figma: 1px)
  static const double glassCardBorderWidth = 1.0;

  /// Auth Outline Button Height (Figma: 58px for E-Mail/Google buttons)
  static const double buttonHeightOutline = 58.0;

  /// Auth Outline Button Horizontal Padding (Figma: 24px)
  static const double buttonPaddingHorizontal = 24.0;

  // ─── Auth Typography (Figma Auth UI v2) ───

  /// Auth screen title fontSize (Figma: Playfair Display Bold 24px)
  static const double authTitleFontSize = 24.0;

  /// Auth screen title lineHeight ratio (Figma: 32/24)
  static const double authTitleLineHeight = 32.0 / 24.0;

  /// Auth screen subtitle fontSize (Figma: Figtree Regular 16px)
  static const double authSubtitleFontSize = 16.0;

  /// Auth screen subtitle lineHeight ratio (Figma: 24/16)
  static const double authSubtitleLineHeight = 24.0 / 16.0;

  /// Auth forgot/link text fontSize (Figma: Figtree Bold 20px)
  static const double authLinkFontSize = 20.0;

  /// Auth link lineHeight ratio (Figma: 24/20)
  static const double authLinkLineHeight = 24.0 / 20.0;

  // ─── Loading Indicator (Button spinner) ───

  /// Loading indicator size inside buttons (Figma: 20px)
  static const double loadingIndicatorSize = 20.0;

  /// Loading indicator stroke width (Figma: 2px)
  static const double loadingIndicatorStroke = 2.0;

  Sizes._();
}
