import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/utils/layout_utils.dart';

void main() {
  group('topOffsetFromSafeArea', () {
    test('returns 0 for negative gap (figmaY < figmaSafeTop)', () {
      expect(
        topOffsetFromSafeArea(12.0, figmaSafeTop: 20.0),
        0,
      );
    });

    test('returns 0 for zero gap (figmaY == figmaSafeTop)', () {
      expect(
        topOffsetFromSafeArea(24.0, figmaSafeTop: 24.0),
        0,
      );
    });

    test('returns positive gap (figmaY > figmaSafeTop)', () {
      expect(
        topOffsetFromSafeArea(40.0, figmaSafeTop: 24.0),
        16.0,
      );
    });
  });
}

