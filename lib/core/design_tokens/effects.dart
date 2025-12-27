import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';

/// Design system effect tokens for glass morphism and other visual effects.
///
/// All effects are derived from Figma designs (2024-12 Onboarding Refactor).
/// BoxDecoration instances are cached as static finals for performance.
class DsEffects {
  const DsEffects._();

  // ─── Opacity Design Tokens ───
  // Background opacity levels for glass morphism
  static const double _opacityLight = 0.10; // 10% - subtle glass
  static const double _opacityMedium = 0.30; // 30% - visible glass
  static const double _opacityStrong = 0.50; // 50% - prominent glass
  static const double _opacityUltra = 0.60; // 60% - solid glass
  static const double _opacityDense = 0.70; // 70% - near-opaque

  // Border opacity levels
  static const double _borderOpacityMedium = 0.60; // 60%
  static const double _borderOpacityStrong = 0.70; // 70%
  static const double _borderOpacityUltra = 0.80; // 80%
  static const double _borderOpacityMax = 0.85; // 85%
  static const double _borderOpacityFull = 0.90; // 90%

  // ─── Pre-computed Colors for Static Initialization ───
  static final Color _glassLight =
      DsColors.white.withValues(alpha: _opacityLight);
  static final Color _glassMedium =
      DsColors.white.withValues(alpha: _opacityMedium);
  static final Color _glassStrong =
      DsColors.white.withValues(alpha: _opacityStrong);
  static final Color _glassUltra =
      DsColors.white.withValues(alpha: _opacityUltra);
  static final Color _glassDense =
      DsColors.white.withValues(alpha: _opacityDense);
  static final Color _borderMedium =
      DsColors.white.withValues(alpha: _borderOpacityMedium);
  static final Color _borderStrong =
      DsColors.white.withValues(alpha: _borderOpacityStrong);
  static final Color _borderUltra =
      DsColors.white.withValues(alpha: _borderOpacityUltra);
  static final Color _borderMax =
      DsColors.white.withValues(alpha: _borderOpacityMax);
  static final Color _borderFull =
      DsColors.white.withValues(alpha: _borderOpacityFull);

  // ─── Cached BoxDecoration Instances ───

  // Basic Glass (1-4)
  static final BoxDecoration _glassCardInstance = BoxDecoration(
    color: _glassLight,
    borderRadius: BorderRadius.circular(Sizes.radiusCard),
  );

  static final BoxDecoration _glassPillInstance = BoxDecoration(
    color: _glassLight,
    borderRadius: BorderRadius.circular(Sizes.radiusPill),
  );

  static final BoxDecoration _glassCalendarInstance = BoxDecoration(
    color: _glassMedium,
    borderRadius: BorderRadius.circular(Sizes.radiusXL),
  );

  static final BoxDecoration _glassMiniCalendarInstance = BoxDecoration(
    color: _glassLight,
    borderRadius: BorderRadius.circular(Sizes.radius24),
  );

  // Enhanced Glassmorphism (5-8)
  static final BoxDecoration _glassCardStrongInstance = BoxDecoration(
    color: _glassMedium,
    borderRadius: BorderRadius.circular(Sizes.radiusL),
    border: Border.all(color: _borderStrong, width: 1.5),
  );

  static final BoxDecoration _glassPillStrongInstance = BoxDecoration(
    color: _glassMedium,
    borderRadius: BorderRadius.circular(Sizes.radiusL),
    border: Border.all(color: _borderMedium, width: 1.5),
  );

  static final BoxDecoration _glassCalendarStrongInstance = BoxDecoration(
    color: _glassStrong,
    borderRadius: BorderRadius.circular(Sizes.radiusXL),
    border: Border.all(color: _borderStrong, width: 1.5),
  );

  static final BoxDecoration _glassMiniCalendarStrongInstance = BoxDecoration(
    color: _glassMedium,
    borderRadius: BorderRadius.circular(Sizes.radius24),
    border: Border.all(color: _borderStrong, width: 1.5),
  );

