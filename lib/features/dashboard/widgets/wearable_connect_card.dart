import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

const double kStatsCardWidth = 173;
const double kStatsCardHeight = 159;
const double kStatsCardRadius = 24;

/// Glassmorphism fallback card shown when no wearable is connected.
class WearableConnectCard extends StatelessWidget {
  const WearableConnectCard({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolved = message ?? l10n.dashboardWearableConnectMessage;
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    final surfaceTokens = Theme.of(context).extension<SurfaceColorTokens>();

    final textColor = textTokens?.secondary ?? const Color(0xFF6D6D6D);

    return Semantics(
      container: true,
      label: resolved,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: Container(
            width: kStatsCardWidth,
            height: kStatsCardHeight,
            decoration: BoxDecoration(
              color: surfaceTokens?.cardBackgroundNeutral ?? const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(kStatsCardRadius),
              border: Border.all(
                color: const Color(0x1A000000), // Figma: 1dp @ 10% black
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                resolved,
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
    );
  }
}
