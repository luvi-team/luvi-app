// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Audit Test: Core→Feature Boundary Enforcement
///
/// This test enforces the Clean Architecture guardrail:
/// "lib/core/** must never import lib/features/**"
///
/// The only exception is lib/router.dart which is the composition layer
/// that connects core navigation infrastructure with feature screens.
///
/// Run: flutter test test/dev/audit/core_feature_boundary_test.dart
void main() {
  group('Core→Feature Boundary Audit', () {
    late Directory libDir;
    late Directory coreDir;

    setUpAll(() {
      // Find lib directory relative to test file
      final testDir = Directory.current;
      libDir = Directory(p.join(testDir.path, 'lib'));
      coreDir = Directory(p.join(libDir.path, 'core'));

      if (!libDir.existsSync()) {
        fail('lib/ directory not found at ${libDir.path}');
      }
      if (!coreDir.existsSync()) {
        fail('lib/core/ directory not found at ${coreDir.path}');
      }
    });

    test('lib/core/** must not import lib/features/**', () {
      final violations = <String>[];

      // Scan all Dart files in lib/core/
      final coreFiles = coreDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in coreFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];

          // Check for feature imports
          // Patterns:
          // - import 'package:luvi_app/features/
          // - import '../features/
          // - import '../../features/
          // - export 'package:luvi_app/features/
          final hasFeatureImport = line.contains("import 'package:luvi_app/features/") ||
              line.contains("import '../features/") ||
              line.contains("import '../../features/") ||
              line.contains("import '../../../features/") ||
              line.contains("export 'package:luvi_app/features/") ||
              RegExp(r"import\s+'[^']*features/").hasMatch(line);

          if (hasFeatureImport) {
            final relativePath = p.relative(file.path, from: libDir.parent.path);
            violations.add('$relativePath:${i + 1}: $line');
          }
        }
      }

      if (violations.isNotEmpty) {
        final message = StringBuffer()
          ..writeln('Found ${violations.length} Core→Feature import violation(s):')
          ..writeln()
          ..writeln('GUARDRAIL: lib/core/** must never import lib/features/**')
          ..writeln()
          ..writeln('Violations:');

        for (final v in violations) {
          message.writeln('  - $v');
        }

        message
          ..writeln()
          ..writeln('Fix: Move feature-importing code to lib/router.dart or')
          ..writeln('     extract pure helpers to lib/core/** without feature deps.');

        fail(message.toString());
      }
    });

    test('lib/features/**/widgets/** must not import screens/', () {
      final violations = <String>[];
      final featuresDir = Directory(p.join(libDir.path, 'features'));

      if (!featuresDir.existsSync()) {
        return; // No features directory, nothing to check
      }

      // Find all widget files
      final widgetFiles = featuresDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.dart') &&
              f.path.contains('${p.separator}widgets${p.separator}'));

      for (final file in widgetFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];

          // Check for screen imports from widgets
          // Patterns:
          // - import '...screens/...'
          // - import 'package:luvi_app/features/.../screens/...'
          final hasScreenImport =
              RegExp(r"import\s+'[^']*screens/[^']+\.dart'").hasMatch(line);

          if (hasScreenImport) {
            final relativePath = p.relative(file.path, from: libDir.parent.path);
            violations.add('$relativePath:${i + 1}: $line');
          }
        }
      }

      if (violations.isNotEmpty) {
        final message = StringBuffer()
          ..writeln('Found ${violations.length} Widget→Screen import violation(s):')
          ..writeln()
          ..writeln('GUARDRAIL: lib/features/**/widgets/** must not import screens/')
          ..writeln()
          ..writeln('Violations:');

        for (final v in violations) {
          message.writeln('  - $v');
        }

        message
          ..writeln()
          ..writeln('Fix: Use RoutePaths constants from lib/core/navigation/route_paths.dart')
          ..writeln('     instead of importing screens directly.');

        fail(message.toString());
      }
    });

    test('lib/router.dart exists as composition layer', () {
      final routerFile = File(p.join(libDir.path, 'router.dart'));
      expect(
        routerFile.existsSync(),
        isTrue,
        reason: 'lib/router.dart must exist as the router composition layer. '
            'This file is the only place allowed to import features for routing.',
      );
    });

    test('lib/core/navigation/route_paths.dart exists as SSOT', () {
      final routePathsFile = File(p.join(coreDir.path, 'navigation', 'route_paths.dart'));
      expect(
        routePathsFile.existsSync(),
        isTrue,
        reason: 'lib/core/navigation/route_paths.dart must exist as the SSOT for route paths.',
      );
    });

    test('lib/core/config/legal_actions.dart exists without feature imports', () {
      final legalActionsFile = File(p.join(coreDir.path, 'config', 'legal_actions.dart'));
      expect(
        legalActionsFile.existsSync(),
        isTrue,
        reason: 'lib/core/config/legal_actions.dart must exist for legal link openers.',
      );

      // Verify no feature imports
      final content = legalActionsFile.readAsStringSync();
      expect(
        content.contains("import 'package:luvi_app/features/"),
        isFalse,
        reason: 'legal_actions.dart must not import features (uses RoutePaths fallback).',
      );
    });
  });
}
