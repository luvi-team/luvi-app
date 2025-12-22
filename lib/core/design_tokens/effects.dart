import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';

/// Design system effect tokens for glass morphism and other visual effects.
///
/// All effects are derived from Figma designs (2024-12 Onboarding Refactor).
class DsEffects {
  const DsEffects._();

  /// Glass Card Effect - 10% white opacity background with 16px radius
  /// Used for: Name input container (O1), BirthdatePicker container (O2)
  static BoxDecoration get glassCard => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      );

  /// Glass Pill Effect - 10% white opacity background with full pill radius
  /// Used for: Fitness pills (O3), Interest pills (O5)
  static BoxDecoration get glassPill => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      );

  /// Glass Calendar Container - 30% white opacity with 40px radius
  /// Used for: Period calendar containers (O7, O8)
  static BoxDecoration get glassCalendar => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(40),
      );

  /// Glass Mini Calendar Container - 10% white opacity with 24px radius
  /// Used for: Calendar mini widget on cycle intro (O6)
  static BoxDecoration get glassMiniCalendar => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      );

  // ─── Enhanced Glassmorphism for Onboarding (Figma v3 2024-12) ───
  // These variants have stronger glass effect without affecting existing app styles

  /// Strong Glass Card - 30% white opacity + white border for enhanced visibility
  /// Used for: O1 name input, O2 birthdate picker, O4/O5 goal/interest cards
  static BoxDecoration get glassCardStrong => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(Sizes.radiusL),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.70),
          width: 1.5,
        ),
      );

  /// Strong Glass Pill - 30% white opacity + white border
  /// Used for: O3 fitness level pills (rounded-rect, not pill)
  static BoxDecoration get glassPillStrong => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(Sizes.radiusL),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.60),
          width: 1.5,
        ),
      );

  /// Strong Glass Calendar - 50% white opacity + white border
  /// Used for: O7/O8 period calendar containers
  static BoxDecoration get glassCalendarStrong => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.70),
          width: 1.5,
        ),
      );

  /// Strong Glass Mini Calendar - 30% white opacity + white border
  /// Used for: O6 calendar mini widget
  static BoxDecoration get glassMiniCalendarStrong => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.70),
          width: 1.5,
        ),
      );

  /// Success Card Glass - Figma O9 specs: #E9D5FF @ 20%, 16px radius
  /// Used for: O9 content preview cards (deprecated - use individual card effects)
  /// Note: No border per Figma O9 design
  static BoxDecoration get successCardGlass => BoxDecoration(
        color: DsColors.successCardGlass,
        borderRadius: BorderRadius.circular(Sizes.radius16),
      );

  /// O9 Success Card 1 (left/top) - Purple (#E9D5FF @ 20%), 16px radius
  /// Figma v3: White border 70% opacity, 1.5px width
  static BoxDecoration get successCardPurple => BoxDecoration(
        color: DsColors.successCardPurple,
        borderRadius: BorderRadius.circular(Sizes.radius16),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.70),
          width: 1.5,
        ),
      );

  /// O9 Success Card 2 (right) - Cyan (#CFFAFE @ 20%), 16px radius
  /// Figma v3: White border 70% opacity, 1.5px width
  static BoxDecoration get successCardCyan => BoxDecoration(
        color: DsColors.successCardCyan,
        borderRadius: BorderRadius.circular(Sizes.radius16),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.70),
          width: 1.5,
        ),
      );

  /// O9 Success Card 3 (bottom) - Pink (#FCE7F3 @ 20%), 16px radius
  /// Figma v3: White border 70% opacity, 1.5px width
  static BoxDecoration get successCardPink => BoxDecoration(
        color: DsColors.successCardPink,
        borderRadius: BorderRadius.circular(Sizes.radius16),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.70),
          width: 1.5,
        ),
      );

  // ─── Figma v3 Onboarding Effects (2024-12 Parity) ───
  // These effects match Figma exactly - NO additional borders unless Figma specifies

  /// O1 Name Input - 10% white opacity, 16px radius (Figma v3 exact)
  /// Used for: Name text input container
  static BoxDecoration get glassOnboardingInput10 => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Sizes.radius16),
      );

  /// O2 Birthdate Picker - Transparent background, 16px radius (Figma v3 exact)
  /// Used for: Birthdate picker container
  static BoxDecoration get glassOnboardingPickerTransparent16 => BoxDecoration(
        color: DsColors.transparent,
        borderRadius: BorderRadius.circular(Sizes.radius16),
      );

  /// O3/O4/O5 Options - Transparent background, 16px radius (Figma v3 exact)
  /// Used for: Fitness pills, Goal cards, Interest cards (unselected)
  static BoxDecoration get glassOnboardingOptionTransparent16 => BoxDecoration(
        color: DsColors.transparent,
        borderRadius: BorderRadius.circular(Sizes.radius16),
      );

  /// O6 Mini Calendar - 10% white opacity, 24px radius (Figma v3 exact)
  /// Used for: Calendar mini widget on cycle intro
  static BoxDecoration get glassOnboardingMiniCalendar10 => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Sizes.radius24),
      );

  /// O7/O8 Calendar - 30% white opacity, 40px radius (Figma v3 exact)
  /// Used for: Period calendar containers
  static BoxDecoration get glassOnboardingCalendar30 => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(Sizes.radiusXL),
      );

  // ─── Ultra-Strong Glass Effects (Figma v3 Polish 2024-12) ───
  // These effects have enhanced opacity and borders for pixel-perfect Figma match

  /// Ultra Glass Card - 60% white opacity + 85% white border, 2px width
  /// Used for: O1 name input, O2 birthdate picker (Figma v3 polish)
  static BoxDecoration get glassCardUltra => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(Sizes.radiusL),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.85),
          width: 2.0,
        ),
      );

  /// Ultra Glass Pill - 60% white opacity + 80% white border, 2px width
  /// Used for: O3 fitness level pills (Figma v3 polish)
  static BoxDecoration get glassPillUltra => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(Sizes.radiusL),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.80),
          width: 2.0,
        ),
      );

  /// Ultra Glass Calendar - 70% white opacity + 90% white border, 2px width
  /// Used for: O7/O8 period calendar containers (Figma v3 polish)
  static BoxDecoration get glassCalendarUltra => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(Sizes.radiusXL),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.90),
          width: 2.0,
        ),
      );
}
