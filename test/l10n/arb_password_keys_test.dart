import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('l10n granular password keys', () {
    // Keys that must exist in every locale ARB file.
    const requiredKeys = <String>{
      'authErrPasswordTooShort',
      'authErrPasswordMissingTypes',
      'authErrPasswordCommonWeak',
    };

    test('every app_*.arb contains required password keys', () async {
      final dir = Directory('lib/l10n');
      expect(await dir.exists(), isTrue,
          reason: 'lib/l10n directory must exist');

      final arbFiles = await dir
          .list()
          .where((e) => e is File && e.path.endsWith('.arb'))
          .cast<File>()
          .where((f) => RegExp(r'app_[a-z]{2}(_[A-Z]{2})?\.arb|app_[a-z]{2}(_[a-zA-Z0-9_]+)?\.arb')
              .hasMatch(f.uri.pathSegments.last))
          .toList();

      expect(arbFiles, isNotEmpty, reason: 'No ARB files found in lib/l10n');

      final failures = <String, Set<String>>{}; // file -> missing keys

      for (final file in arbFiles) {
        final raw = await file.readAsString();
        final jsonMap = json.decode(raw) as Map<String, dynamic>;
        final keys = jsonMap.keys.toSet();
        final missing = requiredKeys.difference(keys);
        if (missing.isNotEmpty) {
          failures[file.path] = missing;
        }
      }

      if (failures.isNotEmpty) {
        final buf = StringBuffer('Missing required password keys in ARB files:\n');
        failures.forEach((path, missing) {
          buf.writeln(' - $path: missing ${missing.join(', ')}');
        });
        fail(buf.toString());
      }
    });
  });
}

