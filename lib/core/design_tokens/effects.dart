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
}
