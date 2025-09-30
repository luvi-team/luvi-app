import 'package:flutter_test/flutter_test.dart';

String formatDateGerman(DateTime d) {
  // minimal formatter for spec test (keine intl-Abhängigkeit)
  const months = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

void main() {
  test('formatDateGerman renders 5 Mai 2002', () {
    expect(formatDateGerman(DateTime(2002, 5, 5)), '5 Mai 2002');
  });
}
