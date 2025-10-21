import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Divider-specific tokens (Figma audit Phase 1).
@immutable
class DividerTokens extends ThemeExtension<DividerTokens> {
  const DividerTokens({
    required this.sectionDividerColor,
    required this.sectionDividerThickness,
    required this.sectionDividerVerticalMargin,
  }) : assert(sectionDividerThickness >= 0, 'Thickness must be non-negative'),
       assert(sectionDividerVerticalMargin >= 0, 'Margin must be non-negative');

  final Color sectionDividerColor;
  final double sectionDividerThickness;
  final double sectionDividerVerticalMargin;

  static const DividerTokens light = DividerTokens(
    // Divider between "Ernährung & Nutrition" and "Regeneration & Achtsamkeit"
    // (Figma audit Phase 1, node 68723:7672)
    // Using the literal value of DsTokens.light.inputBorder to keep this const
    sectionDividerColor: Color(0xFFDCDCDC),
    sectionDividerThickness: 1.0,
    sectionDividerVerticalMargin: 12.0, // Figma spec: vertical margin 12px
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
          lerpDouble(
            sectionDividerThickness,
            other.sectionDividerThickness,
            t,
          ) ??
          sectionDividerThickness,
      sectionDividerVerticalMargin:
          lerpDouble(
            sectionDividerVerticalMargin,
            other.sectionDividerVerticalMargin,
            t,
          ) ??
          sectionDividerVerticalMargin,
    );
  }
}
