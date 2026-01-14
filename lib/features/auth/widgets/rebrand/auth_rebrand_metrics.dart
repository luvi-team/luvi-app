/// Design metrics for Auth Rebrand v3 (Figma Auth Screens 2026-01).
///
/// Baseline: 393×873 (Figma export dimensions)
/// All values are pixel-exact from Figma audit YAML.
class AuthRebrandMetrics {
  const AuthRebrandMetrics._();

  // ─── Design Baseline ───
  // PNG-Exports are 402×874 (visual SSOT from context/design/Auth Screens/)
  static const double designWidth = 402.0;
  static const double designHeight = 874.0;
  static const double statusBarHeight = 47.0;

  // ─── Entry Screen (SSOT: auth_entry) ───
  static const double entryCtaY = 692.0;
  static const double entryCtaX = 52.0;
  static const double entryCtaWidth = 300.0;
  static const double entryPrimaryButtonHeight = 56.0;
  static const double entryLogoWidth = 489.0;
  static const double entryLogoHeight = 87.0;
  static const double entryLogoCenterYOffset = -268.0;
  static const double entryTealDotX = 306.0;
  static const double entryTealDotY = 95.0;
  static const double entryTealDotSize = 44.0;
  static const double entryCtaGap = 16.0; // Gap Button→Link

  // ─── Bottom Sheet Overlay (SSOT: auth_overlay) ───
  static const double sheetTopY = 253.0;
  static const double sheetWidth = 402.0;
  static const double sheetHeight = 621.0;
  static const double sheetRadius = 40.0;
  static const double sheetBorderTop = 2.0;
  static const double sheetDragIndicatorWidth = 134.0; // SSOT: 134
  static const double sheetDragIndicatorHeight = 5.0; // SSOT: 5
  static const double sheetDragIndicatorTop = 17.0; // SSOT: 17
  static const double sheetDragIndicatorRadius = 100.0; // SSOT: fully rounded

  // ─── Rainbow Container (SSOT: auth_overlay.rainbow_container) ───
  static const double overlayRainbowContainerTop = 53.0;
  static const double overlayRainbowContainerWidth = 371.0;
  static const double overlayRainbowContainerHeight = 568.0;

  // ─── Content Card ───
  static const double cardWidth = 361.0; // Overlay card width
  static const double cardWidthForm = 364.0; // Email form card width (SSOT)
  static const double cardRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double cardContentGap = 16.0;
  static const double cardInputGap = 8.0;

  // ─── Input Fields ───
  static const double inputHeight = 50.0;
  static const double inputWidth = 329.0;
  static const double inputRadius = 12.0;
  static const double inputBorderWidth = 1.0;
  static const double inputPaddingHorizontal = 16.0;

  // ─── Buttons ───
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 12.0;
  static const double buttonWidth = 329.0;
  static const double ctaButtonWidth = 249.0;

  // ─── Outline Button Icon Layout (SSOT: auth_overlay) ───
  static const double outlineButtonIconLeftPadding = 53.0;
  static const double outlineButtonIconSize = 20.0;
  static const double outlineButtonIconToTextGap = 26.0;

  // ─── Rainbow Background (SSOT: rainbow_footer_stripes.ring_widths) ───
  /// Ring widths from outer to inner: teal, pink, orange, beige
  static const List<double> rainbowRingWidths = [329.0, 249.0, 167.0, 87.0];

  /// Calculated stripe widths: teal=40, pink=41, orange=40, beige=87
  static const List<double> rainbowStripeWidths = [40.0, 41.0, 40.0, 87.0];

  // ─── Rainbow Ring Offsets (SSOT: auth_email_form.ring_offsets) ───
  static const double ringTealX = 21.0; // (371 - 329) / 2
  static const double ringTealY = 7.0;
  static const double ringPinkX = 58.0;
  static const double ringPinkY = 56.0;
  static const double ringOrangeX = 99.0;
  static const double ringOrangeY = 112.0;
  static const double ringBeigeX = 139.0;
  static const double ringBeigeY = 168.0;

  // ─── Rainbow Heights for Overlay (SSOT: auth_registrieren_overlay) ───
  static const double overlayRingTealHeight = 561.0;
  static const double overlayRingPinkHeight = 512.0;
  static const double overlayRingOrangeHeight = 456.0;
  static const double overlayRingBeigeHeight = 400.0;

  // ─── Back Button ───
  static const double backButtonLeft = 10.0;
  static const double backButtonTop = 53.0;
  static const double backButtonTouchTarget = 44.0;

  // ─── Typography ───
  static const double headlineFontSize = 20.0;
  static const double headlineLineHeight = 24.0 / 20.0; // 1.2
  static const double bodyFontSize = 17.0;
  static const double bodyLineHeight = 24.0 / 17.0;
  static const double placeholderFontSize = 12.0;
  static const double placeholderLineHeight = 15.0 / 12.0; // 1.25
  static const double buttonFontSize = 17.0;
  static const double linkFontSize = 17.0;
  static const double errorTextFontSize = 14.0; // Error messages & field hints
  static const double dividerTextFontSize = 14.0; // "oder" divider text

  // ─── Icon Sizes ───
  static const double passwordToggleIconSize = 20.0;
  static const double backButtonIconSize = 28.0;

  // ─── Content Spacing ───
  static const double contentTopGap = 100.0; // Gap nach Back-Button zu Content
  static const double contentBottomGap = 60.0; // Gap vor CTA-Button
  static const double sheetBottomGap = 40.0; // Gap für Bottom Stripes in Sheets
  static const double entryLogoGap = 80.0; // Gap zwischen Logo und CTA auf Entry
}
