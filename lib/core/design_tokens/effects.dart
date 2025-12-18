import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';

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

  /// Strong Glass Card - 20% white opacity + white border for enhanced visibility
  /// Used for: O1 name input, O2 birthdate picker, O4/O5 goal/interest cards
  static BoxDecoration get glassCardStrong => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.4),
          width: 1,
        ),
      );

  /// Strong Glass Pill - 20% white opacity + white border
  /// Used for: O3 fitness level pills
  static BoxDecoration get glassPillStrong => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      );

  /// Strong Glass Calendar - 40% white opacity + white border
  /// Used for: O7/O8 period calendar containers
  static BoxDecoration get glassCalendarStrong => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      );

  /// Strong Glass Mini Calendar - 20% white opacity + white border
  /// Used for: O6 calendar mini widget
  static BoxDecoration get glassMiniCalendarStrong => BoxDecoration(
        color: DsColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.4),
          width: 1,
        ),
      );

  /// Success Card Glass - Figma O9 specs: #E9D5FF @ 20%, 16px radius
  /// Used for: O9 content preview cards
  static BoxDecoration get successCardGlass => BoxDecoration(
        color: DsColors.successCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DsColors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      );
}
