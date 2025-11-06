// Simple CI validator to ensure no DRAFT-labeled files are bundled under assets/.
// Fails with a non-zero exit if any file name or file content contains 'DRAFT'.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final root = Directory('assets');
  if (!await root.exists()) {
    // No assets folder → nothing to validate.
    exit(0);
  }

  final violations = <String>[];

  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final path = entity.path;
    final fileName = path.split(Platform.pathSeparator).last;
    if (fileName.toUpperCase().contains('DRAFT')) {
      violations.add('File name contains DRAFT: $path');
      continue;
    }
    // Best-effort textual scan; ignore binary read errors.
    try {
      final contents = await entity.openRead().transform(utf8.decoder).join();
      if (contents.toUpperCase().contains('DRAFT')) {
        violations.add('File content contains DRAFT: $path');
      }
    } catch (_) {
      // Non-text or unreadable file; ignore.
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('[privacy-gate] OK: No DRAFT markers found under assets/.');
    exit(0);
  }

  stderr.writeln('[privacy-gate] ERROR: Found DRAFT markers under assets/.');
  for (final v in violations) {
    stderr.writeln(' - $v');
  }
  exit(2);
}

