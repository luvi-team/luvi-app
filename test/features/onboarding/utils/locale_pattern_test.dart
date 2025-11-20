import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luvi_app/features/onboarding/utils/date_formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    await initializeDateFormatting('en');
  });

  group('Locale resolution (allowlist + canonicalization)', () {
    test('resolves supported tags to base language', () {
      expect(resolveSupportedLocale2('en'), 'en');
      expect(resolveSupportedLocale2('EN'), 'en');
      expect(resolveSupportedLocale2('en-US'), 'en');
      expect(resolveSupportedLocale2('de-DE'), 'de');
      expect(resolveSupportedLocale2('de'), 'de');
    });

    test('rejects malformed or unsupported tags', () {
      expect(resolveSupportedLocale2(''), isNull);
      expect(resolveSupportedLocale2('a'), isNull);
      expect(resolveSupportedLocale2('en--US'), isNull);
      expect(resolveSupportedLocale2('en-US-'), isNull);
      expect(resolveSupportedLocale2('x-private'), isNull);
      expect(resolveSupportedLocale2('pt-BR'), isNull); // not in supportedLocales
      expect(resolveSupportedLocale2('zh-Hans-CN'), isNull); // not supported
    });
  });

  group('localizedDayMonthYear formatting safety', () {
    test('formats without throwing for valid/invalid tags', () {
      final date = DateTime(2002, 5, 5);
      // Supported
      final en = DateFormatters.localizedDayMonthYear(date, localeName: 'en');
      final de = DateFormatters.localizedDayMonthYear(date, localeName: 'de');
      expect(en.isNotEmpty, isTrue);
      expect(de.isNotEmpty, isTrue);

      // Unsupported or odd but parseable tags fall back gracefully
      final pt = DateFormatters.localizedDayMonthYear(date, localeName: 'pt-BR');
      final priv = DateFormatters.localizedDayMonthYear(date, localeName: 'x-private');
      final malformed = DateFormatters.localizedDayMonthYear(date, localeName: 'en--US');
      expect(pt.isNotEmpty, isTrue);
      expect(priv.isNotEmpty, isTrue);
      expect(malformed.isNotEmpty, isTrue);
    });
  });
}
