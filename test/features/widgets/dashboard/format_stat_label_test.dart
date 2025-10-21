import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/widgets/dashboard/stats_scroller.dart';

void main() {
  group('formatStatLabelForTest', () {
    test('returns simple label unchanged', () {
      expect(formatStatLabelForTest('Kalorien'), 'Kalorien');
    });

    test('trims surrounding whitespace and line breaks', () {
      expect(formatStatLabelForTest('  Schlaf \n '), 'Schlaf');
    });

    test('wraps two-word label when exceeding threshold', () {
      expect(formatStatLabelForTest('Aktive Minuten'), 'Aktive\nMinuten');
    });
  });
}
