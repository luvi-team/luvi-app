import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/effects.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Mini calendar preview widget for the cycle intro screen (O6).
///
/// Figma specs:
/// - Container: 10% white opacity, radius 24
/// - RadialGradient glow for highlighted day (pulsating animation)
/// - Days after highlighted day: only text color change (no circle)
class CalendarMiniWidget extends StatefulWidget {
  const CalendarMiniWidget({
    super.key,
    this.highlightedDay = 25,
  });

  /// The day to highlight with the glow effect
  final int highlightedDay;

  @override
  State<CalendarMiniWidget> createState() => _CalendarMiniWidgetState();
}

class _CalendarMiniWidgetState extends State<CalendarMiniWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  static const _weekdayLabels = ['M', 'D', 'M', 'D', 'F', 'S', 'S'];

  // Widget-specific layout constants (Figma Calendar Mini specs)
  static const double _cellSize = 32.0;
  static const double _dayCircleSize = 28.0;
  static const double _glowSize = 50.0;
  static const double _weekdayFontSize = 12.0;
  static const double _dayFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    // Pulsating glow animation (Figma v2)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.semanticCalendarPreview,
      child: Container(
        padding: const EdgeInsets.all(Spacing.calendarMiniPadding),
        decoration: DsEffects.glassMiniCalendarStrong,
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
                    return _buildDayCell(dayNumber, widget.highlightedDay);
                  }),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(int day, int highlightedDay) {
    final isHighlighted = day == highlightedDay;
    // Period range: days AFTER the highlighted day (26-31 when highlightedDay=25)
    // Figma v2: Only text color change, no circle background
    final isInPeriodRange = day > highlightedDay && day <= 31;

    return SizedBox(
      width: _cellSize,
      height: _cellSize,
      child: Stack(
        clipBehavior: Clip.none, // Allow glow to extend beyond cell bounds
        alignment: Alignment.center,
        children: [
          // Pulsating glow effect for highlighted day (Figma v2)
          if (isHighlighted)
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: _glowSize,
                  height: _glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        DsColors.periodGlowPink.withValues(alpha: _glowAnimation.value),
                        DsColors.periodGlowPinkLight.withValues(alpha: _glowAnimation.value * 0.6),
                        DsColors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                );
              },
            ),
          // Day number - Figma v2: days 26-31 only have text color, no circle
          Container(
            width: _dayCircleSize,
            height: _dayCircleSize,
            decoration: isHighlighted
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: DsColors.white,
                  )
                : null, // No circle for period range days (Figma v2)
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: _dayFontSize,
                  fontWeight:
                      isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  color: isHighlighted
                      ? DsColors.signature
                      : isInPeriodRange
                          ? DsColors.signature // Only text color change
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
