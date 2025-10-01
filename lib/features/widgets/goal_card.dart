import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/custom_radio_check.dart';

/// Goal card widget for onboarding multi-select screen.
///
/// Figma specs: ONB_03
/// - Width: 388 px (full content width)
/// - Height: Auto (66 px single-line, 89 px two-line)
/// - Border radius: 20 px
/// - Padding: 20 px (vertical) × 16 px (horizontal)
/// - Icon: 24×24 px, 20 px gap to text
/// - Selected state: 1 px border (#1C1411)
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dsTokens = theme.extension<DsTokens>()!;

    return Semantics(
      label: title,
      checked: selected,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Sizes.radiusL),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.m,
              vertical: Spacing.goalCardVertical,
            ),
            decoration: BoxDecoration(
              color: dsTokens.cardSurface, // #F7F7F8
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
                // Icon
                SizedBox(
                  width: Sizes.iconM,
                  height: Sizes.iconM,
                  child: icon,
                ),
                const SizedBox(width: Spacing.goalCardIconGap),
                // Text
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 24 / 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.m),
                // Custom radio button
                CustomRadioCheck(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
