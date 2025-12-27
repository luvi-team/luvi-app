import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme smoke test', () {
    test('buildAppTheme returns valid ThemeData', () {
      final theme = AppTheme.buildAppTheme();
      expect(theme, isA<ThemeData>());
    });

    test('DsTokens extension is accessible', () {
      final theme = AppTheme.buildAppTheme();
      // DsTokens is defined in app_theme.dart line 182
      final dsTokens = theme.extension<DsTokens>();
      expect(dsTokens, isNotNull);
    });

    test('theme has expected extensions count', () {
      final theme = AppTheme.buildAppTheme();
      // 13 extensions registered in buildAppTheme() lines 108-122
      expect(theme.extensions.length, equals(13));
    });
  });
}
