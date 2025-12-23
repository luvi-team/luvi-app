import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_glass_card.dart';
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

  // Widget-specific layout constants (Figma Calendar Mini specs)
  static const double _cellSize = 32.0;
  static const double _dayCircleSize = 28.0;
  static const double _glowSize = 150.0; // v4.3: Larger glow per user request
  static const double _weekdayFontSize = 12.0;
  static const double _dayFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    // Pulsating glow animation (Figma v2)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000), // v4.3: Faster pulse
      vsync: this,
    )..repeat(reverse: true);

    // Figma v3: Full range animation for more visible pulsating effect
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  /// Returns localized weekday labels (Mon-Sun).
  List<String> _buildWeekdayLabels(AppLocalizations l10n) {
    return [
      l10n.weekdayMondayShort,
      l10n.weekdayTuesdayShort,
      l10n.weekdayWednesdayShort,
      l10n.weekdayThursdayShort,
      l10n.weekdayFridayShort,
      l10n.weekdaySaturdayShort,
      l10n.weekdaySundayShort,
    ];
  }

  /// Builds the 5-row calendar grid for days 1-31.
  List<Widget> _buildCalendarRows(int highlightedDay) {
    return List.generate(5, (rowIndex) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (colIndex) {
            final dayNumber = rowIndex * 7 + colIndex + 1;
            if (dayNumber > 31) {
              return const SizedBox(width: _cellSize, height: _cellSize);
            }
            return _buildDayCell(dayNumber, highlightedDay);
          }),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.semanticCalendarPreview,
      // B2: Use OnboardingGlassCard for real BackdropFilter blur + border
      child: OnboardingGlassCard(
        backgroundColor: DsColors.white.withValues(alpha: 0.10),
        borderRadius: Sizes.radius24,
        borderColor: DsColors.white.withValues(alpha: 0.70),
        borderWidth: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.calendarMiniPadding),
          // LayoutBuilder to calculate glow position based on grid width
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Grid-Layout calculation
              final gridWidth = constraints.maxWidth;
              final cellWidth = gridWidth / 7; // 7 columns

              // Position of highlightedDay
              final row = (widget.highlightedDay - 1) ~/ 7;
              final col = (widget.highlightedDay - 1) % 7;

              // Header height (Weekday-Row + Spacing)
              final headerHeight = _weekdayFontSize + Spacing.xs;
              // Row height (Cell + vertical padding)
              final rowHeight = _cellSize + (Spacing.xxs * 2);

              // Glow-Center Position
              final glowLeft = (col * cellWidth) + (cellWidth / 2);
              final glowTop =
                  headerHeight + (row * rowHeight) + (_cellSize / 2);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Glow FIRST (below in Stack, but visible through transparency)
                  Positioned(
                    left: glowLeft - (_glowSize / 2),
                    top: glowTop - (_glowSize / 2),
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          // v4.3: Pulsating for 150px glow
                          final glowScale =
                              0.95 + (_glowAnimation.value * 0.05);
                          return Transform.scale(
                            scale: glowScale,
                            child: Container(
                              width: _glowSize,
                              height: _glowSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    // Figma v4.2: rgba(255, 100, 130, 0.60) - Core
                                    DsColors.periodGlowPinkBase
                                        .withValues(alpha: 0.6),
                                    // Figma v4.2: rgba(255, 100, 130, 0.10) - Edge at 70%
                                    DsColors.periodGlowPinkBase
                                        .withValues(alpha: 0.1),
                                    DsColors.transparent,
                                  ],
                                  stops: const [0.0, 0.7, 1.0], // Figma v4.2 exact
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // 2. Grid (days on top)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Weekday header row (localized)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _buildWeekdayLabels(l10n)
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
                      // Calendar grid (5 rows for days 1-31)
                      ..._buildCalendarRows(widget.highlightedDay),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(int day, int highlightedDay) {
    final isHighlighted = day == highlightedDay;
    // Period range: days AFTER the highlighted day (26-31 when highlightedDay=25)
    // Figma v2: Only text color change, no circle background
    final isInPeriodRange = day > highlightedDay && day <= 31;

    // Glow is now rendered at parent Stack level via LayoutBuilder (Fix 3)
    // This cell only renders the day number + white circle for highlighted
    return SizedBox(
      width: _cellSize,
      height: _cellSize,
      child: Center(
        // Day number - Figma v3: Scale animation for highlighted day
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Transform.scale(
              // Figma v3: Number scales from 1.0 to 1.15 with glow
              scale: isHighlighted ? 1.0 + (_glowAnimation.value * 0.15) : 1.0,
              child: Container(
                width: _dayCircleSize,
                height: _dayCircleSize,
                decoration: isHighlighted
                    ? const BoxDecoration(
                        shape: BoxShape.circle,
                        color: DsColors.white,
                      )
                    : null, // No circle for period range days (Figma v3)
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
            );
          },
        ),
      ),
    );
  }
}
