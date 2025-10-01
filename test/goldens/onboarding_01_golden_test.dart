import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/onboarding_01.dart';

void main() {
  testWidgets('golden: onboarding_01', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.buildAppTheme(),
      home: const Onboarding01Screen(),
    ));
    await expectLater(
      find.byType(Onboarding01Screen),
      matchesGoldenFile('onboarding_01.png'),
    );
  });
}
