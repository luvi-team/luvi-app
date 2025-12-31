import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardrail audit for LUVI UI code.
///
/// Goal: prevent *new* hardcoded Colors/Strings/Spacing from entering `lib/features/**`.
/// Existing offenders stay allowlisted below until dedicated cleanup tasks fix
/// them. If you truly need a waiver, update the matching allowlist with a TODO
/// plus context so we can remove it later.
///
/// MUST-01: Design Tokens only - no hardcoded colors
/// MUST-02: Spacing via tokens - no custom EdgeInsets/BorderRadius/SizedBox with literals
/// MUST-03: L10n first - all user text via AppLocalizations
void main() {
  test('features avoid new hardcoded Colors, Spacing & German UI strings', () {
    final featuresDir = Directory('lib/features');
    expect(featuresDir.existsSync(), isTrue,
        reason: 'Expected lib/features directory for UI audit.');

    const allowedColorFiles = <String>{};

    const allowedGermanStringFiles = <String>{};

    // MUST-02: Spacing tokens allowlist (should stay empty after cleanup)
    const allowedSpacingFiles = <String>{};

    final colorPattern = RegExp(r'Color\s*\(\s*0x[0-9A-Fa-f]{6,8}');
    // Word-boundary ensures we match Flutter's Colors class, not DsColors tokens
    final colorsDotPattern = RegExp(r'\bColors\.');
    final umlautPattern = RegExp(r'[äöüÄÖÜß]');
    final keywordPattern = RegExp(
      r'\b(Registrieren|Einloggen|Willkommen|Zur(?:ück|ueck)|Weiter|Passwort|Hinweis|Bestätigen|Abbrechen|Speichern)\b',
      caseSensitive: false,
    );
    final textLiteralPattern = RegExp(
      r"""(?:const\s+)?Text\s*\(\s*['"]([^'"]+)['"]""",
      multiLine: true,
    );
    final labelPattern = RegExp(
      r"""label\s*:\s*['"]([^'"]+)['"]""",
      multiLine: true,
    );

    // MUST-02: Spacing patterns - detect hardcoded numeric values
    // Matches EdgeInsets with non-zero hardcoded numeric values:
    // - Positional: EdgeInsets.all(16), EdgeInsets.fromLTRB(16, ...)
    // - Named: EdgeInsets.only(top: 4), EdgeInsets.symmetric(horizontal: 8)
    // Excludes: 0 values (no padding), ternary expressions (isFirst ? 12 : 0),
    // and token references (Spacing.m)
    final edgeInsetsPattern = RegExp(
      r'EdgeInsets\.(all|symmetric|only|fromLTRB)\s*\((\s*[1-9]|[^)]*:\s*[1-9])',
    );
    // Matches BorderRadius.circular(8), BorderRadius.circular(16.0), etc.
    final borderRadiusPattern = RegExp(
      r'BorderRadius\.circular\s*\(\s*[0-9]+\.?[0-9]*\s*\)',
    );
    // Matches SizedBox(height: 4), SizedBox(width: 12), etc.
    final sizedBoxPattern = RegExp(
      r'SizedBox\s*\(\s*(height|width)\s*:\s*[0-9]+\.?[0-9]*',
    );

    // Helper functions defined once outside the loop for efficiency
    bool looksGerman(String literal) {
      return umlautPattern.hasMatch(literal) ||
          keywordPattern.hasMatch(literal);
    }

    // Cannot be const: RegExp instances are not compile-time constants.
    // Defined once outside loop to avoid repeated allocation.
    final uiStringPatterns = [textLiteralPattern, labelPattern];

    bool hasGermanUiString(String source) {
      for (final pattern in uiStringPatterns) {
        for (final match in pattern.allMatches(source)) {
          final literal = match.group(1) ?? '';
          if (looksGerman(literal)) {
            return true;
          }
        }
      }
      return false;
    }

    final colorViolations = <String>{};
    final stringViolations = <String>{};
    final spacingViolations = <String>{};

    for (final entity in featuresDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final normalizedPath = entity.path.replaceAll('\\', '/');
      final source = entity.readAsStringSync();

      final hasHardcodedColor = colorPattern.hasMatch(source) ||
          colorsDotPattern.hasMatch(source);
      if (hasHardcodedColor &&
          !allowedColorFiles.contains(normalizedPath)) {
        colorViolations.add(normalizedPath);
      }

      if (hasGermanUiString(source) &&
          !allowedGermanStringFiles.contains(normalizedPath)) {
        stringViolations.add(normalizedPath);
      }

      // MUST-02: Check for hardcoded spacing values
      final hasHardcodedSpacing = edgeInsetsPattern.hasMatch(source) ||
          borderRadiusPattern.hasMatch(source) ||
          sizedBoxPattern.hasMatch(source);
      if (hasHardcodedSpacing && !allowedSpacingFiles.contains(normalizedPath)) {
        spacingViolations.add(normalizedPath);
      }
    }

    expect(
      colorViolations,
      isEmpty,
      reason:
          'Neue hardcodierte Farben in lib/features/** entdeckt. Nutze Design Tokens oder erweitere das erlaubte Set bewusst (mit TODO) – betroffen: ${colorViolations.join(', ')}',
    );

    expect(
      stringViolations,
      isEmpty,
      reason:
          'Neue hardcodierte deutsche UI-Strings gefunden. L10n (`AppLocalizations`) nutzen oder Allowlist pflegen (inkl. TODO) – betroffen: ${stringViolations.join(', ')}',
    );

    // MUST-02: Spacing tokens gate
    expect(
      spacingViolations,
      isEmpty,
      reason:
          'Neue hardcodierte Spacing-Werte gefunden. Nutze Spacing.* oder Sizes.* Tokens – betroffen: ${spacingViolations.join(', ')}',
    );
  });
}
