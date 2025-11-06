import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/screens/onboarding/utils/date_formatters.dart';

void main() {
  group('kBcp47LocalePattern validity', () {
    test('valid tags match', () {
      final valid = <String>[
        'en',
        'en-US',
        'pt-BR',
        'zh-Hans-CN',
        'zh-Hant-TW',
        'en-US-u-ca-buddhist',
        'x-private',
      ];
      for (final tag in valid) {
        expect(isLikelyBcp47LocaleTag(tag), isTrue, reason: 'tag=$tag');
        expect(kBcp47LocalePattern.hasMatch(tag), isTrue, reason: 'regex tag=$tag');
      }
    });

    test('invalid tags do not match', () {
      final invalid = <String?>[
        '',
        'a',
        'en--US',
        'en-US-',
        '123',
        'en-abc-def-ghi', // excessive extlang (3) — must be rejected
        null,
      ];
      for (final tag in invalid) {
        expect(isLikelyBcp47LocaleTag(tag), isFalse, reason: 'tag=$tag');
        if (tag != null) {
          expect(kBcp47LocalePattern.hasMatch(tag), isFalse, reason: 'regex tag=$tag');
        }
      }
    });
  });
}
