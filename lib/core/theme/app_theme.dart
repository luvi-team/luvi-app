import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Zentraler Theme-Builder für konsistentes Design zwischen Dev und Prod.
/// Verhindert Theme-Drift zwischen verschiedenen Umgebungen.
ThemeData buildAppTheme({required Brightness brightness}) {
  const primary = Color(0xFFD9B18E); // Figma Primary 100
  
  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
  );
  
  // Disable runtime fetching for offline font support
  GoogleFonts.config.allowRuntimeFetching = false;
  
  // Create base theme
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
  );
  
  // Configure text theme with Figma-specified fonts
  final textTheme = GoogleFonts.figtreeTextTheme(base.textTheme).copyWith(
    // Headline (Playfair Display 32/40)
    headlineLarge: GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 40 / 32,
    ),
    // Body (Figtree 16/24)
    bodyMedium: GoogleFonts.figtree(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
    ),
    // Callout/CTA (20 Bold)
    titleSmall: GoogleFonts.figtree(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  );
  
  // Configure button themes with Figma specifications
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
  final elevated = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: buttonShape,
      textStyle: GoogleFonts.figtree(fontSize: 20, fontWeight: FontWeight.w700),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
  );
  final textBtn = TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w600),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );
  
  return base.copyWith(
    colorScheme: scheme,
    textTheme: textTheme,
    elevatedButtonTheme: elevated,
    textButtonTheme: textBtn,
  );
}