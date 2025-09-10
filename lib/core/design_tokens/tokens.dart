import 'package:flutter/material.dart';

/// Zentraler Zugriff auf LUVI-Design-Tokens via Theme.
/// Keine Hexwerte, nur Theme/ColorScheme/TextTheme.
class LuviTokens {
  LuviTokens.of(this.context);
  final BuildContext context;

  Color get primary => Theme.of(context).colorScheme.primary;
  Color get surface => Theme.of(context).colorScheme.surface;
  Color get onSurface => Theme.of(context).colorScheme.onSurface;
  Color get outline => Theme.of(context).colorScheme.outline;

  TextStyle? get h1 => Theme.of(context).textTheme.headlineLarge;
  TextStyle? get body => Theme.of(context).textTheme.bodyMedium;
  TextStyle? get callout => Theme.of(context).textTheme.titleSmall;
  TextStyle? get caption => Theme.of(context).textTheme.titleMedium;

  SizedBox get gap8 => const SizedBox(height: 8, width: 8);
  SizedBox get gap16 => const SizedBox(height: 16, width: 16);
  SizedBox get gap24 => const SizedBox(height: 24, width: 24);
  SizedBox get gap34 => const SizedBox(height: 34, width: 34);

  // --- Welcome: Geometry ---
  static const double welcomeHeroHeightRatio = 0.677; // 627/926 (Figma)
  static const double welcomeHeroAlignY = -0.72; // Feintuning-Knopf für Hero-Bild
  static const double _welcomeWaveIntrusionRatio = 138.0 / 428.0; // Crest-Eindringtiefe relativ zur Breite
  double welcomeWaveIntrusionForWidth(double width) => width * _welcomeWaveIntrusionRatio;

  // --- Welcome: Spacing (@428 px) ---
  static const double welcomeContentHorizontal = 20;
  static const double welcomeHeadlineToBody = 8;
  static const double welcomeBodyToDots = 24;
  static const double welcomeDotsToButton = 34;
  static const double welcomeButtonToSkip = 24;
  static const double welcomeDotSpacing = 6;
  static const double _welcomeContentFromWaveRatio = 62.0 / 428.0;
  double welcomeContentFromWaveForWidth(double width) => width * _welcomeContentFromWaveRatio;

  // --- Welcome: Colors (HEX aus Figma) ---
  static const Color welcomeTextPrimary = Color(0xFF030401);
  static const Color welcomeAccent = Color(0xFFD9B6A3);   // "Superkraft."
  static const Color welcomeCtaFill = Color(0xFFD9B18E);
  static const Color welcomeCtaText = Color(0xFFFFFFFF);
  static const Color welcomeDotActive = Color(0xFFD9B18E);
  static const Color welcomeDotInactive = Color(0xFFE5E5E5);

  // --- Welcome: Safe bottom padding helper ---
  double welcomeSafeBottomPadding(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    // Einheitlich: mind. 24 pt oder das vorhandene Inset (kein doppeltes Addieren!)
    return inset > 24 ? inset : 24;
  }

  // Figma-Basis für Wellen-Layout
  static const double welcomeWaveBaselineWidth = 428.0;
  @Deprecated('Replaced by welcomeWaveIntrusionForWidth(width) // TODO: in nächstem Commit entfernen')
  static const double welcomeWaveHeightAtBaseline = 95.0; // vorher 120.0
  @Deprecated('Replaced by welcomeWaveIntrusionForWidth(width) // TODO: in nächstem Commit entfernen')
  double welcomeWaveHeightForWidth(double width) =>
      width * (welcomeWaveHeightAtBaseline / welcomeWaveBaselineWidth);
  
  // 32px bei 428px Breite
  double welcomeTextTopSpacingForWidth(double width) =>
      width * (32.0 / 428.0);
  
  /// Safe bottom padding that accounts for home indicator and gesture navigation
  /// Mindestens 24px Luft über dem Home-Indicator
  double safeBottomPadding(BuildContext context) {
    final inset = MediaQuery.of(context).viewPadding.bottom;
    const min = 24.0;
    return inset > 0 ? inset + 8.0 : min;
  }
}
