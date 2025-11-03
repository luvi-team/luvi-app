import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design_tokens/typography.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/phase.dart';
import '../domain/week_strip.dart';
import '../screens/cycle_overview_stub.dart';

const double _trackHeight = 50.0;
const double _dayWidth = 25.31;
const double _todayWidth = 55.94;
const double _weekdayFontSize = 14.0;
const double _weekdayLineHeight = 1.12;
const double _weekdaySpacing =
    4.0; // Reduced from 7.0 for much more segment depth (aggressive)
const double _dayFontSize = 18.0;
const double _dayLineHeight = 1.15;
const double _topPadding =
    4.0; // Unchanged to preserve header position and external spacing
const double _bottomPadding =
    0.0; // Reduced from 2.0 for much more segment depth (aggressive)

// Asymmetric overhang: segment extends ONLY above the day numbers (prevents overflow)
const double _segmentOverhangTop = 3.0; // Extends upward for visual depth
const double _segmentOverhangBottom =
    0.0; // No bottom overhang (prevents container overflow)

const double _weekdayTextHeight = _weekdayFontSize * _weekdayLineHeight;
const double _segmentTopOffset =
    _topPadding + _weekdayTextHeight + _weekdaySpacing - _segmentOverhangTop;
const double _segmentHeight =
    _trackHeight - _segmentTopOffset - _bottomPadding + _segmentOverhangBottom;

String _formatWeekdayUpper(DateTime date) {
  try {
    return DateFormat('EEEEE', 'de_DE').format(date).toUpperCase();
  } catch (_) {
    // Manual German weekday abbreviations (Mo–So) → upper-case
    const days = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];
    final idx = date.weekday - 1;
    return (idx >= 0 && idx < days.length) ? days[idx] : '';
  }
}

String _formatDayMonthDe(DateTime date) {
  try {
    return DateFormat('d. MMM', 'de_DE').format(date);
  } catch (_) {
    const months = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    final m = (date.month >= 1 && date.month <= 12)
        ? months[date.month - 1]
        : '';
    return '${date.day}. $m';
  }
}

/// Inline calendar used on the dashboard header.
class CycleInlineCalendar extends StatelessWidget {
  const CycleInlineCalendar({
    super.key,
    required this.view,
    this.onSegmentsPainted,
  });

