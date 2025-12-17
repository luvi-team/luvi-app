import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';

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
    // Use DsColors.signature (pink) to match Figma onboarding designs
    final activeColor = DsColors.signature;
    final inactiveColor = DsColors.signature.withValues(alpha: 0.5);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? activeColor : inactiveColor,
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
                  color: activeColor,
                ),
              ),
            )
          : null,
    );
  }
}
