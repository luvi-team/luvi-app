import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/dashboard/utils/heute_layout_utils.dart';

void main() {
  group('compressFirstRowWidths', () {
    test('shrinks widths proportionally when total exceeds available', () {
      final measured = [80.0, 90.0, 70.0, 60.0];
      final result = compressFirstRowWidths(
        measured: measured,
        contentWidth: 280.0,
        columnCount: 4,
        minGap: 8.0,
        minWidth: 60.0,
      );
      // 3 gaps → 24px, available items width = 256 when content width = 280
      // total measured = 300, shrinkFactor ≈ 0.7866, applying minWidth=60.0
      // Minimum feasible width = 4*60 + 3*8 = 264px, so 280px content width leaves slack
      expect(result.length, 4);

      // Verify all widths respect minWidth
      expect(result[0] >= 60.0, isTrue);
      expect(result[1] >= 60.0, isTrue);
      expect(result[2] >= 60.0, isTrue);
      expect(result[3] >= 60.0, isTrue);

      final totalWidth = result.reduce((a, b) => a + b) + (3 * 8.0);
      // Verify the result respects the contentWidth constraint
      expect(totalWidth, lessThanOrEqualTo(280.0));
    });

    test('returns original widths when they already fit', () {
      final measured = [60.0, 60.0, 60.0, 60.0];
      final result = compressFirstRowWidths(
        measured: measured,
        contentWidth: 300.0,
        columnCount: 4,
        minGap: 8.0,
        minWidth: 60.0,
      );
      expect(result, measured);
    });

    test('throws when constraints cannot be satisfied', () {
      final measured = [80.0, 90.0, 70.0, 60.0];
      expect(
        () => compressFirstRowWidths(
          measured: measured,
          contentWidth: 260.0,
          columnCount: 4,
          minGap: 8.0,
          minWidth: 60.0,
        ),
        throwsArgumentError,
      );
    });
  });
}
