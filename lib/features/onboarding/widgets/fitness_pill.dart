import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_glass_card.dart';

/// Horizontal pill widget for fitness level selection (O3).
/// Figma specs: horizontally arranged pills with rounded corners.
class FitnessPill extends StatelessWidget {
  const FitnessPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Material(
        color: DsColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Sizes.radius16),
          // B3: Use OnboardingGlassCard for real BackdropFilter blur effect
          child: OnboardingGlassCard(
            backgroundColor:
                selected ? DsColors.transparent : null, // default 10% white
            borderColor:
                selected ? DsColors.buttonPrimary : null, // default 70% white
            borderWidth: selected ? 2.0 : 1.5,
            borderRadius: Sizes.radius16,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.l,
                vertical: Spacing.m,
              ),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: TypographyTokens.size16,
                    height: TypographyTokens.lineHeightRatio24on16,
                    color: colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
