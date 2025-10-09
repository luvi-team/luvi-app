import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';

const double _cardWidth = 380;
const double _cardRadius = 24;
const double _iconSize = 24;

/// Purple info card that surfaces a short, phase-specific recommendation.
class CycleTipCard extends StatelessWidget {
  const CycleTipCard({
    super.key = const Key('dashboard_cycle_tip_card'),
    required this.phase,
  });

  final Phase phase;

  static const Map<Phase, _CycleTipCopy> _copyByPhase = <Phase, _CycleTipCopy>{
    Phase.follicular: _CycleTipCopy(
      headline: 'Follikelphase',
      body:
          'Nutze dein Energiehoch für bewusst intensivere Workouts - achte trotzdem auf klare Körpersignale.',
    ),
    Phase.ovulation: _CycleTipCopy(
      headline: 'Ovulationsfenster',
      body:
          'Kurze, knackige Sessions funktionieren jetzt meist am besten. Plane danach bewusst Cool-down & Hydration ein.',
    ),
    Phase.luteal: _CycleTipCopy(
      headline: 'Lutealphase',
      body:
          'Wechsle auf ruhige Kraft- oder Mobility-Einheiten. Zusätzliche Pausen helfen dir, das Energielevel zu halten.',
    ),
    Phase.menstruation: _CycleTipCopy(
      headline: 'Menstruation',
      body:
          'Sanfte Bewegung, Stretching oder ein Spaziergang sind heute ideale Begleiter - alles darf, nichts muss.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final surfaceTokens = Theme.of(context).extension<SurfaceColorTokens>();
    final textTokens = Theme.of(context).extension<TextColorTokens>();
    final backgroundColor =
        surfaceTokens?.infoBackground ?? DsColors.infoBackground;
    final textColor = textTokens?.primary ?? DsColors.textPrimary;

    final copy = _copyByPhase[phase] ?? _copyByPhase[Phase.follicular]!;
    final semanticsLabel = 'Phasenhinweis ${copy.headline}. ${copy.body}';

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
                                copy.headline,
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
                                copy.body,
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

class _CycleTipCopy {
  const _CycleTipCopy({required this.headline, required this.body});

  final String headline;
  final String body;
}
