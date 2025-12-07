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
