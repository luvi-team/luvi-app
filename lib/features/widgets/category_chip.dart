import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

/// Category chip for Dashboard: Column layout (icon above label).
/// from DASHBOARD_spec.json $.categories.chips (60×92, icon 60×60, label below, gap 8px)
class CategoryChip extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final double? width;
  final VoidCallback? onTap;

  const CategoryChip({
    required this.iconPath,
    required this.label,
    this.isSelected = false,
    this.width,
    this.onTap,
    super.key,
  });

  static const double _iconContainerSize = 60;
  static const double _minChipWidth = 60;
  static const double _maxChipWidth = 88; // from DASHBOARD_spec.json $.categories.chips.widthRange (≈60–88px)
  static const double _labelGuardPadding = 4; // audit delta: min padding while keeping 4 chips inside 390px viewport

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: FontFamilies.figtree,
    fontSize: 14,
    height: 24 / 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF030401),
  );

  /// Measures the required width for the label and clamps it to audit bounds.
  static double measuredWidth(String label, TextDirection textDirection) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: _labelStyle),
      textDirection: textDirection,
      maxLines: 1,
    )..layout(maxWidth: double.infinity);

    final textWidth = painter.width + _labelGuardPadding;
    final effectiveWidth = math.max(_iconContainerSize, textWidth);
    return effectiveWidth.clamp(_minChipWidth, _maxChipWidth);
  }

  static double get minWidth => _minChipWidth;

  @override
  Widget build(BuildContext context) {
    // from DASHBOARD_spec_deltas.json $.deltas[5] (selected state)
    final backgroundColor = isSelected
        ? const Color(0xFFD9B18E) // selected (beige/gold)
        : const Color(0xFFF7F7F8); // normal (gray)

    final chipWidth = width ?? measuredWidth(label, Directionality.of(context));

    return SizedBox(
      width: chipWidth,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            // from DASHBOARD_spec.json $.categories.chips[0].container (60×60, radius 16, padding 10)
            Align(
              child: Container(
                width: _iconContainerSize,
                height: _iconContainerSize,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SvgPicture.asset(
                  iconPath,
                  // TODO(assets): re-export SVGs with thinner stroke (1.5px, no scale-strokes); restore 24px.
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8), // from DASHBOARD_spec.json $.spacingTokensObserved[4] (gap 8px)
            // Label
            // from DASHBOARD_spec.json $.categories.chips[0].labelTypography (Figtree 14/24)
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
              style: _labelStyle,
            ),
          ],
        ),
      ),
    );
  }
}
