import 'package:flutter/material.dart';

/// Zentraler Theme-Builder für konsistentes Design zwischen Dev und Prod.
/// Verhindert Theme-Drift zwischen verschiedenen Umgebungen.
ThemeData buildAppTheme({required Brightness brightness}) {
  const primary = Color(0xFFD9B18E); // Figma Primary 100
  
  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
  );
  
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    // Weitere Customizations können hier zentral hinzugefügt werden:
    // - ElevatedButton Styles
    // - TextButton Styles
    // - Chip Themes
    // - Card Themes
    // etc.
  );
}