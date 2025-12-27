import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('Asset smoke tests', () {
    test('loads onboarding content card image', () async {
      final data = await rootBundle.load(Assets.images.onboardingContentCard1);
      expect(data.lengthInBytes, greaterThan(0));
    });

    test('loads onboarding success celebration animation', () async {
      final jsonString = await rootBundle.loadString(
        Assets.animations.onboardingSuccessCelebration,
      );
      expect(jsonString, isNotEmpty);

      final decoded = jsonDecode(jsonString);
      expect(decoded, isA<Map<String, dynamic>>());
      expect(decoded, isNotEmpty);
    });
  });
}
