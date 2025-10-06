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
}
