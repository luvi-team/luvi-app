import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LUVI Design Tokens - Mapping für Figma → Flutter Theme
/// Definiert das zentrale Theme basierend auf Figma Variables
class LuviTokens {
  LuviTokens._();

  /// LUVI ThemeData basierend auf Figma Variables
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: _colorScheme.surface,
    );
  }

  /// Farbschema basierend auf Figma Variables
  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    // Seed approximates Figma Primary color/100 without hex literals
    seedColor: Colors.brown.shade300,
    brightness: Brightness.light,
  );

  /// Typografie basierend auf Figma Variables
  static TextTheme get _textTheme {
    return TextTheme(
      // Figma: Heading/H1 (Playfair Display Regular, 32px, 400, 40px line-height)
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 40 / 32, // line-height / font-size
      ),
      
      // Figma: Caption 1 (Inter Semi Bold, 18px, 600, 27px line-height)
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 27 / 18,
      ),
      
      // Figma: Regular klein (Figtree Regular, 16px, 400, 24px line-height)
      bodyMedium: GoogleFonts.figtree(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      ),
      
      // Figma: Callout (Inter Medium, 16px, 500, 24px line-height)
      titleSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
    );
  }
}

/// Convenience-Klasse für direkten Zugriff auf Design Tokens
class LuviDesignTokens {
  LuviDesignTokens.of(this.context);
  final BuildContext context;

  // Farben via Theme
  Color get primary => Theme.of(context).colorScheme.primary;
  Color get surface => Theme.of(context).colorScheme.surface;
  Color get onSurface => Theme.of(context).colorScheme.onSurface;
  Color get outline => Theme.of(context).colorScheme.outline;
  Color get surfaceContainerHighest => Theme.of(context).colorScheme.surfaceContainerHighest;
  Color get surfaceContainerHigh => Theme.of(context).colorScheme.surfaceContainerHigh;
  
  // Typography via Theme
  TextStyle? get h1 => Theme.of(context).textTheme.headlineLarge;
  TextStyle? get body => Theme.of(context).textTheme.bodyMedium;
  TextStyle? get callout => Theme.of(context).textTheme.titleSmall;
  TextStyle? get caption => Theme.of(context).textTheme.titleMedium;

  // Spacing
  SizedBox get gap16 => const SizedBox(height: 16, width: 16);
  SizedBox get gap24 => const SizedBox(height: 24, width: 24);
}

/// Figma Variable Mapping Configuration
/// Für automatische Code-Generation via @figma get_code
class FigmaVariableMapping {
  /// Color mappings: Figma Variable Name → Flutter Theme Property
  static const Map<String, String> colors = {
    'Grayscale/White': 'Theme.of(context).colorScheme.surface',
    'Grayscale/Black': 'Theme.of(context).colorScheme.onSurface',
    'Grayscale/100': 'Theme.of(context).colorScheme.surfaceContainerHighest',
    'Grayscale/200': 'Theme.of(context).colorScheme.surfaceContainerHigh',
    'Grayscale/400': 'Theme.of(context).colorScheme.outlineVariant',
    'Grayscale/500': 'Theme.of(context).colorScheme.outline',
    'Primary color/100': 'Theme.of(context).colorScheme.primary',
  };

  /// Typography mappings: Figma Variable Name → Flutter Theme Property
  static const Map<String, String> typography = {
    'Heading/H1': 'Theme.of(context).textTheme.headlineLarge',
    'Caption 1': 'Theme.of(context).textTheme.titleMedium',
    'Regular klein': 'Theme.of(context).textTheme.bodyMedium',
    'Callout': 'Theme.of(context).textTheme.titleSmall',
  };

  /// Spacing mappings: Figma Variable Name → Flutter Widget
  static const Map<String, String> spacing = {
    'spacing/16': 'const SizedBox(height: 16)',
    'spacing/24': 'const SizedBox(height: 24)',
  };
}
