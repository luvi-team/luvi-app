import 'package:flutter/material.dart';

/// Design system color tokens (centralized, audit-backed).
class DsColors {
  const DsColors._();

  /// Accent purple/violet color from Figma (used for dock wave border, sync button bg).
  /// Figma: #CCB2F4 (Accent/300)
  static const Color accentPurple = Color(0xFFCCB2F4);

  /// Primary gold color (active tab tint).
  /// Figma: #D9B18E
  static const Color primaryGold = Color(0xFFD9B18E);

  /// Grayscale black (inactive tab tint, on-surface).
  /// Figma: #030401
  static const Color grayscaleBlack = Color(0xFF030401);

  /// Grayscale white (backgrounds).
  /// Figma: #FFFFFF
  static const Color grayscaleWhite = Color(0xFFFFFFFF);

  /// Secondary color dark (used for icon tints).
  /// Figma: #1C1411
  static const Color secondaryDark = Color(0xFF1C1411);

  /// Sub text 2 (inactive/secondary text).
  /// Figma: #6d6d6d
  static const Color subText2 = Color(0xFF6d6d6d);

  /// Grayscale/500 (borders, secondary UI elements).
  /// Figma: #696969
  static const Color grayscale500 = Color(0xFF696969);

  /// Cycle phase: follicular dark (Follikelphase).
  /// Hex: #4169E1
  static const Color phaseFollicularDark = Color(0xFF4169E1);

  /// Cycle phase: follicular light overlay (20% alpha).
  /// Hex: #4169E1 @ 0.20
  static const Color phaseFollicularLight = Color(0x334169E1);

  /// Cycle phase: ovulation base.
  /// Hex: #E1B941
  static const Color phaseOvulation = Color(0xFFE1B941);

  /// Cycle phase: luteal base.
  /// Hex: #A755C2
  static const Color phaseLuteal = Color(0xFFA755C2);

  /// Cycle phase: menstruation base.
  /// Hex: #FFB9B9
  static const Color phaseMenstruation = Color(0xFFFFB9B9);

  /// Cycle phase: menstruation dark (fallback for progress indicators).
  /// Hex: #8B3A62
  static const Color phaseMenstruationDark = Color(0xFF8B3A62);

  /// Dashboard wave overlay tint (30% opacity blush pink from Figma).
  /// Hex: #FADCDC @ 0x4D alpha.
  static const Color waveOverlayPink = Color(0x4DFADCDC);

  /// Primary text color.
  /// Hex: #030401
  static const Color textPrimary = grayscaleBlack;

  /// Secondary text color.
  /// Hex: #6D6D6D
  static const Color textSecondary = subText2;

  /// Muted text color.
  /// Hex: #C5C7C9
  static const Color textMuted = Color(0xFFC5C7C9);

  /// Informational background.
  /// Hex: #CCB2F4
  static const Color infoBackground = accentPurple;

  /// Neutral card background.
  /// Hex: #F7F7F8 (Figma Grayscale/100)
  static const Color cardBackgroundNeutral = Color(0xFFF7F7F8);

  /// White surface token.
  /// Hex: #FFFFFF
  static const Color white = grayscaleWhite;

  /// Low-emphasis border color for neutral cards.
  /// Hex: #000000 @ 10% alpha
  static const Color borderSubtle = Color(0x1A000000);

  // ─── Welcome Screen Specific (Figma Polish v2) ───

  /// Welcome CTA Button Background (Figma: #A8406F)
  static const Color welcomeButtonBg = Color(0xFFA8406F);

  /// Welcome Wave/Panel Background (Figma: #FAEEE0 warm cream)
  static const Color welcomeWaveBg = Color(0xFFFAEEE0);

  /// Welcome Button Text (white)
  static const Color welcomeButtonText = Color(0xFFFFFFFF);

  // ─── Auth Flow Specific (Figma Auth UI v2) ───

  /// Auth SignIn Headline Magenta (Figma: #9F2B68)
  static const Color headlineMagenta = Color(0xFF9F2B68);

  /// Auth Gradient Base Color (Figma: #D4B896)
  static const Color authGradientBase = Color(0xFFD4B896);

