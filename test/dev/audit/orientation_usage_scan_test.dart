import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Remove comments and string literals to ensure orientation scans only inspect
/// executable code, preventing false positives from documentation snippets.
String _stripCommentsAndStrings(String source) {
  final buffer = StringBuffer();
  int index = 0;

  String? _peek(int offset) =>
      index + offset < source.length ? source[index + offset] : null;

  void _skipUntil(String terminator, {bool allowEscapes = true}) {
    while (index < source.length) {
      final char = source[index];
      if (allowEscapes && char == '\\') {
        index += 2;
        continue;
      }
      if (source.startsWith(terminator, index)) {
        index += terminator.length;
        break;
      }
      index++;
    }
  }

  while (index < source.length) {
    final char = source[index];

    if (char == '/' && _peek(1) == '/') {
      index += 2;
      while (index < source.length && source[index] != '\n') {
        index++;
      }
      continue;
    }

    if (char == '/' && _peek(1) == '*') {
      index += 2;
      while (index + 1 < source.length &&
          !(source[index] == '*' && _peek(1) == '/')) {
        index++;
      }
      index += index < source.length ? 2 : 0;
      continue;
    }

    final isRawStringPrefix =
        (char == 'r' || char == 'R') && (_peek(1) == '\'' || _peek(1) == '"');
    if (char == '\'' ||
        char == '"' ||
        (isRawStringPrefix && index + 1 < source.length)) {
      String quoteChar;
      bool isTriple = false;
      bool allowEscapes = true;

      if (isRawStringPrefix) {
        quoteChar = _peek(1)!;
        allowEscapes = false;
        index += 2;
      } else {
        quoteChar = char;
        index++;
      }

      if (index + 1 < source.length &&
          source[index] == quoteChar &&
          source[index + 1] == quoteChar) {
        isTriple = true;
        index += 2;
      }

      final terminator = isTriple
          ? quoteChar + quoteChar + quoteChar
          : quoteChar;
      _skipUntil(terminator, allowEscapes: allowEscapes);
      continue;
    }

    buffer.write(char);
    index++;
  }

  return buffer.toString();
}

void main() {
  test('Orientation-specific layout constructs stay audited', () {
    final libDir = Directory('lib');
    final suspectFiles = <String>{};
    const allowedPaths = <String>{
      // Intentionally left empty; add relative lib/ paths that are audited elsewhere.
    };
    final patterns = [
      RegExp(r'OrientationBuilder'),
      RegExp(r'MediaQuery\.of\([^\)]+\)\.orientation'),
    ];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final normalizedPath = entity.path.replaceAll('\\', '/');
      if (allowedPaths.contains(normalizedPath)) {
        continue;
      }

      final sanitizedSource = _stripCommentsAndStrings(
        entity.readAsStringSync(),
      );
      final matchesPattern =
          patterns.any((pattern) => pattern.hasMatch(sanitizedSource));
      if (matchesPattern) {
        suspectFiles.add(normalizedPath);
      }
    }

    expect(
      suspectFiles,
      isEmpty,
      reason:
          'Orientation-aware widgets detected outside allowlist ${allowedPaths.isEmpty ? '(currently empty)' : allowedPaths.join(', ')}. Update overrides or extend the allowlist for: ${suspectFiles.join(', ')}',
    );
  });
}
