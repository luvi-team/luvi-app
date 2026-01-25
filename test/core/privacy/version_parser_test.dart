import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/privacy/version_parser.dart';

void main() {
  group('VersionParser.parseMajorVersion', () {
    test('parses v{major} format', () {
      expect(VersionParser.parseMajorVersion('v1'), equals(1));
      expect(VersionParser.parseMajorVersion('v2'), equals(2));
      expect(VersionParser.parseMajorVersion('v10'), equals(10));
    });

    test('parses v{major}.{minor} format', () {
      expect(VersionParser.parseMajorVersion('v1.0'), equals(1));
      expect(VersionParser.parseMajorVersion('v2.5'), equals(2));
      expect(VersionParser.parseMajorVersion('v10.99'), equals(10));
    });

    test('throws on invalid format', () {
      expect(
        () => VersionParser.parseMajorVersion('1.0'),
        throwsFormatException,
      );
      expect(
        () => VersionParser.parseMajorVersion('version1'),
        throwsFormatException,
      );
      expect(
        () => VersionParser.parseMajorVersion('v1.0.1'),
        throwsFormatException,
      );
      expect(
        () => VersionParser.parseMajorVersion(''),
        throwsFormatException,
      );
    });
  });

  group('VersionParser.parseMinorVersion', () {
    test('returns 0 for v{major} format', () {
      expect(VersionParser.parseMinorVersion('v1'), equals(0));
      expect(VersionParser.parseMinorVersion('v2'), equals(0));
    });

    test('parses minor from v{major}.{minor}', () {
      expect(VersionParser.parseMinorVersion('v1.0'), equals(0));
      expect(VersionParser.parseMinorVersion('v1.5'), equals(5));
      expect(VersionParser.parseMinorVersion('v2.99'), equals(99));
    });

    test('throws on invalid format', () {
      expect(
        () => VersionParser.parseMinorVersion('bad'),
        throwsFormatException,
      );
    });
  });

  group('VersionParser.isValidFormat', () {
    test('returns true for valid formats', () {
      expect(VersionParser.isValidFormat('v1'), isTrue);
      expect(VersionParser.isValidFormat('v1.0'), isTrue);
      expect(VersionParser.isValidFormat('v10.99'), isTrue);
    });

    test('returns false for invalid formats', () {
      expect(VersionParser.isValidFormat('1.0'), isFalse);
      expect(VersionParser.isValidFormat('version1'), isFalse);
      expect(VersionParser.isValidFormat('v1.0.1'), isFalse);
      expect(VersionParser.isValidFormat(''), isFalse);
      expect(VersionParser.isValidFormat('v'), isFalse);
    });
  });
}
