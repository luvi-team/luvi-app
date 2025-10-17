import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Divider-specific tokens (Figma audit Phase 1).
@immutable
class DividerTokens extends ThemeExtension<DividerTokens> {
  const DividerTokens({
    required this.sectionDividerColor,
    required this.sectionDividerThickness,
    required this.sectionDividerVerticalMargin,
  });

  final Color sectionDividerColor;
  final double sectionDividerThickness;
  final double sectionDividerVerticalMargin;

  static const DividerTokens light = DividerTokens(
    // Divider between "Ernährung & Nutrition" and "Regeneration & Achtsamkeit"
    // (Figma audit Phase 1, node 68723:7672)
    sectionDividerColor: Color(0xFFDCDCDC), // inputBorder token
    sectionDividerThickness: 1.0,
    sectionDividerVerticalMargin: 12.0, // Visual estimate from screenshot
  );

  @override
  DividerTokens copyWith({
    Color? sectionDividerColor,
    double? sectionDividerThickness,
    double? sectionDividerVerticalMargin,
  }) => DividerTokens(
    sectionDividerColor: sectionDividerColor ?? this.sectionDividerColor,
    sectionDividerThickness:
        sectionDividerThickness ?? this.sectionDividerThickness,
    sectionDividerVerticalMargin:
        sectionDividerVerticalMargin ?? this.sectionDividerVerticalMargin,
  );

  @override
  DividerTokens lerp(ThemeExtension<DividerTokens>? other, double t) {
    if (other is! DividerTokens) return this;
    return DividerTokens(
      sectionDividerColor:
          Color.lerp(sectionDividerColor, other.sectionDividerColor, t) ??
          sectionDividerColor,
      sectionDividerThickness:
          lerpDouble(sectionDividerThickness, other.sectionDividerThickness, t) ??
          sectionDividerThickness,
      sectionDividerVerticalMargin:
          lerpDouble(sectionDividerVerticalMargin, other.sectionDividerVerticalMargin, t) ??
          sectionDividerVerticalMargin,
    );
  }
}
