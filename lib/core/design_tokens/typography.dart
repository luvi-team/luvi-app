/// Typography tokens used across onboarding.
class TypographyTokens {
  const TypographyTokens._();

  static const double size12 = 12.0;
  static const double size14 = 14.0;
  static const double size16 = 16.0;
  static const double size20 = 20.0;
  static const double size24 = 24.0;
  static const double size28 = 28.0;
  static const double size32 = 32.0;

  static const double lineHeightRatio16on12 = 16 / 12;
  static const double lineHeightRatio24on14 = 24 / 14;
  static const double lineHeightRatio24on16 = 24 / 16;
  static const double lineHeightRatio24on20 = 24 / 20;
  static const double lineHeightRatio32on24 = 32 / 24;
  static const double lineHeightRatio36on28 = 36 / 28;
  static const double lineHeightRatio40on32 = 40 / 32;

  /// Welcome Title: Figma 38px line-height on 32px font (ratio: 1.1875)
  static const double lineHeightRatio38on32 = 38 / 32;

  /// Welcome Subtitle: Figma 26px line-height on 20px font (ratio: 1.3)
  static const double lineHeightRatio26on20 = 26 / 20;
}

/// Shared font family identifiers to centralize typography references.
class FontFamilies {
  const FontFamilies._();

  static const String figtree = 'Figtree';
  static const String inter = 'Inter';
  static const String playfairDisplay = 'Playfair Display';
}

/// Auth screen typography constants (Figma Auth UI v2).
///
/// These constants define reusable text style parameters for auth screens.
/// Use with theme.textTheme.copyWith() to maintain theme integration.
///
/// Values delegate to [TypographyTokens] to avoid maintenance drift.
class AuthTypography {
  const AuthTypography._();

  // ─── Auth Headline (SignIn glass card) ───
  /// Auth headline fontSize (Figma: Playfair Display Bold 32px)
  static const double headlineFontSize = TypographyTokens.size32;

  /// Auth headline lineHeight ratio (Figma: 40/32)
  static const double headlineLineHeight = TypographyTokens.lineHeightRatio40on32;

  // ─── Auth Title (Login, Reset, CreateNew screens) ───
  /// Auth title fontSize (Figma: Playfair Display Bold 24px)
  static const double titleFontSize = TypographyTokens.size24;

  /// Auth title lineHeight ratio (Figma: 32/24)
  static const double titleLineHeight = TypographyTokens.lineHeightRatio32on24;

  // ─── Success Screen Typography ───
  /// Success title fontSize (Figma: Playfair Display Regular 32px)
  static const double successTitleFontSize = TypographyTokens.size32;

  /// Success title lineHeight ratio (Figma: 40/32)
  static const double successTitleLineHeight = TypographyTokens.lineHeightRatio40on32;

  /// Success subtitle fontSize (Figma: Playfair Display Regular 24px)
  static const double successSubtitleFontSize = TypographyTokens.size24;

  /// Success subtitle lineHeight ratio (Figma: 32/24)
  static const double successSubtitleLineHeight = TypographyTokens.lineHeightRatio32on24;
}
