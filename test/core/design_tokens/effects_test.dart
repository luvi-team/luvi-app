import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/effects.dart';

import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('DsEffects caching', () {
    test('glassCard returns identical instance on multiple accesses', () {
      final first = DsEffects.glassCard;
      final second = DsEffects.glassCard;
      expect(identical(first, second), isTrue);
    });

    test('all basic glass decorations return cached instances', () {
      // Basic Glass (1-4)
      expect(identical(DsEffects.glassCard, DsEffects.glassCard), isTrue);
      expect(identical(DsEffects.glassPill, DsEffects.glassPill), isTrue);
      expect(identical(DsEffects.glassCalendar, DsEffects.glassCalendar), isTrue);
      expect(
        identical(DsEffects.glassMiniCalendar, DsEffects.glassMiniCalendar),
        isTrue,
      );
    });

    test('all strong glass decorations return cached instances', () {
      // Enhanced Glassmorphism (5-8)
      expect(
        identical(DsEffects.glassCardStrong, DsEffects.glassCardStrong),
        isTrue,
      );
      expect(
        identical(DsEffects.glassPillStrong, DsEffects.glassPillStrong),
        isTrue,
      );
      expect(
        identical(DsEffects.glassCalendarStrong, DsEffects.glassCalendarStrong),
        isTrue,
      );
      expect(
        identical(
          DsEffects.glassMiniCalendarStrong,
          DsEffects.glassMiniCalendarStrong,
        ),
        isTrue,
      );
    });

    test('all success card decorations return cached instances', () {
      // Success Cards (9-12)
      // Test deprecated getter to ensure it's also cached
      // ignore: deprecated_member_use_from_same_package
      final glass1 = DsEffects.successCardGlass;
      // ignore: deprecated_member_use_from_same_package
      final glass2 = DsEffects.successCardGlass;
      expect(identical(glass1, glass2), isTrue);
      expect(
        identical(DsEffects.successCardPurple, DsEffects.successCardPurple),
        isTrue,
      );
      expect(
        identical(DsEffects.successCardCyan, DsEffects.successCardCyan),
        isTrue,
      );
      expect(
        identical(DsEffects.successCardPink, DsEffects.successCardPink),
        isTrue,
      );
    });

    test('all onboarding glass decorations return cached instances', () {
      // Figma v3 Onboarding Effects (13-17)
      expect(
        identical(
          DsEffects.glassOnboardingInput10,
          DsEffects.glassOnboardingInput10,
        ),
        isTrue,
      );
      expect(
        identical(
          DsEffects.glassOnboardingPickerTransparent16,
          DsEffects.glassOnboardingPickerTransparent16,
        ),
        isTrue,
      );
      expect(
        identical(
          DsEffects.glassOnboardingOptionTransparent16,
          DsEffects.glassOnboardingOptionTransparent16,
        ),
        isTrue,
      );
      expect(
        identical(
          DsEffects.glassOnboardingMiniCalendar10,
          DsEffects.glassOnboardingMiniCalendar10,
        ),
        isTrue,
      );
      expect(
        identical(
          DsEffects.glassOnboardingCalendar30,
          DsEffects.glassOnboardingCalendar30,
        ),
        isTrue,
      );
    });

    test('all ultra glass decorations return cached instances', () {
      // Ultra-Strong Glass Effects (18-20)
      expect(
        identical(DsEffects.glassCardUltra, DsEffects.glassCardUltra),
        isTrue,
      );
      expect(
        identical(DsEffects.glassPillUltra, DsEffects.glassPillUltra),
        isTrue,
      );
      expect(
        identical(DsEffects.glassCalendarUltra, DsEffects.glassCalendarUltra),
        isTrue,
      );
    });
  });
}
