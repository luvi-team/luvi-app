import 'package:flutter/material.dart';

/// Custom radio-style checkbox widget for multi-select scenarios.
/// Visually appears as a radio button but supports multiple selections.
///
/// Figma specs: ONB_03 (node 1115:3916, 1115:3919)
/// - Outer circle: 24×24 px
/// - Inner fill: 14×14 px (when selected)
class CustomRadioCheck extends StatelessWidget {
  const CustomRadioCheck({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? colorScheme
                    .primary // #D9B18E (gold) when selected
              : colorScheme.onSurface.withValues(
                  alpha: 0.3,
                ), // lighter when unselected
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary, // #D9B18E
                ),
              ),
            )
          : null,
    );
  }
}
