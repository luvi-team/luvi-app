import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luvi_app/features/onboarding/utils/date_formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    await initializeDateFormatting('en');
  });
  test('localizedDayMonthYear respects provided locale', () {
    expect(
      DateFormatters.localizedDayMonthYear(
        DateTime(2002, 5, 5),
        localeName: 'de',
      ),
      '5. Mai 2002',
    );

    expect(
      DateFormatters.localizedDayMonthYear(
        DateTime(2002, 5, 5),
        localeName: 'en',
      ),
      'May 5, 2002',
    );
  });
}
