import 'package:flutter/material.dart';

/// Minimal theme scaffold for the LUVI app.
/// This is a placeholder for future design system implementation.
class AppTheme {
  /// Builds the app theme configuration.
  static ThemeData buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      textTheme: const TextTheme(
        // from Figma: Heading/H1 - Playfair Display Regular 32/40
        displayLarge: TextStyle(
          fontFamily: 'Playfair Display', // TODO(fonts): wire via assets
          fontSize: 32, // from Figma: Heading/H1 size
          height: 1.25, // from Figma: 40/32 = 1.25
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        // Mappe auch headlineMedium auf den gleichen Playfair-Style,
        // damit der bestehende Screen exakt rendert.
        headlineMedium: TextStyle(
          fontFamily: 'Playfair Display', // TODO(fonts): wire via assets
          fontSize: 32, // from Figma: Heading/H1 size
          height: 1.25, // 40/32
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        // from Figma: Body/Regular - Figtree Regular 20/24
        bodyMedium: TextStyle(
          fontFamily: 'Figtree', // TODO(fonts): wire via assets
          fontSize: 20, // from Figma: Body/Regular size
          height: 1.2, // from Figma: 24/20 = 1.2
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
      // Add theme customizations here as needed
    );
  }
}
