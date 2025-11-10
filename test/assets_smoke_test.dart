import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Asset smoke tests', () {
    test('loads onboarding success trophy image', () async {
      final data = await rootBundle.load(Assets.images.onboardingSuccessTrophy);
      expect(data.lengthInBytes, greaterThan(0));
    });

    test('loads onboarding success confetti animation', () async {
      final jsonString = await rootBundle.loadString(
        Assets.animations.onboardingSuccessCelebration,
      );
      expect(jsonString, isNotEmpty);

      final dynamic decoded = jsonDecode(jsonString);
      expect(decoded, isA<Map<String, dynamic>>());
      expect((decoded as Map<String, dynamic>).isNotEmpty, isTrue);
    });
  });
}
