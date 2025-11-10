import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

const double _cardWidth = 380;
const double _cardRadius = 24;
const double _iconSize = 24;

/// Purple info card that surfaces a short, phase-specific recommendation.
class CycleTipCard extends StatelessWidget {
  const CycleTipCard({super.key, required this.phase});

  final Phase phase;

  // Copy moved to l10n. Headline/body resolved via AppLocalizations per phase.

  @override
  Widget build(BuildContext context) {
    final surfaceTokens = Theme.of(context).extension<SurfaceColorTokens>();
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    final backgroundColor =
        surfaceTokens?.infoBackground ?? DsColors.infoBackground;
    final textColor = textTokens?.primary ?? DsColors.textPrimary;

    final l10n = AppLocalizations.of(context)!;
    late final String headline;
    late final String body;
    switch (phase) {
      case Phase.menstruation:
        headline = l10n.cycleTipHeadlineMenstruation;
        body = l10n.cycleTipBodyMenstruation;
        break;
      case Phase.follicular:
        headline = l10n.cycleTipHeadlineFollicular;
        body = l10n.cycleTipBodyFollicular;
        break;
      case Phase.ovulation:
        headline = l10n.cycleTipHeadlineOvulation;
        body = l10n.cycleTipBodyOvulation;
        break;
      case Phase.luteal:
        headline = l10n.cycleTipHeadlineLuteal;
        body = l10n.cycleTipBodyLuteal;
        break;
    }
    final semanticsLabel = '$headline. $body';

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _cardWidth;
        final double width = math.min(availableWidth, _cardWidth);

        return Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            container: true,
            label: semanticsLabel,
            child: ExcludeSemantics(
              child: SizedBox(
                width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_cardRadius),
                  child: Container(
                    color: backgroundColor,
                    padding: const EdgeInsets.all(Spacing.m),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: _iconSize,
                          color: textColor,
                        ),
                        const SizedBox(width: Spacing.s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                headline,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: FontFamilies.figtree,
                                  fontSize: TypographyTokens.size16,
                                  height:
                                      TypographyTokens.lineHeightRatio24on16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                body,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: FontFamilies.figtree,
                                  fontSize: TypographyTokens.size14,
                                  height:
                                      TypographyTokens.lineHeightRatio24on14,
                                  fontWeight: FontWeight.w400,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
