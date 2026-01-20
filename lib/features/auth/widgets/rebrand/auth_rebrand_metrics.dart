/// Design metrics for Auth Rebrand v3 (Figma Auth Screens 2026-01).
///
/// Baseline: 402×874 (PNG export SSOT from context/design/Auth Screens/)
/// All values are pixel-exact from Figma audit YAML.
final class AuthRebrandMetrics {
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
  static const double entryLogoHeight = 87.0;
  static const double entryLogoCenterYOffset = -240.0; // Adjusted: logo closer to center
  static const double entryCtaGap = 16.0; // Gap Button→Link

  // ─── Teal Dot (relative to Logo, SSOT: Figma node 69650:2686) ───
  static const double entryTealDotSize = 44.0;
  static const double entryTealDotGap = 15.0; // Gap between dot bottom and logo top (halved)
  /// Dot right offset from logo right edge (negative = extends beyond logo)
  static const double entryTealDotRightOffset = -2.0;
  /// Dot top offset relative to logo top: -(dotSize + gap)
  static const double entryTealDotTopOffset = -(entryTealDotSize + entryTealDotGap);

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
  /// Rainbow container top offset - applies to ALL auth screens (Figma Node 69692:2569)
  /// Calculated: SafeArea.top(47) + backButtonTop(20) + chevronOffset(13) - ringTealY(7) = 73
  /// This aligns the teal arc top with the back button chevron top.
  static const double overlayRainbowContainerTop = 73.0;
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
  /// Ring widths from outer to inner.
  /// Index mapping: [0]=teal, [1]=pink, [2]=orange, [3]=beige
  static const List<double> rainbowRingWidths = [329.0, 249.0, 167.0, 87.0];

  /// Calculated stripe widths.
  /// Index mapping: [0]=teal(40), [1]=pink(41), [2]=orange(40), [3]=beige(87)
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
  static const double backButtonTop = 20.0; // Näher an Status Bar (Figma-Alignment)
  // Note: backButtonTouchTarget removed - use Sizes.touchTargetMin (SSOT)

  // ─── Rainbow Container Alignment ───
  /// Offset from SafeArea.top for rainbow container positioning.
  /// Aligns rainbow arcs visually with back button position (Figma SSOT).
  static const double rainbowContainerTopOffset = 26.0;

  // ─── Typography ───
  static const double headlineFontSize = 20.0;
  static const double headlineLineHeightRatio = 24.0 / 20.0; // 1.2
  static const double headlineLineHeight = headlineLineHeightRatio;

  static const double bodyFontSize = 17.0;
  static const double bodyLineHeightRatio = 24.0 / 17.0;
  static const double bodyLineHeight = bodyLineHeightRatio;

  static const double placeholderFontSize = 12.0;
  static const double placeholderLineHeightRatio = 15.0 / 12.0; // 1.25
  static const double placeholderLineHeight = placeholderLineHeightRatio;

  static const double buttonFontSize = 17.0;
  static const double linkFontSize = 17.0;
  static const double inputTextFontSize = 14.0;
  static const double errorTextFontSize = 14.0; // Error messages & field hints
  static const double dividerTextFontSize = 14.0; // "oder" divider text

  // ─── Icon Sizes ───
  static const double passwordToggleIconSize = 20.0;
  static const double loadingIndicatorSize = 20.0;
  static const double loadingIndicatorStrokeWidth = 2.0;
  /// Back button icon size - reduced for Figma SVG alignment (stroke 1.5dp)
  static const double backButtonIconSize = 24.0;

  // ─── Content Spacing ───
  static const double contentTopGap = 100.0; // Gap nach Back-Button zu Content
  static const double contentBottomGap = 60.0; // Gap vor CTA-Button
  static const double sheetBottomGap = 40.0; // Gap für Bottom Stripes in Sheets
  static const double entryLogoGap = 80.0; // Gap zwischen Logo und CTA auf Entry

  // ─── Keyboard Handling ───
  /// Factor applied to keyboard height for padding calculation.
  /// Calculated as targetMax / typicalKeyboardHeight (200 / 320 ≈ 0.625)
  static const double keyboardPaddingFactor = 0.625;
  /// Maximum padding when keyboard is open
  static const double keyboardPaddingMax = 200.0;

  // ─── Keyboard Handling (Compact Cards) ───
  /// Factor for screens with fewer fields (e.g., ResetPasswordScreen, CreateNewPasswordScreen).
  /// Lower factor = less upward shift = smaller gap to keyboard.
  /// Tuned iteratively to match visual gap of larger cards (Login/Signup).
  static const double keyboardPaddingFactorCompact = 0.50;
  /// Maximum padding for compact cards (fewer fields than Login/Signup).
  static const double keyboardPaddingMaxCompact = 157.0;
}