  final WeekStripView view;
  @visibleForTesting
  final void Function(List<PaintedSegmentDebug>)? onSegmentsPainted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseTokens = theme.extension<CyclePhaseTokens>();
    final textTokens = theme.extension<TextColorTokens>();
    final radiusTokens = theme.extension<CalendarRadiusTokens>();
    if (phaseTokens == null || textTokens == null || radiusTokens == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final dayGeometries = _computeGeometries(
          view.days,
          radiusTokens.calendarGap,
          availableWidth,
        );
        if (dayGeometries.isEmpty) {
          return const SizedBox.shrink();
        }

        final todayIndex = view.days.indexWhere((day) => day.isToday);
        final todayGeometry = todayIndex >= 0
            ? dayGeometries[todayIndex]
            : null;
        final todayDay = todayIndex >= 0 ? view.days[todayIndex] : null;

        return _CalendarContent(
          availableWidth: availableWidth,
          dayGeometries: dayGeometries,
          todayGeometry: todayGeometry,
          todayDay: todayDay,
          phaseTokens: phaseTokens,
          textTokens: textTokens,
          radiusTokens: radiusTokens,
          days: view.days,
          segments: view.segments,
          onSegmentsPainted: onSegmentsPainted,
        );
      },
    );
  }
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({
    required this.availableWidth,
    required this.dayGeometries,
    required this.todayGeometry,
    required this.todayDay,
    required this.phaseTokens,
    required this.textTokens,
    required this.radiusTokens,
    required this.days,
    required this.segments,
    this.onSegmentsPainted,
  });

  final double availableWidth;
  final List<_DayGeometry> dayGeometries;
  final _DayGeometry? todayGeometry;
  final WeekStripDay? todayDay;
  final CyclePhaseTokens phaseTokens;
  final TextColorTokens textTokens;
  final CalendarRadiusTokens radiusTokens;
  final List<WeekStripDay> days;
  final List<WeekStripSegment> segments;
  final void Function(List<PaintedSegmentDebug>)? onSegmentsPainted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('cycle_inline_calendar_semantics'),
      container: true,
      button: true,
      label: _buildSemanticsLabel(todayDay),
      hint: 'Zur Zyklusübersicht wechseln.',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go(CycleOverviewStubScreen.routeName),
            borderRadius: BorderRadius.zero,
            child: SizedBox(
              width: availableWidth,
              height: _trackHeight,
              child: _CalendarStack(
                availableWidth: availableWidth,
                dayGeometries: dayGeometries,
                segments: segments,
                todayGeometry: todayGeometry,
                todayDay: todayDay,
                days: days,
                phaseTokens: phaseTokens,
                textTokens: textTokens,
                radiusTokens: radiusTokens,
                onSegmentsPainted: onSegmentsPainted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildSemanticsLabel(WeekStripDay? todayDay) {
    if (todayDay != null) {
      final formattedDate = _formatDayMonthDe(todayDay.date);
      return 'Zykluskalender. Heute $formattedDate Phase: ${todayDay.phase.label}. '
          'Nur zur Orientierung – kein medizinisches Vorhersage- oder Diagnosetool.';
    }
    return 'Zykluskalender. Zur Zyklusübersicht wechseln. '
        'Nur zur Orientierung – kein medizinisches Vorhersage- oder Diagnosetool.';
  }
}

class _CalendarStack extends StatelessWidget {
  const _CalendarStack({
    required this.availableWidth,
    required this.dayGeometries,
    required this.segments,
    required this.todayGeometry,
    required this.todayDay,
    required this.days,
    required this.phaseTokens,
    required this.textTokens,
    required this.radiusTokens,
    this.onSegmentsPainted,
  });

  final double availableWidth;
  final List<_DayGeometry> dayGeometries;
  final List<WeekStripSegment> segments;
  final _DayGeometry? todayGeometry;
  final WeekStripDay? todayDay;
  final List<WeekStripDay> days;
  final CyclePhaseTokens phaseTokens;
  final TextColorTokens textTokens;
  final CalendarRadiusTokens radiusTokens;
  final void Function(List<PaintedSegmentDebug>)? onSegmentsPainted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _CalendarLayers(
          availableWidth: availableWidth,
          dayGeometries: dayGeometries,
          segments: segments,
          todayGeometry: todayGeometry,
          todayDay: todayDay,
          phaseTokens: phaseTokens,
          radiusTokens: radiusTokens,
          onSegmentsPainted: onSegmentsPainted,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: availableWidth,
              height: _trackHeight,
              child: _DaysRow(
                days: days,
                dayGeometries: dayGeometries,
                textTokens: textTokens,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarLayers extends StatelessWidget {
  const _CalendarLayers({
    required this.availableWidth,
    required this.dayGeometries,
    required this.segments,
    required this.todayGeometry,
    required this.todayDay,
    required this.phaseTokens,
    required this.radiusTokens,
    this.onSegmentsPainted,
  });

  final double availableWidth;
  final List<_DayGeometry> dayGeometries;
  final List<WeekStripSegment> segments;
  final _DayGeometry? todayGeometry;
  final WeekStripDay? todayDay;
  final CyclePhaseTokens phaseTokens;
  final CalendarRadiusTokens radiusTokens;
  final void Function(List<PaintedSegmentDebug>)? onSegmentsPainted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: availableWidth,
      height: _trackHeight,
      child: Stack(
        children: [
          _SegmentLayer(
            availableWidth: availableWidth,
            dayGeometries: dayGeometries,
            segments: segments,
            tokens: phaseTokens,
            radiusTokens: radiusTokens,
            onSegmentsPainted: onSegmentsPainted,
          ),
          _TodayPillLayer(
            todayGeometry: todayGeometry,
            todayDay: todayDay,
            tokens: phaseTokens,
            radiusTokens: radiusTokens,
          ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    super.key,
    required this.day,
    required this.geometry,
    required this.textTokens,
    this.isFirst = false,
    this.isLast = false,
  });

  final WeekStripDay day;
  final _DayGeometry geometry;
  final TextColorTokens textTokens;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final weekdayLabel = _formatWeekdayUpper(day.date);
    final dayNumber = day.date.day.toString();
    final isToday = day.isToday;
    final baseTextColor = isToday ? Colors.white : textTokens.primary;
    final weekdayTextColor = textTokens.secondary;
    final padding = EdgeInsets.only(
      top: _topPadding,
      bottom: _bottomPadding,
      left: isFirst ? 12 : 0,
      right: isLast ? 12 : 0,
    );

    return SizedBox(
      key: ValueKey('day_chip_${day.date.day}'),
      width: geometry.width,
      height: _trackHeight,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              weekdayLabel,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontFamily: FontFamilies.figtree,
                fontWeight: FontWeight.w600,
                fontSize: _weekdayFontSize,
                height: _weekdayLineHeight,
                color: weekdayTextColor,
              ),
            ),
            const SizedBox(height: _weekdaySpacing),
            Text(
              dayNumber,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontFamily: FontFamilies.figtree,
                fontWeight: FontWeight.w700,
                fontSize: _dayFontSize,
                height: _dayLineHeight,
                color: baseTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentLayer extends StatelessWidget {
  const _SegmentLayer({
    required this.availableWidth,
    required this.dayGeometries,
    required this.segments,
    required this.tokens,
    required this.radiusTokens,
    this.onSegmentsPainted,
  });

  final double availableWidth;
  final List<_DayGeometry> dayGeometries;
  final List<WeekStripSegment> segments;
  final CyclePhaseTokens tokens;
  final CalendarRadiusTokens radiusTokens;
  final void Function(List<PaintedSegmentDebug>)? onSegmentsPainted;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(availableWidth, _trackHeight),
      painter: _SegmentPainter(
        segments: segments,
        geometries: dayGeometries,
        tokens: tokens,
        radiusTokens: radiusTokens,
        topOffset: _segmentTopOffset,
        segmentHeight: _segmentHeight,
        onPaintDebug: onSegmentsPainted,
      ),
    );
  }
}

class _TodayPillLayer extends StatelessWidget {
  const _TodayPillLayer({
    required this.todayGeometry,
    required this.todayDay,
    required this.tokens,
    required this.radiusTokens,
  });

  final _DayGeometry? todayGeometry;
  final WeekStripDay? todayDay;
  final CyclePhaseTokens tokens;
  final CalendarRadiusTokens radiusTokens;

  @override
  Widget build(BuildContext context) {
    if (todayGeometry == null || todayDay == null) {
      return const SizedBox.shrink();
    }

    final geometry = todayGeometry!;
    final day = todayDay!;

    return Positioned(
      left: geometry.start,
      top: _segmentTopOffset,
      child: Container(
        width: geometry.width,
        height: _segmentHeight,
        decoration: BoxDecoration(
          color: _todayColor(day.phase, tokens),
          borderRadius: BorderRadius.circular(radiusTokens.calendarChip),
        ),
      ),
    );
  }
}

class _DaysRow extends StatelessWidget {
  const _DaysRow({
    required this.days,
    required this.dayGeometries,
    required this.textTokens,
  });

  final List<WeekStripDay> days;
  final List<_DayGeometry> dayGeometries;
  final TextColorTokens textTokens;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final geometry = dayGeometries[i];
      final bool isFirst = i == 0;
      final bool isLast = i == days.length - 1;
      children.add(
        _DayColumn(
          key: ValueKey('day_col_${day.date.toIso8601String()}'),
          day: day,
          geometry: geometry,
          textTokens: textTokens,
          isFirst: isFirst,
          isLast: isLast,
        ),
      );
      if (geometry.gapAfter > 0 && i != days.length - 1) {
        children.add(SizedBox(width: geometry.gapAfter));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: children,
    );
  }
}

class _DayGeometry {
  const _DayGeometry({
    required this.start,
    required this.width,
    required this.gapAfter,
  });

  final double start;
  final double width;
  final double gapAfter;

  double get end => start + width;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _DayGeometry &&
        other.start == start &&
        other.width == width &&
        other.gapAfter == gapAfter;
  }

  @override
  int get hashCode => Object.hash(start, width, gapAfter);
}

List<_DayGeometry> _computeGeometries(
  List<WeekStripDay> days,
  double calendarGap,
  double availableWidth,
) {
  if (days.isEmpty) return [];

  // Calculate flexible width ratio: today pill is ~2.21× wider than regular day
  const todayFlex = _todayWidth / _dayWidth; // ≈ 2.21

  // Count phase change boundaries (where gaps will be inserted)
  int boundariesCount = 0;
  for (var i = 0; i < days.length - 1; i++) {
    if (days[i].phase != days[i + 1].phase) {
      boundariesCount++;
    }
  }

  // Calculate total gap space
  final totalGapsPx = boundariesCount * calendarGap;

  // Calculate total flex units (sum of all day flex values)
  double totalFlexUnits = 0.0;
  for (final day in days) {
    totalFlexUnits += day.isToday ? todayFlex : 1.0;
  }

  // Calculate base width per flex unit
  final baseWidth = (availableWidth - totalGapsPx) / totalFlexUnits;

  // Generate geometries with distributed widths
  var cursor = 0.0;
  return List<_DayGeometry>.generate(days.length, (index) {
    final day = days[index];
    final width = baseWidth * (day.isToday ? todayFlex : 1.0);
    final hasPhaseChangeAhead =
        index < days.length - 1 && day.phase != days[index + 1].phase;
    final gapAfter = hasPhaseChangeAhead ? calendarGap : 0.0;

    final geometry = _DayGeometry(
      start: cursor,
      width: width,
      gapAfter: gapAfter,
    );
    cursor += width + gapAfter;
    return geometry;
  });
}

class _SegmentPainter extends CustomPainter {
  const _SegmentPainter({
    required this.segments,
    required this.geometries,
    required this.tokens,
    required this.radiusTokens,
    required this.topOffset,
    required this.segmentHeight,
    this.onPaintDebug,
  });

  final List<WeekStripSegment> segments;
  final List<_DayGeometry> geometries;
  final CyclePhaseTokens tokens;
  final CalendarRadiusTokens radiusTokens;
  final double topOffset;
  final double segmentHeight;
  final void Function(List<PaintedSegmentDebug>)? onPaintDebug;

  @override
  void paint(Canvas canvas, Size size) {
    List<PaintedSegmentDebug>? debug;
    if (onPaintDebug != null) debug = <PaintedSegmentDebug>[];
    for (final segment in segments) {
      final startGeometry = geometries[segment.startIndex];
      final endGeometry = geometries[segment.endIndex];
      final left = startGeometry.start;
      final right = endGeometry.end;
      final rect = Rect.fromLTWH(left, topOffset, right - left, segmentHeight);
      final radiusLeft = segment.startIndex == 0
          ? Radius.circular(radiusTokens.calendarSegmentEdge)
          : Radius.circular(radiusTokens.calendarSegmentInner);
      final radiusRight = segment.endIndex == geometries.length - 1
          ? Radius.circular(radiusTokens.calendarSegmentEdge)
          : Radius.circular(radiusTokens.calendarSegmentInner);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: radiusLeft,
        bottomLeft: radiusLeft,
        topRight: radiusRight,
        bottomRight: radiusRight,
      );
      final color = _segmentColor(segment.phase, tokens);
      final paint = Paint()..color = color;
      canvas.drawRRect(rrect, paint);
      if (debug != null) {
        debug.add(PaintedSegmentDebug(
          phase: segment.phase,
          rect: rect,
          color: color,
        ));
      }
    }
    if (onPaintDebug != null && debug != null) onPaintDebug!(debug);
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter oldDelegate) {
    return !listEquals(oldDelegate.segments, segments) ||
        !listEquals(oldDelegate.geometries, geometries) ||
        oldDelegate.tokens != tokens ||
        oldDelegate.radiusTokens != radiusTokens ||
        oldDelegate.topOffset != topOffset ||
        oldDelegate.segmentHeight != segmentHeight;
  }
}

Color _segmentColor(Phase phase, CyclePhaseTokens tokens) {
  // Segment background colors with explicit opacities per Figma design
  switch (phase) {
    case Phase.menstruation:
      return tokens.menstruation.withValues(alpha: 0.25);
    case Phase.follicular:
      return tokens.follicularDark.withValues(alpha: 0.20);
    case Phase.ovulation:
      return tokens.ovulation.withValues(alpha: 0.50);
    case Phase.luteal:
      return tokens.luteal.withValues(alpha: 0.25);
  }
}

Color _todayColor(Phase phase, CyclePhaseTokens tokens) {
  // Today pill always uses full phase color (100% opacity)
  switch (phase) {
    case Phase.menstruation:
      return tokens.menstruation;
    case Phase.follicular:
      return tokens.follicularDark;
    case Phase.ovulation:
      return tokens.ovulation;
    case Phase.luteal:
      return tokens.luteal;
  }
}

/// Debug info for painted segments, exposed in tests via
/// [CycleInlineCalendar.onSegmentsPainted].
@immutable
class PaintedSegmentDebug {
  const PaintedSegmentDebug({
    required this.phase,
    required this.rect,
    required this.color,
  });
  final Phase phase;
  final Rect rect;
  final Color color;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaintedSegmentDebug &&
        other.phase == phase &&
        other.rect == rect &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(phase, rect, color);
}
