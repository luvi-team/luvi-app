import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

const double kStatsCardWidth = 173;
const double kStatsCardHeight = 210;
const double kStatsCardRadius = 24;

/// Glassmorphism fallback card shown when no wearable is connected.
class WearableConnectCard extends StatelessWidget {
  const WearableConnectCard({
    super.key = const Key('dashboard_wearable_connect_card'),
    this.message =
        'Verbinde dein Wearable, um deine Trainingsdaten anzeigen zu lassen.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final glassTokens = Theme.of(context).extension<GlassTokens>();
    final textTokens = Theme.of(context).extension<TextColorTokens>();

    final backgroundColor = glassTokens?.background ?? const Color(0x8CFFFFFF);
    final borderSide =
        glassTokens?.border ?? const BorderSide(color: Color(0x14000000));
    final blur = glassTokens?.blur ?? 16.0;
    final textColor = textTokens?.secondary ?? const Color(0xFF6D6D6D);

    return Semantics(
      container: true,
      label: message,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kStatsCardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                width: kStatsCardWidth,
                height: kStatsCardHeight,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(kStatsCardRadius),
                  border: Border.fromBorderSide(borderSide),
                ),
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: TypographyTokens.size16,
                      height: TypographyTokens.lineHeightRatio24on16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
