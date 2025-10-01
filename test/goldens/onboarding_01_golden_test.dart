import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';

void main() {
  testWidgets('golden: onboarding_01', (tester) async {
    // Ensure a consistent viewport size for golden comparisons.
    await tester.binding.setSurfaceSize(const Size(375, 812)); // iPhone X dimensions
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.buildAppTheme(),
      home: const Onboarding01Screen(),
    ));
    // Lock environment for reproducible rendering
    tester.binding.platformDispatcher.localeTestValue = const Locale('de');
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.0;
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Onboarding01Screen),
      matchesGoldenFile('onboarding_01.png'),
    );
  });
}
