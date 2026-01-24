import 'dart:ui';

/// Centralized FontVariation constants for variable fonts.
///
/// Consolidates inline FontVariation('wght', xxx) usage across the codebase.
abstract final class FontVariations {
  /// Bold weight (700)
  static const FontVariation bold = FontVariation('wght', 700);

  /// SemiBold weight (600)
  static const FontVariation semiBold = FontVariation('wght', 600);

  /// Medium weight (500)
  static const FontVariation medium = FontVariation('wght', 500);

  /// Regular weight (400)
  static const FontVariation regular = FontVariation('wght', 400);
}

/// Typography tokens used across onboarding.
class TypographyTokens {
  const TypographyTokens._();

  static const double size12 = 12.0;
  static const double size14 = 14.0;
  static const double size16 = 16.0;
  static const double size18 = 18.0;
  static const double size20 = 20.0;
  static const double size24 = 24.0;
  static const double size28 = 28.0;
  static const double size30 = 30.0;
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

  /// Welcome Screen 2 Title: Figma 38px line-height on 30px font (ratio: 1.267)
  static const double lineHeightRatio38on30 = 38 / 30;

  /// Welcome Subtitle: Figma 26px line-height on 20px font (ratio: 1.3)
  static const double lineHeightRatio26on20 = 26 / 20;

  /// Welcome Button Label: Figma 24px line-height on 17px font (ratio: 1.412)
  static const double lineHeightRatio24on17 = 24 / 17;

  /// Button font size 17px (Figma Welcome CTA)
  static const double size17 = 17.0;

  /// Onboarding header: 28px line-height on 20px font (ratio: 1.4)
  static const double lineHeightRatio28on20 = 28 / 20;

  /// Consent intro title: 37.5px line-height on 30px font (ratio: 1.25)
  static const double lineHeightRatio37_5on30 = 37.5 / 30;

  /// Consent intro body: 29.25px line-height on 18px font (ratio: 1.625)
  static const double lineHeightRatio29_25on18 = 29.25 / 18;

  /// Consent Options header: 34px line-height on 28px font (ratio: 1.214)
  static const double lineHeightRatio34on28 = 34 / 28;

  /// Consent Options body: 22px line-height on 14px font (ratio: 1.571)
  static const double lineHeightRatio22on14 = 22 / 14;

  /// Section header: 20px line-height on 14px font (ratio: 1.429)
  static const double lineHeightRatio20on14 = 20 / 14;
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

/// Consent screen typography constants (Figma Consent UI).
///
/// These constants define reusable text style parameters for consent screens.
/// Use with theme.textTheme.copyWith() to maintain theme integration.
///
/// Values delegate to [TypographyTokens] to avoid maintenance drift.
class ConsentTypography {
  const ConsentTypography._();

  // ─── Consent Intro Title (Playfair Display SemiBold 30px) ───
  /// Consent intro title fontSize (Figma: 30px)
  static const double introTitleFontSize = TypographyTokens.size30;

  /// Consent intro title lineHeight ratio (Figma: 37.5/30 = 1.25)
  static const double introTitleLineHeight = TypographyTokens.lineHeightRatio37_5on30;

  // ─── Consent Intro Body (Figtree Regular 18px) ───
  /// Consent intro body fontSize (Figma: 18px)
  static const double introBodyFontSize = TypographyTokens.size18;

  /// Consent intro body lineHeight ratio (Figma: 29.25/18 = 1.625)
  static const double introBodyLineHeight = TypographyTokens.lineHeightRatio29_25on18;

  // ─── Consent Options Header (Playfair Display Bold 28px) ───
  /// Consent options header fontSize (Figma: 28px)
  static const double headerFontSize = TypographyTokens.size28;

  /// Consent options header lineHeight ratio (Figma: 34/28 = 1.214)
  static const double headerLineHeight = TypographyTokens.lineHeightRatio34on28;

  // ─── Consent Options Subheader (Playfair Display SemiBold 17px) ───
  /// Consent options subheader fontSize (Figma: 17px)
  static const double subheaderFontSize = TypographyTokens.size17;

  /// Consent options subheader lineHeight ratio (Figma: 24/17 = 1.412)
  static const double subheaderLineHeight = TypographyTokens.lineHeightRatio24on17;

  // ─── Consent Options Body Text (Figtree Regular 14px) ───
  /// Consent options body fontSize (Figma: 14px)
  static const double bodyFontSize = TypographyTokens.size14;

  /// Consent options body lineHeight ratio (Figma: 22/14 = 1.571)
  static const double bodyLineHeight = TypographyTokens.lineHeightRatio22on14;

  // ─── Consent Options CTA Button (Figtree Bold 17px) ───
  /// Consent options button fontSize (Figma: 17px)
  static const double buttonFontSize = TypographyTokens.size17;

  /// Consent options button lineHeight ratio (Figma: 24/17 = 1.412)
  static const double buttonLineHeight = TypographyTokens.lineHeightRatio24on17;

  // ─── Consent Options Section Header (Figtree Bold 14px) ───
  /// Section header font size (14px)
  static const double sectionHeaderFontSize = TypographyTokens.size14;

  /// Section header line height ratio (20px / 14px = 1.429)
  static const double sectionHeaderLineHeight = TypographyTokens.lineHeightRatio20on14;

  // ─── Consent Options Footnote (Figtree Regular 12px) ───
  /// Footnote font size (12px) - used for revoke instructions
  static const double footnoteFontSize = TypographyTokens.size12;

  /// Footnote line height ratio (16px / 12px = 1.333, standard for 12px text)
  static const double footnoteLineHeight = TypographyTokens.lineHeightRatio16on12;
}

/// Welcome screen typography constants (Figma Welcome Rebrand).
///
/// These constants define reusable text style parameters for welcome screens.
/// Values delegate to [TypographyTokens] to avoid maintenance drift.
class WelcomeTypography {
  const WelcomeTypography._();

  // ─── W1 Headline (Playfair Display Bold 28px) ───
  /// W1 headline fontSize (Figma: 28px)
  static const double w1FontSize = TypographyTokens.size28;

  /// W1 headline lineHeight ratio (Figma: 36/28)
  static const double w1LineHeight = TypographyTokens.lineHeightRatio36on28;

  /// W1 headline fontWeight (Figma: Bold 700)
  static const int w1FontWeight = 700;

  // ─── W2 Headline (Playfair Display Bold 30px) ───
  /// W2 headline fontSize (Figma: 30px)
  static const double w2FontSize = TypographyTokens.size30;

  /// W2 headline lineHeight ratio (Figma: 38/30)
  static const double w2LineHeight = TypographyTokens.lineHeightRatio38on30;

  /// W2 headline fontWeight (Figma: Bold 700)
  static const int w2FontWeight = 700;

  // ─── W3 Headline (Playfair Display SemiBold 32px) ───
  /// W3 headline fontSize (Figma: 32px)
  static const double w3FontSize = TypographyTokens.size32;

  /// W3 headline lineHeight ratio (Figma: 38/32)
  static const double w3LineHeight = TypographyTokens.lineHeightRatio38on32;

  /// W3 headline fontWeight (Figma: SemiBold 600)
  static const int w3FontWeight = 600;
}