  /// Auth Gradient Light Color (Figma: #EDE1D3)
  static const Color authGradientLight = Color(0xFFEDE1D3);

  // ─── Auth Conic Gradient Stops (Figma SignIn Screen) ───

  /// Auth Gradient Stop: #E5D3BF (19.79%)
  static const Color authGradientStop1 = Color(0xFFE5D3BF);

  /// Auth Gradient Stop: #EADDCD (29.13%)
  static const Color authGradientStop2 = Color(0xFFEADDCD);

  /// Auth Gradient Stop: #D6BC9C (60.93%)
  static const Color authGradientStop3 = Color(0xFFD6BC9C);

  /// Auth Gradient Stop: #E2CFB8 (78.65%)
  static const Color authGradientStop4 = Color(0xFFE2CFB8);

  // ─── Auth Radial Gradient Stops (Figma Success Screen) ───

  /// Auth Radial Stop: #DBC4A7 (14.17%)
  static const Color authRadialStop1 = Color(0xFFDBC4A7);

  /// Auth Radial Stop: #E4D3BE (32.86%)
  static const Color authRadialStop2 = Color(0xFFE4D3BE);

  /// Auth Radial Stop: #E9DBCA (42.51%)
  static const Color authRadialStop3 = Color(0xFFE9DBCA);

  /// Auth Radial Stop: #E8D9C7 (60.22%)
  static const Color authRadialStop4 = Color(0xFFE8D9C7);

  /// Auth Radial Stop: #E1CDB5 (74.22%)
  static const Color authRadialStop5 = Color(0xFFE1CDB5);

  /// Auth Radial Stop: #DBC4A8 (85.34%)
  static const Color authRadialStop6 = Color(0xFFDBC4A8);

  // ─── Auth Glass Card (Figma SignIn Screen) ───

  /// Glass Background: 10% white opacity (rgba 255,255,255,0.1)
  static const Color authGlassBackground = Color(0x1AFFFFFF);

  /// Glass Border: 20% white opacity (rgba 255,255,255,0.2)
  static const Color authGlassBorder = Color(0x33FFFFFF);

  // ─── Auth Outline Button (Figma SignIn Screen) ───

  /// Outline Button Border Color (Figma: #E5E7EB)
  static const Color authOutlineBorder = Color(0xFFE5E7EB);

  /// Outline Button Text/Icon Color (Figma: #1F2937)
  static const Color authOutlineText = Color(0xFF1F2937);

  // ─── Base Colors (Common Utility) ───

  /// Pure black (#000000) for filled buttons like Apple Sign-In.
  static const Color black = Color(0xFF000000);

  /// Fully transparent color for backgrounds that should show through.
  static const Color transparent = Color(0x00000000);

  /// Shadow color for elevated components (20% black opacity).
  /// Used for: OnboardingButton drop shadow
  static const Color shadowMedium = Color(0x33000000);

  // ─── Consent & Onboarding Specific (Figma Refactor 2024-12) ───

  /// Consent Background Cream (Figma: #FAEEE0)
  /// Alias: Same as welcomeWaveBg for consistency
  static const Color bgCream = welcomeWaveBg;

  /// Gradient Light Gold (Figma: #EDE1D3)
  /// Alias: Same as authGradientLight for consistency
  static const Color goldLight = authGradientLight;

  /// Gradient Medium Gold (Figma: #D4B896)
  /// Alias: Same as authGradientBase for consistency
  static const Color goldMedium = authGradientBase;

  /// Signature Magenta (Figma: #9F2B68)
  /// Used for links, progress indicators, period markers
  /// Alias: Same as headlineMagenta for consistency
  static const Color signature = headlineMagenta;

  /// Primary Button Background (Figma: #A8406F)
  /// Alias: Same as welcomeButtonBg for consistency
  static const Color buttonPrimary = welcomeButtonBg;

  /// Gray 300 - Secondary Button Background (Figma: #DCDCDC)
  static const Color gray300 = Color(0xFFDCDCDC);

  /// Gray 500 - Secondary Button Text (Figma: #525252)
  static const Color gray500 = Color(0xFF525252);

  /// Divider Color (Figma: #A1A1A1)
  static const Color divider = Color(0xFFA1A1A1);