  // Success Cards (9-12)
  static final BoxDecoration _successCardGlassInstance = BoxDecoration(
    color: DsColors.successCardGlass,
    borderRadius: BorderRadius.circular(Sizes.radius16),
  );

  static final BoxDecoration _successCardPurpleInstance = BoxDecoration(
    color: DsColors.successCardPurple,
    borderRadius: BorderRadius.circular(Sizes.radius16),
    border: Border.all(color: _borderStrong, width: 1.5),
  );

  static final BoxDecoration _successCardCyanInstance = BoxDecoration(
    color: DsColors.successCardCyan,
    borderRadius: BorderRadius.circular(Sizes.radius16),
    border: Border.all(color: _borderStrong, width: 1.5),
  );

  static final BoxDecoration _successCardPinkInstance = BoxDecoration(
    color: DsColors.successCardPink,
    borderRadius: BorderRadius.circular(Sizes.radius16),
    border: Border.all(color: _borderStrong, width: 1.5),
  );

  // Figma v3 Onboarding Effects (13-17)
  static final BoxDecoration _glassOnboardingInput10Instance = BoxDecoration(
    color: _glassLight,
    borderRadius: BorderRadius.circular(Sizes.radius16),
  );

  static final BoxDecoration _glassOnboardingPickerTransparent16Instance =
      BoxDecoration(
    color: DsColors.transparent,
    borderRadius: BorderRadius.circular(Sizes.radius16),
  );

  static final BoxDecoration _glassOnboardingOptionTransparent16Instance =
      BoxDecoration(
    color: DsColors.transparent,
    borderRadius: BorderRadius.circular(Sizes.radius16),
  );

  static final BoxDecoration _glassOnboardingMiniCalendar10Instance =
      BoxDecoration(
    color: _glassLight,
    borderRadius: BorderRadius.circular(Sizes.radius24),
  );

  static final BoxDecoration _glassOnboardingCalendar30Instance = BoxDecoration(
    color: _glassMedium,
    borderRadius: BorderRadius.circular(Sizes.radiusXL),
  );

  // Ultra-Strong Glass Effects (18-20)
  static final BoxDecoration _glassCardUltraInstance = BoxDecoration(
    color: _glassUltra,
    borderRadius: BorderRadius.circular(Sizes.radiusL),
    border: Border.all(color: _borderMax, width: 2.0),
  );

  static final BoxDecoration _glassPillUltraInstance = BoxDecoration(
    color: _glassUltra,
    borderRadius: BorderRadius.circular(Sizes.radiusL),
    border: Border.all(color: _borderUltra, width: 2.0),
  );

  static final BoxDecoration _glassCalendarUltraInstance = BoxDecoration(
    color: _glassDense,
    borderRadius: BorderRadius.circular(Sizes.radiusXL),
    border: Border.all(color: _borderFull, width: 2.0),
  );

  // ─── Public Getters (Return Cached Instances) ───

  /// Glass Card Effect - 10% white opacity background with 16px radius
  /// Used for: Name input container (O1), BirthdatePicker container (O2)
  static BoxDecoration get glassCard => _glassCardInstance;

  /// Glass Pill Effect - 10% white opacity background with full pill radius
  /// Used for: Fitness pills (O3), Interest pills (O5)
  static BoxDecoration get glassPill => _glassPillInstance;

  /// Glass Calendar Container - 30% white opacity with 40px radius
  /// Used for: Period calendar containers (O7, O8)
  static BoxDecoration get glassCalendar => _glassCalendarInstance;

  /// Glass Mini Calendar Container - 10% white opacity with 24px radius
  /// Used for: Calendar mini widget on cycle intro (O6)
  static BoxDecoration get glassMiniCalendar => _glassMiniCalendarInstance;

  // ─── Enhanced Glassmorphism for Onboarding (Figma v3 2024-12) ───
  // These variants have stronger glass effect without affecting existing app styles

  /// Strong Glass Card - 30% white opacity + white border for enhanced visibility
  /// Used for: O1 name input, O2 birthdate picker, O4/O5 goal/interest cards
  static BoxDecoration get glassCardStrong => _glassCardStrongInstance;

