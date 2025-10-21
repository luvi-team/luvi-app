import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Orientation-specific layout constructs stay audited', () {
    final libDir = Directory('lib');
    final suspectFiles = <String>{};
    final patterns = [
      RegExp(r'OrientationBuilder'),
      RegExp(r'MediaQuery\.of\([^\)]+\)\.orientation'),
    ];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final contents = entity.readAsStringSync();
      final matchesPattern = patterns.any((pattern) => pattern.hasMatch(contents));
      if (matchesPattern) {
        suspectFiles.add(entity.path);
      }
    }

    expect(
      suspectFiles,
      isEmpty,
      reason:
          'Orientation-aware widgets detected. Update route overrides or allowed list for: ${suspectFiles.join(', ')}',
    );
  });
}
