/// Design metrics for Auth Rebrand v3 (Figma Auth Screens 2026-01).
///
/// Baseline: 393×873 (Figma export dimensions)
/// All values are pixel-exact from Figma audit YAML.
class AuthRebrandMetrics {
  const AuthRebrandMetrics._();

  // ─── Design Baseline ───
  static const double designWidth = 393.0;
  static const double designHeight = 873.0;

  // ─── Entry Screen ───
  static const double entryCtaY = 692.0;
  static const double entryCtaWidth = 300.0;
  static const double entryPrimaryButtonHeight = 56.0;
  static const double entryLogoTopPadding = 120.0;
  static const double entryTealDotSize = 44.0;

  // ─── Bottom Sheet Overlay ───
  static const double sheetTopY = 253.0;
  static const double sheetHeight = 621.0;
  static const double sheetRadius = 40.0;
  static const double sheetDragIndicatorWidth = 40.0;
  static const double sheetDragIndicatorHeight = 4.0;

  // ─── Content Card ───
  static const double cardWidth = 361.0;
  static const double cardRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double cardContentGap = 16.0;
  static const double cardInputGap = 8.0;

  // ─── Input Fields ───
  static const double inputHeight = 50.0;
  static const double inputRadius = 12.0;
  static const double inputBorderWidth = 1.0;
  static const double inputPaddingHorizontal = 16.0;

  // ─── Buttons ───
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 12.0;
  static const double buttonWidth = 329.0;
  static const double ctaButtonWidth = 249.0;

  // ─── Rainbow Background ───
  /// Ring widths from outer to inner: teal, pink, orange, beige
  static const List<double> rainbowRingWidths = [329.0, 249.0, 167.0, 87.0];

  // ─── Back Button ───
  static const double backButtonLeft = 10.0;
  static const double backButtonTop = 53.0;
  static const double backButtonTouchTarget = 44.0;

  // ─── Typography ───
  static const double headlineFontSize = 20.0;
  static const double headlineLineHeight = 24.0 / 20.0; // 1.2
  static const double placeholderFontSize = 12.0;
  static const double placeholderLineHeight = 15.0 / 12.0; // 1.25
  static const double buttonFontSize = 17.0;
  static const double linkFontSize = 17.0;

  // ─── Content Spacing ───
  static const double contentTopGap = 100.0; // Gap nach Back-Button zu Content
  static const double contentBottomGap = 60.0; // Gap vor CTA-Button
  static const double sheetBottomGap = 40.0; // Gap für Bottom Stripes in Sheets
  static const double entryLogoGap = 80.0; // Gap zwischen Logo und CTA auf Entry
}
