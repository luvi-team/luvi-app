import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/effects.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

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
    final dsTokens = theme.extension<DsTokens>();
    if (dsTokens == null) {
      throw FlutterError(
        'DsTokens extension not found in theme. '
        'Ensure DsTokens is registered via ThemeData.extensions in app_theme.dart',
      );
    }

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Material(
        color: DsColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Sizes.radiusL),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.l,
              vertical: Spacing.m,
            ),
            decoration: selected
                ? BoxDecoration(
                    color: DsColors.white.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(Sizes.radiusL),
                    border: Border.all(
                      color: DsColors.signature,
                      width: 2.0,
                    ),
                  )
                : DsEffects.glassPillStrong,
            child: Text(
              label,
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
    );
  }
}
