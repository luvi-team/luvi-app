import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

/// Goal card widget for onboarding multi-select screen.
///
/// Figma specs: ONB_03
/// - Width: 388 px (full content width)
/// - Height: Auto (66 px single-line, 89 px two-line)
/// - Border radius: 20 px
/// - Padding: 20 px (vertical) × 16 px (horizontal)
/// - Icon: 24×24 px, 20 px gap to text (when provided)
/// - Selected state: 1 px border (#1C1411)
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final Widget? icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dsTokens = theme.extension<DsTokens>();
    if (dsTokens == null) {
      throw FlutterError(
        'DsTokens extension not found in theme. '
        'Ensure DsTokens is registered via ThemeData.extensions in app_theme.dart'
      );
    }
    return Semantics(
      label: title,
      checked: selected,
      child: Material(
        color: DsColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Sizes.radiusL),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.m,
              vertical: Spacing.goalCardVertical,
            ),
            decoration: BoxDecoration(
              // Glass effect: white with 10% opacity (Figma v2)
              color: DsColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Sizes.radiusL),
              border: selected
                  ? Border.all(
                      color: dsTokens.cardBorderSelected, // #1C1411
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  SizedBox(
                    width: Sizes.iconM,
                    height: Sizes.iconM,
                    child: IconTheme(
                      data: IconThemeData(color: theme.colorScheme.onSurface),
                      child: icon!,
                    ),
                  ),
                  const SizedBox(width: Spacing.goalCardIconGap),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: TypographyTokens.size16,
                      height: TypographyTokens.lineHeightRatio24on16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
