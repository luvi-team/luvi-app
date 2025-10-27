import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/screens/onboarding/utils/date_formatters.dart';

void main() {
  test('germanDayMonthYear renders 5 Mai 2002', () {
    expect(
      DateFormatters.germanDayMonthYear(DateTime(2002, 5, 5)),
      '5 Mai 2002',
    );
  });
}
