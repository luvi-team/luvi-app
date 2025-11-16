import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/onboarding_success_tokens.dart';

void main() {
  group('OnboardingSuccessTokens.celebrationConfig', () {
    test('returns min scale/offset at small viewport heights', () {
      final config = OnboardingSuccessTokens.celebrationConfig(
        viewHeight: 640,
        textScaleFactor: 1.0,
      );

      expect(config.scale, closeTo(OnboardingSuccessTokens.minScale, 1e-9));
      expect(
        config.baselineOffset,
        closeTo(OnboardingSuccessTokens.minBaselineOffset, 1e-9),
      );
    });

    test('returns max scale/offset at tall viewport heights', () {
      final config = OnboardingSuccessTokens.celebrationConfig(
        viewHeight: 1500,
        textScaleFactor: 1.0,
      );

      expect(config.scale, closeTo(OnboardingSuccessTokens.maxScale, 1e-9));
      expect(
        config.baselineOffset,
        closeTo(OnboardingSuccessTokens.maxBaselineOffset, 1e-9),
      );
    });

    test('clamps values below minimum viewport height', () {
      final config = OnboardingSuccessTokens.celebrationConfig(
        viewHeight: 320,
        textScaleFactor: 1.0,
      );


      expect(config.scale, closeTo(OnboardingSuccessTokens.minScale, 1e-9));
      expect(config.baselineOffset, closeTo(OnboardingSuccessTokens.minBaselineOffset, 1e-9));
    });

    test('clamps values above maximum viewport height', () {
      final config = OnboardingSuccessTokens.celebrationConfig(
        viewHeight: 2400,
        textScaleFactor: 1.0,
      );


      expect(config.scale, closeTo(OnboardingSuccessTokens.maxScale, 1e-9));
      expect(config.baselineOffset, closeTo(OnboardingSuccessTokens.maxBaselineOffset, 1e-9));
    });

    test('is monotonic for scale/baseline when height increases', () {
      final lower = OnboardingSuccessTokens.celebrationConfig(
        viewHeight: 820,
        textScaleFactor: 1.0,
      );
      final higher = OnboardingSuccessTokens.celebrationConfig(
        viewHeight: 1000,
        textScaleFactor: 1.0,
      );

      expect(lower.scale, lessThanOrEqualTo(higher.scale));
      expect(lower.baselineOffset, lessThanOrEqualTo(higher.baselineOffset));
    });

    test('reduces scale when textScaleFactor increases', () {
      final baseConfig = OnboardingSuccessTokens.celebrationConfig(
        viewHeight: 900,
        textScaleFactor: 1.0,
      );
      final scaledConfig = OnboardingSuccessTokens.celebrationConfig(
        viewHeight: 900,
        textScaleFactor: 1.3,
      );

      expect(scaledConfig.scale, lessThan(baseConfig.scale));
      expect(scaledConfig.baselineOffset, lessThan(baseConfig.baselineOffset));
    });
  });
}
