import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

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
  static const double _maxChipWidth =
      88; // from DASHBOARD_spec.json $.categories.chips.widthRange (≈60–88px)
  static const double _labelGuardPadding =
      4; // audit delta: min padding while keeping 4 chips inside 390px viewport

  static const TextStyle _baseLabelStyle = TextStyle(
    fontFamily: FontFamilies.figtree,
    fontSize: 14,
    height: 24 / 14,
    fontWeight: FontWeight.w400,
  );

  /// Measures the required width for the label and clamps it to audit bounds.
  static double measuredWidth(String label, TextDirection textDirection) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: _baseLabelStyle),
      textDirection: textDirection,
      maxLines: 1,
    );
    painter.layout(maxWidth: double.infinity);

    final textWidth = painter.width + _labelGuardPadding;
    final effectiveWidth = math.max(_iconContainerSize, textWidth);
    painter.dispose();
    return effectiveWidth.clamp(_minChipWidth, _maxChipWidth);
  }

  static double get minWidth => _minChipWidth;

  @override
  Widget build(BuildContext context) {
    final dsTokens = Theme.of(context).extension<DsTokens>();
    final textTokens = Theme.of(context).extension<TextColorTokens>();

    // from DASHBOARD_spec_deltas.json $.deltas[5] (selected state)
    final backgroundColor = isSelected
        ? (dsTokens?.color.icon.badge.goldCircle ?? ColorTokens.chipSelected)
        : (dsTokens?.cardSurface ?? ColorTokens.chipDefault);

    final chipWidth = width ?? measuredWidth(label, Directionality.of(context));
    final labelStyle = _baseLabelStyle.copyWith(
      color: textTokens?.primary ?? ColorTokens.sectionTitle,
    );

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          width: chipWidth,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container
                  // from DASHBOARD_spec.json $.categories.chips[0].container (60×60, radius 16, padding 10 baseline)
                  Align(
                    child: Container(
                      width: _iconContainerSize,
                      height: _iconContainerSize,
                      // Visual tuning: padding 16→14 to allow a 32 px glyph within 60 px container
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.asset(
                        iconPath,
                        // 60 − 2×14 = 32 → exact inner space for the glyph
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                            'CategoryChip: failed to load SVG $iconPath. Error: $error',
                          );
                          return const SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: Icon(Icons.broken_image, size: 20),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ), // from DASHBOARD_spec.json $.spacingTokensObserved[4] (gap 8px)
                  // Label
                  // from DASHBOARD_spec.json $.categories.chips[0].labelTypography (Figtree 14/24)
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: labelStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
