import 'package:flutter/material.dart';
import '../design_tokens/typography.dart';
import '../design_tokens/spacing.dart';
import '../design_tokens/sizes.dart';

/// Minimal theme scaffold for the LUVI app.
/// This is a placeholder for future design system implementation.
class AppTheme {
  // Colors from Figma CSS
  static const Color _primary = Color(
    0xFFD9B18E,
  ); // Primary color/100 (Button bg)
  static const Color _accentSubtle = Color(
    0xFFD9B6A3,
  ); // Accent-Subtle (nur "Superkraft.")
  static const Color _onPrimary = Color(0xFFFFFFFF); // Grayscale/White
  static const Color _onSurface = Color(0xFF030401); // Grayscale/Black
  static const Color _grayscale400 = Color(
    0xFFB0B0B0,
  ); // Grayscale/400 (Dots inactive base)

  static const TextTheme _textThemeConst = TextTheme(
    // H1
    headlineMedium: TextStyle(
      fontFamily: TypeScale.playfair,
      fontWeight: FontWeight.w400,
      fontSize: TypeScale.h1Size,
      height: TypeScale.h1Height,
      letterSpacing: 0,
    ),
    // Body Regular
    bodyMedium: TextStyle(
      fontFamily: TypeScale.figtree,
      fontWeight: FontWeight.w400,
      fontSize: TypeScale.bodySize,
      height: TypeScale.bodyHeight,
      letterSpacing: 0,
    ),
    // Button Label (bold)
    labelLarge: TextStyle(
      fontFamily: TypeScale.figtree,
      fontWeight: FontWeight.w700,
      fontSize: TypeScale.labelSize,
      height: TypeScale.labelHeight,
      letterSpacing: 0,
    ),
    // Skip / small
    bodySmall: TextStyle(
      fontFamily: TypeScale.inter,
      fontWeight: FontWeight.w500,
      fontSize: TypeScale.smallSize,
      height: TypeScale.smallHeight,
      letterSpacing: 0,
    ),
  );

  /// Builds the app theme configuration.
  static ThemeData buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      // Keep global default as Playfair to avoid unexpected fallbacks for styles
      fontFamily: TypeScale.playfair,
      colorScheme: _buildColorScheme(),
      textTheme: _buildTextTheme(),
      // Button global stylen wie Figma
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      extensions: const <ThemeExtension<dynamic>>[DsTokens.light],
    );
  }

  static ColorScheme _buildColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _accentSubtle, // für "Superkraft."
      onPrimary: _onPrimary,
      onSurface: _onSurface,
      outlineVariant: _grayscale400, // für Dots inactive (mit Opacity)
    );
  }

  static TextTheme _buildTextTheme() => _textThemeConst;

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        minimumSize: Size.fromHeight(Sizes.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.s,
          vertical: Spacing.s,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusM),
        ),
        textStyle: const TextStyle(
          fontFamily: TypeScale.figtree,
          fontWeight: FontWeight.w700,
          fontSize: TypeScale.labelSize,
          height: TypeScale.labelHeight,
        ),
        elevation: 0,
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _onSurface,
        textStyle: const TextStyle(
          fontFamily: TypeScale.inter,
          fontWeight: FontWeight.w500,
          fontSize: TypeScale.smallSize,
          height: TypeScale.smallHeight,
        ),
      ),
    );
  }
}

/// Design System tokens not covered by Material ColorScheme.
/// Extendable for dark mode or brand variants without touching widgets.
@immutable
class DsTokens extends ThemeExtension<DsTokens> {
  const DsTokens({
    required this.cardSurface,
    required this.cardBorderSelected,
    required this.inputBorder,
    required this.grayscale500,
  });

  final Color cardSurface; // Grayscale/100 (#F7F7F8)
  final Color cardBorderSelected; // Secondary/100 (#1C1411)
  final Color inputBorder; // Neutral border for inputs
  final Color grayscale500; // Placeholder / secondary text

  static const DsTokens light = DsTokens(
    cardSurface: Color(0xFFF7F7F8),
    cardBorderSelected: Color(0xFF1C1411),
    inputBorder: Color(0xFFDCDCDC),
    grayscale500: Color(0xFF696969),
  );

  @override
  DsTokens copyWith({
    Color? cardSurface,
    Color? cardBorderSelected,
    Color? inputBorder,
    Color? grayscale500,
  }) => DsTokens(
    cardSurface: cardSurface ?? this.cardSurface,
    cardBorderSelected: cardBorderSelected ?? this.cardBorderSelected,
    inputBorder: inputBorder ?? this.inputBorder,
    grayscale500: grayscale500 ?? this.grayscale500,
  );

  @override
  DsTokens lerp(ThemeExtension<DsTokens>? other, double t) {
    if (other is! DsTokens) return this;
    return DsTokens(
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t) ?? cardSurface,
      cardBorderSelected:
          Color.lerp(cardBorderSelected, other.cardBorderSelected, t) ??
          cardBorderSelected,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t) ?? inputBorder,
      grayscale500:
          Color.lerp(grayscale500, other.grayscale500, t) ?? grayscale500,
    );
  }
}
