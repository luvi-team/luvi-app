import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardrail audit for LUVI UI code.
///
/// Goal: prevent *new* hardcoded Colors/Strings from entering `lib/features/**`.
/// Existing offenders stay allowlisted below until dedicated cleanup tasks fix
/// them. If you truly need a waiver, update the matching allowlist with a TODO
/// plus context so we can remove it later.
void main() {
  test('features avoid new hardcoded Colors & German UI strings', () {
    final featuresDir = Directory('lib/features');
    expect(featuresDir.existsSync(), isTrue,
        reason: 'Expected lib/features directory for UI audit.');

    const allowedColorFiles = <String>{
      'lib/features/dashboard/widgets/wearable_connect_card.dart',
      'lib/features/cycle/widgets/cycle_inline_calendar.dart',
      'lib/features/dashboard/widgets/hero_sync_preview.dart',
      'lib/features/dashboard/widgets/weekly_training_card.dart',
      'lib/features/dashboard/widgets/recommendation_card.dart',
      'lib/features/dashboard/widgets/top_recommendation_tile.dart',
      'lib/features/dashboard/widgets/stats_scroller.dart',
      'lib/features/dashboard/widgets/phase_recommendations_section.dart',
      'lib/features/dashboard/screens/heute_screen.dart',
      'lib/features/cycle/screens/cycle_overview_stub.dart',
      'lib/features/onboarding/widgets/goal_card.dart',
      'lib/features/dashboard/widgets/cycle_tip_card.dart',
      'lib/features/consent/screens/consent_02_screen.dart',
      'lib/features/dashboard/widgets/weekly_training_section.dart',
      'lib/features/dashboard/widgets/bottom_nav_dock.dart',
      'lib/features/dashboard/widgets/section_header.dart',
      'lib/features/dashboard/widgets/floating_sync_button.dart',
      'lib/features/dashboard/widgets/heute_header.dart',
      'lib/features/dashboard/widgets/category_chip.dart',
      'lib/features/dashboard/widgets/painters/bottom_wave_border_painter.dart',
    };

    const allowedGermanStringFiles = <String>{
      'lib/features/onboarding/screens/onboarding_07.dart',
      'lib/features/consent/widgets/localized_builder.dart',
      'lib/features/consent/widgets/welcome_shell.dart',
      'lib/features/consent/model/consent_types.dart',
      'lib/features/auth/state/login_state.dart',
      'lib/features/auth/widgets/login_header.dart',
      'lib/features/cycle/widgets/cycle_inline_calendar.dart',
      'lib/features/auth/screens/auth_entry_screen.dart',
      'lib/features/cycle/domain/date_utils.dart',
      'lib/features/auth/utils/name_validator.dart',
      'lib/features/dashboard/data/fixtures/heute_fixtures.dart',
    };

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

    final colorViolations = <String>{};
    final stringViolations = <String>{};

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

      // Check for German UI strings
      bool looksGerman(String literal) {
        return umlautPattern.hasMatch(literal) ||
            keywordPattern.hasMatch(literal);
      }

      bool hasGermanUiString = false;
      for (final match in textLiteralPattern.allMatches(source)) {
        final literal = match.group(1) ?? '';
        if (looksGerman(literal)) {
          hasGermanUiString = true;
          break;
        }
      }
      if (!hasGermanUiString) {
        for (final match in labelPattern.allMatches(source)) {
          final literal = match.group(1) ?? '';
          if (looksGerman(literal)) {
            hasGermanUiString = true;
            break;
          }
        }
      }

      if (hasGermanUiString &&
          !allowedGermanStringFiles.contains(normalizedPath)) {
        stringViolations.add(normalizedPath);
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
  });
}
