import 'package:flutter/material.dart';
import '../design_tokens/typography.dart';
import '../design_tokens/spacing.dart';
import '../design_tokens/sizes.dart';

/// Minimal theme scaffold for the LUVI app.
/// This is a placeholder for future design system implementation.
class AppTheme {
  /// Builds the app theme configuration.
  static ThemeData buildAppTheme() {
    // Colors from Figma CSS
    const primary = Color(0xFFD9B18E);       // Primary color/100 (Button bg)
    const accentSubtle = Color(0xFFD9B6A3);  // Accent-Subtle (nur "Superkraft.")
    const onPrimary = Color(0xFFFFFFFF);     // Grayscale/White
    const onSurface = Color(0xFF030401);     // Grayscale/Black
    const grayscale400 = Color(0xFFB0B0B0);  // Grayscale/400 (Dots inactive base)

    return ThemeData(
      useMaterial3: true,
      // Keep global default as Playfair to avoid unexpected fallbacks for styles
      fontFamily: TypeScale.playfair,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accentSubtle, // für "Superkraft."
        onPrimary: onPrimary,
        onSurface: onSurface,
        outlineVariant: grayscale400, // für Dots inactive (mit Opacity)
      ),
      textTheme: const TextTheme(
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
      ),
      // Button global stylen wie Figma
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, Sizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: Spacing.s),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.radiusM)),
          textStyle: const TextStyle(
            fontFamily: TypeScale.figtree,
            fontWeight: FontWeight.w700,
            fontSize: TypeScale.labelSize,
            height: TypeScale.labelHeight,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: onSurface,
          textStyle: const TextStyle(
            fontFamily: TypeScale.inter,
            fontWeight: FontWeight.w500,
            fontSize: TypeScale.smallSize,
            height: TypeScale.smallHeight,
          ),
        ),
      ),
    );
  }
}