  // ─── Consent Checkbox Specific (Figma Consent Options Screen) ───

  /// Consent Checkbox Border (Figma: #B0B0B0)
  static const Color consentCheckboxBorder = Color(0xFFB0B0B0);

  /// Consent Checkbox Selected Fill (Figma: #A8406F)
  /// Alias: Same as buttonPrimary for consistency
  static const Color consentCheckboxSelected = buttonPrimary;

  /// Consent Checkbox Background (Figma: #FFFFFF)
  /// Alias: Same as grayscaleWhite for consistency
  static const Color consentCheckboxBackground = grayscaleWhite;

  /// Divider Gray (Figma: #A1A1A1)
  /// Alias: Same as divider for semantic clarity
  static const Color dividerGray = divider;

  // ─── Calendar/Period Picker Specific (Figma Onboarding 2024-12) ───

  /// Calendar Weekday Header Gray (Figma: #99A1AF)
  static const Color calendarWeekdayGray = Color(0xFF99A1AF);

  /// Today Label Gray (Figma: #6A7282)
  static const Color todayLabelGray = Color(0xFF6A7282);

  /// Period Glow Pink Base - 100% opacity for animation control (Figma: #FF6482)
  /// Use this when alpha is animated programmatically via .withValues(alpha:)
  static const Color periodGlowPinkBase = Color(0xFFFF6482);

  /// Period Glow Pink - 60% opacity (Figma: #FF6482 @ 0.6)
  static const Color periodGlowPink = Color(0x99FF6482);

  /// Period Glow Pink Light - 10% opacity (Figma: #FF6482 @ 0.1)
  ///
  /// Migration: Find & replace `periodGlowPinkLight` → `periodGlow10`
  /// Note: Updated to canonical 10% value (0x1A=26/255=10.2%)
  @Deprecated('Use periodGlow10 instead. Will be removed in v2.0.0')
  static const Color periodGlowPinkLight = Color(0x1AFF6482);

  /// Date Picker Selection Background (Figma: #F5F5F5)
  static const Color datePickerSelectionBg = Color(0xFFF5F5F5);

  // ─── Onboarding Success Screen (Figma O9 2024-12) ───

  /// Success Card Glass Background (Figma: #E9D5FF @ 20%)
  /// Light purple/lavender with 20% opacity for content preview cards
  static const Color successCardGlass = Color(0x33E9D5FF);

  /// Success Card 1 (left/top) - Purple (Figma: #E9D5FF @ 20%)
  /// Alias of successCardGlass for semantic clarity
  static const Color successCardPurple = successCardGlass;

  /// Success Card 2 (right) - Cyan (Figma: #CFFAFE @ 20%)
  static const Color successCardCyan = Color(0x33CFFAFE);

  /// Success Card 3 (bottom) - Pink (Figma: #FCE7F3 @ 20%)
  static const Color successCardPink = Color(0x33FCE7F3);

  // ─── O6 Radial Gradient Colors (Figma O6 2024-12) ───

  /// Period Glow 60% opacity - alias for periodGlowPink (Fix 9: deduplicate)
  static const Color periodGlow60 = periodGlowPink;

  /// Period Glow 10% opacity - canonical value (Figma: #FF6482 @ 10%)
  /// 0x1A = 26/255 = 10.2% (closest integer to true 10%)
  /// Prefer this over deprecated periodGlowPinkLight.
  static const Color periodGlow10 = Color(0x1AFF6482);
}

/// Widget-facing color tokens that map named usages to DS palette values.
class ColorTokens {
  const ColorTokens._();

  /// Selected background for category chips (Figma: Primary color/100).
  static const Color chipSelected = DsColors.primaryGold;

  /// Default background for category chips (Figma: Grayscale/100).
  static const Color chipDefault = Color(0xFFF7F7F8);

  /// Text color for card tags that ensures WCAG-AA contrast.
  static const Color recommendationTag = Color(0xFFA0A0A0);

  /// Section header title color (maps to textPrimary).
  static const Color sectionTitle = DsColors.textPrimary;

  /// Section header trailing action color (maps to primary gold).
  static const Color sectionTrailing = DsColors.primaryGold;
}