  /// Strong Glass Pill - 30% white opacity + white border
  /// Used for: O3 fitness level pills (rounded-rect, not pill)
  static BoxDecoration get glassPillStrong => _glassPillStrongInstance;

  /// Strong Glass Calendar - 50% white opacity + white border
  /// Used for: O7/O8 period calendar containers
  static BoxDecoration get glassCalendarStrong => _glassCalendarStrongInstance;

  /// Strong Glass Mini Calendar - 30% white opacity + white border
  /// Used for: O6 calendar mini widget
  static BoxDecoration get glassMiniCalendarStrong =>
      _glassMiniCalendarStrongInstance;

  /// Success Card Glass - Figma O9 specs: #E9D5FF @ 20%, 16px radius
  /// @deprecated Use [successCardPurple], [successCardCyan], or [successCardPink] instead.
  /// Note: No border per Figma O9 design
  @Deprecated('Use successCardPurple, successCardCyan, or successCardPink instead')
  static BoxDecoration get successCardGlass => _successCardGlassInstance;

  /// O9 Success Card 1 (left/top) - Purple (#E9D5FF @ 20%), 16px radius
  /// Figma v3: White border 70% opacity, 1.5px width
  static BoxDecoration get successCardPurple => _successCardPurpleInstance;

  /// O9 Success Card 2 (right) - Cyan (#CFFAFE @ 20%), 16px radius
  /// Figma v3: White border 70% opacity, 1.5px width
  static BoxDecoration get successCardCyan => _successCardCyanInstance;

  /// O9 Success Card 3 (bottom) - Pink (#FCE7F3 @ 20%), 16px radius
  /// Figma v3: White border 70% opacity, 1.5px width
  static BoxDecoration get successCardPink => _successCardPinkInstance;

  // ─── Figma v3 Onboarding Effects (2024-12 Parity) ───
  // These effects match Figma exactly - NO additional borders unless Figma specifies

  /// O1 Name Input - 10% white opacity, 16px radius (Figma v3 exact)
  /// Used for: Name text input container
  static BoxDecoration get glassOnboardingInput10 =>
      _glassOnboardingInput10Instance;

  /// O2 Birthdate Picker - Transparent background, 16px radius (Figma v3 exact)
  /// Used for: Birthdate picker container
  static BoxDecoration get glassOnboardingPickerTransparent16 =>
      _glassOnboardingPickerTransparent16Instance;

  /// O3/O4/O5 Options - Transparent background, 16px radius (Figma v3 exact)
  /// Used for: Fitness pills, Goal cards, Interest cards (unselected)
  static BoxDecoration get glassOnboardingOptionTransparent16 =>
      _glassOnboardingOptionTransparent16Instance;

  /// O6 Mini Calendar - 10% white opacity, 24px radius (Figma v3 exact)
  /// Used for: Calendar mini widget on cycle intro
  static BoxDecoration get glassOnboardingMiniCalendar10 =>
      _glassOnboardingMiniCalendar10Instance;

  /// O7/O8 Calendar - 30% white opacity, 40px radius (Figma v3 exact)
  /// Used for: Period calendar containers
  static BoxDecoration get glassOnboardingCalendar30 =>
      _glassOnboardingCalendar30Instance;

  // ─── Ultra-Strong Glass Effects (Figma v3 Polish 2024-12) ───
  // These effects have enhanced opacity and borders for pixel-perfect Figma match

  /// Ultra Glass Card - 60% white opacity + 85% white border, 2px width
  /// Used for: O1 name input, O2 birthdate picker (Figma v3 polish)
  static BoxDecoration get glassCardUltra => _glassCardUltraInstance;

  /// Ultra Glass Pill - 60% white opacity + 80% white border, 2px width
  /// Used for: O3 fitness level pills (Figma v3 polish)
  static BoxDecoration get glassPillUltra => _glassPillUltraInstance;

  /// Ultra Glass Calendar - 70% white opacity + 90% white border, 2px width
  /// Used for: O7/O8 period calendar containers (Figma v3 polish)
  static BoxDecoration get glassCalendarUltra => _glassCalendarUltraInstance;
}
