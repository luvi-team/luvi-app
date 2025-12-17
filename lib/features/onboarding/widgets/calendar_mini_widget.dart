import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/effects.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Mini calendar preview widget for the cycle intro screen (O6).
///
/// Figma specs:
/// - Container: 10% white opacity, radius 24
/// - RadialGradient glow for highlighted day (120px)
class CalendarMiniWidget extends StatelessWidget {
  const CalendarMiniWidget({
    super.key,
    this.highlightedDay = 25,
  });

  /// The day to highlight with the glow effect
  final int highlightedDay;

  static const _weekdayLabels = ['M', 'D', 'M', 'D', 'F', 'S', 'S'];

  // Widget-specific layout constants (Figma Calendar Mini specs)
  static const double _cellSize = 32.0;
  static const double _dayCircleSize = 28.0;
  static const double _glowSize = 40.0;
  static const double _weekdayFontSize = 12.0;
  static const double _dayFontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.semanticCalendarPreview,
      child: Container(
        padding: const EdgeInsets.all(Spacing.calendarMiniPadding),
        decoration: DsEffects.glassMiniCalendar,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Weekday header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekdayLabels
                  .map((label) => SizedBox(
                        width: _cellSize,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _weekdayFontSize,
                            fontWeight: FontWeight.w500,
                            color: DsColors.calendarWeekdayGray,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: Spacing.xs),
            // Calendar grid (simplified 5 rows)
            ...List.generate(5, (rowIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (colIndex) {
                    final dayNumber = rowIndex * 7 + colIndex + 1;
                    if (dayNumber > 31) {
                      return const SizedBox(width: _cellSize, height: _cellSize);
                    }
                    return _buildDayCell(dayNumber);
                  }),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(int day) {
    final isHighlighted = day == highlightedDay;
    // Period range: days AFTER the highlighted day (26-31 when highlightedDay=25)
    // Figma: Days after period start are marked as upcoming period days
    final isInPeriodRange = day > highlightedDay && day <= 31;

    return SizedBox(
      width: _cellSize,
      height: _cellSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect for highlighted day
          if (isHighlighted)
            Container(
              width: _glowSize,
              height: _glowSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    DsColors.periodGlowPink,
                    DsColors.periodGlowPinkLight,
                    DsColors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          // Day number
          Container(
            width: _dayCircleSize,
            height: _dayCircleSize,
            decoration: isHighlighted
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: DsColors.signature,
                  )
                : isInPeriodRange
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        // Filled with light pink (Figma: period days after start)
                        color: DsColors.signature.withValues(alpha: 0.2),
                      )
                    : null,
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: _dayFontSize,
                  fontWeight:
                      isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  color: isHighlighted
                      ? DsColors.white
                      : isInPeriodRange
                          ? DsColors.signature
                          : DsColors.grayscaleBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
