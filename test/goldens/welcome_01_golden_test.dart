import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:luvi_app/features/consent/screens/welcome_01.dart';

void main() {
  group('Welcome01 Golden Tests', () {
    testGoldens('welcome_01 header should match snapshot', (tester) async {
      // Set surface size to match Figma design
      await tester.pumpWidgetBuilder(
        const Welcome01Screen(),
        surfaceSize: const Size(428, 926),
        wrapper: materialAppWrapper(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD9B18E),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
        ),
      );

      // Verify golden
      await expectLater(
        find.byType(Welcome01Screen),
        matchesGoldenFile('goldens/welcome_01_header.png'),
      );
    });
  });
}