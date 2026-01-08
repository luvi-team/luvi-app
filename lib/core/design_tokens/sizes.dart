class Sizes {
  static const double radiusXS = 6.0; // extra small radius (edge case elements)
  static const double radiusS = 8.0; // small radius (inner elements)
  static const double radiusM = 12.0; // default medium radius
  static const double radiusL = 20.0; // cards / collage tiles
  static const double radiusCard = 16.0; // content card radius (Figma: 16px)

  /// Explicit 16px radius token for Figma v3 onboarding elements
  /// Alias of radiusCard for semantic clarity in onboarding context
  static const double radius16 = radiusCard;

  /// Mini Calendar radius (Figma O6: 24px)
  static const double radius24 = 24.0;

  /// Pill/Capsule radius - full pill shape (Figma: 999px)
  /// Use for true pill-shaped elements like fitness pills, interest pills.
  static const double radiusPill = 999.0;

  // ─── O9 Success Screen Image Sizes (Figma O9 2024-12) ───

  /// Success Card 1 (left/top) image width (Figma: 92px)
  static const double successCard1ImageWidth = 92.0;

  /// Success Card 1 (left/top) image height (Figma: 127px)
  static const double successCard1ImageHeight = 127.0;

  /// Success Card 2/3 (right/bottom) image width (Figma: 46px)
  static const double successCardSmallImageWidth = 46.0;

  /// Success Card 2/3 (right/bottom) image height (Figma: 90px)
  static const double successCardSmallImageHeight = 90.0;

  /// Picker selection highlight radius (Figma: 14px)
  static const double radiusPickerHighlight = 14.0;

  static const double buttonHeight = 50.0; // Figma: Button H=50
  static const double touchTargetMin = 44.0; // iOS HIG / WCAG minimum tap target

  /// Icon size 24 px (Figma: Goal card icon)
  static const double iconM = 24.0;

  /// Icon size 32 px (Figma: Category chip icon fallback, dashboard icons)
  static const double iconL = 32.0;

  /// Fixed height for training card title container (Figma: 64px)
  static const double trainingCardTitleHeight = 64.0;

  /// Recommendation list/empty container height (Figma: 180px)
  static const double recommendationListHeight = 180.0;

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

  // ─── Auth Back Button (Figma Auth UI v2) ───

  /// Auth Back Button Icon Size (Figma: 32×30.5px, normalized to 32px square)
  /// Used for back chevron icon in Auth screens without circle background.
  /// Note: Figma shows non-square dimensions; 32px used as square touch target.
  static const double authBackIconSize = 32.0;

  // ─── Loading Indicator (Button spinner) ───

  /// Loading indicator size inside buttons (Figma: 20px)
  static const double loadingIndicatorSize = 20.0;

  /// Loading indicator stroke width (Figma: 2px)
  static const double loadingIndicatorStroke = 2.0;

  // ─── Onboarding Specific (Figma Onboarding v2) ───

  /// Progress Bar Max Width (Figma: 307px)
  static const double progressBarMaxWidth = 307.0;

  /// Calculate responsive progress bar width.
  /// Returns 80% of available width, capped at [progressBarMaxWidth].
  static double progressBarWidthFor(double availableWidth) {
    return (availableWidth * 0.80).clamp(0.0, progressBarMaxWidth);
  }

  /// Progress Bar Height (Figma: 18px)
  static const double progressBarHeight = 18.0;

  /// Onboarding Button Font Size (Figma: 20px)
  static const double onboardingButtonFontSize = 20.0;

  /// Input Text Font Size (Figma: 18px)
  static const double onboardingInputFontSize = 18.0;

  /// HEUTE Label Font Size - small for single line (Figma: 10px)
  static const double todayLabelFontSize = 10.0;

  /// Calendar day cell label placeholder size.
  /// Intentionally matches todayLabelFontSize to ensure uniform row height
  /// across days with and without the "HEUTE" label. (Fix 10: renamed for clarity)
  static const double calendarDayLabelSize = todayLabelFontSize;

  /// Calendar day cell total height (Figma: 48px).
  /// Fits day circle (32px) + HEUTE label (10px) + gap (4px) + padding.
  static const double calendarDayCellHeight = 48.0;

  // ─── Page Indicator Sizes (Welcome Flow - Figma Rebrand) ───

  /// Page indicator height (Figma Rebrand: 4px)
  static const double pageIndicatorHeight = 4.0;

  /// Page indicator inactive width (Figma Rebrand: 24px)
  static const double pageIndicatorInactiveWidth = 24.0;

  /// Page indicator active width (Figma Rebrand: 32px)
  static const double pageIndicatorActiveWidth = 32.0;

  /// Page indicator gap (Figma Rebrand: 8px)
  static const double pageIndicatorGap = 8.0;

  /// Page indicator border radius (Figma: pill shape)
  static const double pageIndicatorRadius = 999.0;

  // ─── Legacy aliases (deprecated, will be removed) ───
  @Deprecated('Use pageIndicatorHeight instead')
  static const double pageIndicatorDot = pageIndicatorHeight;
  @Deprecated('Use pageIndicatorActiveWidth instead')
  static const double pageIndicatorActive = pageIndicatorActiveWidth;

  // ─── Welcome Hero Frame (Figma Rebrand) ───

  /// Welcome Hero frame width (Figma: 354px)
  static const double welcomeHeroWidth = 354.0;

  /// Welcome Hero frame height (Figma: 475px)
  static const double welcomeHeroHeight = 475.0;

  /// Welcome Hero aspect ratio (354/475 ≈ 0.745)
  static const double welcomeHeroAspect = welcomeHeroWidth / welcomeHeroHeight;

  /// Welcome Hero border radius (Figma: 24px)
  static const double welcomeHeroRadius = 24.0;

  /// Welcome Hero border width (Figma: 1px solid black)
  static const double welcomeHeroBorderWidth = 1.0;

  // ─── Welcome CTA Button (Figma Rebrand) ───

  /// Welcome CTA button width (Figma: 300px)
  static const double welcomeCtaWidth = 300.0;

  /// Welcome CTA button height (Figma: 56px)
  static const double welcomeCtaHeight = 56.0;

  /// Welcome CTA button border radius (Figma: 12px)
  static const double welcomeCtaRadius = 12.0;

  /// Welcome Screen 3 subheader max width (Figma Rebrand: 308px)
  static const double welcomeSubheaderWidth = 308.0;

  // ─── Welcome Reference Device Thresholds (Figma: iPhone 14 Pro) ───

  /// Welcome reference device minimum width (Figma: 393px)
  /// Used to determine if hero needs scaling on constrained viewports.
  static const double welcomeReferenceWidth = 393.0;

  /// Welcome reference device minimum height (Figma: 800px)
  /// Below this height, hero scales down to prevent overflow.
  static const double welcomeReferenceHeight = 800.0;

  Sizes._();
}
