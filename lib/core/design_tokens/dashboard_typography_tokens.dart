import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// Dashboard-specific typography tokens (Figma audit Phase 1).
@immutable
class DashboardTypographyTokens
    extends ThemeExtension<DashboardTypographyTokens>
    with DiagnosticableTreeMixin {
  const DashboardTypographyTokens({
    required this.sectionTitle,
    required this.sectionSubtitle,
  });

  final TextStyle sectionTitle;
  final TextStyle sectionSubtitle;

  static const DashboardTypographyTokens light = DashboardTypographyTokens(
    // "Dein Training für diese Woche" (Figma audit Phase 1, node 68721:7583)
    sectionTitle: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 20,
      height: 24 / 20,
      color: DsColors.grayscaleBlack,
    ),
    // "Erstellt von deinen LUVI-Expert:innen" (Figma audit Phase 1, node 68721:7584)
    sectionSubtitle: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
      fontStyle: FontStyle.italic,
      color: DsColors.grayscale500, // #696969 (Grayscale/500)
    ),
  );

  @override
  DashboardTypographyTokens copyWith({
    TextStyle? sectionTitle,
    TextStyle? sectionSubtitle,
  }) => DashboardTypographyTokens(
    sectionTitle: sectionTitle ?? this.sectionTitle,
    sectionSubtitle: sectionSubtitle ?? this.sectionSubtitle,
  );

  @override
  DashboardTypographyTokens lerp(
    ThemeExtension<DashboardTypographyTokens>? other,
    double t,
  ) {
    if (other is! DashboardTypographyTokens) return this;
    return DashboardTypographyTokens(
      sectionTitle:
          TextStyle.lerp(sectionTitle, other.sectionTitle, t) ?? sectionTitle,
      sectionSubtitle:
          TextStyle.lerp(sectionSubtitle, other.sectionSubtitle, t) ??
          sectionSubtitle,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<TextStyle>('sectionTitle', sectionTitle),
    );
    properties.add(
      DiagnosticsProperty<TextStyle>('sectionSubtitle', sectionSubtitle),
    );
  }
}
