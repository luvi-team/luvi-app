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
