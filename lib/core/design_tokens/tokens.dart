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
}
