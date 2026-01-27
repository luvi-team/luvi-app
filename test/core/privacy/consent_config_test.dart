import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/privacy/consent_config.dart';
import 'package:luvi_app/core/privacy/consent_types.dart';

void main() {
  group('ConsentConfig', () {
    tearDown(() {
      // Reset cache after each test for isolation
      ConsentConfig.resetCacheForTesting();
    });

    group('currentVersion', () {
      test('should be a non-empty string', () {
        expect(ConsentConfig.currentVersion, isA<String>());
        expect(ConsentConfig.currentVersion, isNotEmpty);
      });

      test('should start with "v" prefix', () {
        expect(ConsentConfig.currentVersion.startsWith('v'), isTrue);
      });

      test('should match version format pattern', () {
        final pattern = RegExp(r'^v\d+(?:\.\d+)?$');
        expect(pattern.hasMatch(ConsentConfig.currentVersion), isTrue);
      });
    });

    group('currentVersionInt', () {
      test('should return a positive integer', () {
        expect(ConsentConfig.currentVersionInt, isA<int>());
        expect(ConsentConfig.currentVersionInt, greaterThan(0));
      });

      test('should match major version from currentVersion', () {
        // Extract major version from string (e.g., "v1.0" -> 1)
        final versionMatch =
            RegExp(r'^v(\d+)').firstMatch(ConsentConfig.currentVersion);
        expect(versionMatch, isNotNull);

        final expectedMajor = int.parse(versionMatch!.group(1)!);
        expect(ConsentConfig.currentVersionInt, equals(expectedMajor));
      });

      test('should be cached (returns same value on repeated access)', () {
        final first = ConsentConfig.currentVersionInt;
        final second = ConsentConfig.currentVersionInt;
        expect(first, equals(second));
      });
    });

    group('assertVersionFormatValid', () {
      test('should not throw for valid version format', () {
        expect(() => ConsentConfig.assertVersionFormatValid(), returnsNormally);
      });
    });

    group('requiredScopeNames', () {
      test('should contain all required scope names', () {
        for (final scope in kRequiredConsentScopes) {
          expect(ConsentConfig.requiredScopeNames, contains(scope.name));
        }
      });

      test('should have same length as kRequiredConsentScopes', () {
        expect(
          ConsentConfig.requiredScopeNames.length,
          equals(kRequiredConsentScopes.length),
        );
      });

      test('should be unmodifiable', () {
        expect(
          () => ConsentConfig.requiredScopeNames.add('test'),
          throwsUnsupportedError,
        );
      });
    });

    group('resetCacheForTesting', () {
      test('should allow cache to be recalculated', () {
        // Access to populate cache
        final first = ConsentConfig.currentVersionInt;

        // Reset
        ConsentConfig.resetCacheForTesting();

        // Access again - should still return same value since
        // currentVersion hasn't changed
        final second = ConsentConfig.currentVersionInt;

        expect(first, equals(second));
      });
    });
  });
}
