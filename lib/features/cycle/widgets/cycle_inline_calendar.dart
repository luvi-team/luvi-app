import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design_tokens/typography.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/phase.dart';
import '../domain/week_strip.dart';

const double _trackHeight = 38.0;
const double _dayWidth = 25.31;
const double _todayWidth = 55.94;
const double _segmentRadius = 40.0;
const double _weekdayFontSize = 12.0;
const double _dayFontSize = 16.0;

/// Inline calendar used on the dashboard header.
class CycleInlineCalendar extends StatelessWidget {
  const CycleInlineCalendar({super.key, required this.view});

  final WeekStripView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseTokens = theme.extension<CyclePhaseTokens>();
    final textTokens = theme.extension<TextColorTokens>();
    final radiusTokens = theme.extension<CalendarRadiusTokens>();
    if (phaseTokens == null ||
        textTokens == null ||
        radiusTokens == null) {
      return const SizedBox.shrink();
    }

    final dayGeometries =
        _computeGeometries(view.days, radiusTokens.calendarGap);
    if (dayGeometries.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalWidth = dayGeometries.last.end;
    final todayIndex = view.days.indexWhere((day) => day.isToday);
    final todayGeometry = todayIndex >= 0 ? dayGeometries[todayIndex] : null;
    final todayDay = todayIndex >= 0 ? view.days[todayIndex] : null;

    final weekdayFormat = DateFormat('EEEEE', 'de_DE');
    final dayWidgets = <Widget>[];

    for (var i = 0; i < view.days.length; i++) {
      final day = view.days[i];
      final geometry = dayGeometries[i];

      final weekdayLabel = weekdayFormat.format(day.date).toUpperCase();
      final dayNumber = day.date.day.toString();
      final isToday = day.isToday;
      final baseTextColor =
          isToday ? Colors.white : textTokens.primary;
      final secondaryTextColor =
          isToday ? Colors.white : textTokens.secondary;

      dayWidgets.add(
        SizedBox(
          width: geometry.width,
          height: _trackHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekdayLabel,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontFamily: FontFamilies.figtree,
                  fontWeight: FontWeight.w600,
                  fontSize: _weekdayFontSize,
                  height: 1.0,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayNumber,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontFamily: FontFamilies.figtree,
                  fontWeight: FontWeight.w700,
                  fontSize: _dayFontSize,
                  height: 1.2,
                  color: baseTextColor,
                ),
              ),
            ],
          ),
        ),
      );

      if (geometry.gapAfter > 0 && i != view.days.length - 1) {
        dayWidgets.add(SizedBox(width: geometry.gapAfter));
      }
    }

    final dateFormat = DateFormat('d. MMM', 'de_DE');
    final String semanticsLabel;
    if (todayDay != null) {
      final formattedDate = dateFormat.format(todayDay.date);
      semanticsLabel =
          'Zykluskalender. Heute $formattedDate Phase: ${todayDay.phase.label}.';
    } else {
      semanticsLabel = 'Zykluskalender. Zur Zyklusübersicht wechseln.';
    }

    return Semantics(
      key: const ValueKey('cycle_inline_calendar_semantics'),
      container: true,
      button: true,
      label: semanticsLabel,
      hint: 'Zur Zyklusübersicht wechseln.',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/zyklus'),
            borderRadius: BorderRadius.zero,
            child: SizedBox(
              width: totalWidth,
              height: _trackHeight,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(totalWidth, _trackHeight),
                    painter: _SegmentPainter(
                      segments: view.segments,
                      geometries: dayGeometries,
                      tokens: phaseTokens,
                    ),
                  ),
                  if (todayGeometry != null && todayDay != null)
                    Positioned(
                      left: todayGeometry.start,
                      top: 0,
                      child: Container(
                        width: todayGeometry.width,
                        height: _trackHeight,
                        decoration: BoxDecoration(
                          color: _todayColor(todayDay.phase, phaseTokens),
                          borderRadius: BorderRadius.circular(_segmentRadius),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: totalWidth,
                        height: _trackHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: dayWidgets,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
) {
  var cursor = 0.0;
  return List<_DayGeometry>.generate(days.length, (index) {
    final day = days[index];
    final width = day.isToday ? _todayWidth : _dayWidth;
    final hasPhaseChangeAhead =
        index < days.length - 1 && day.phase != days[index + 1].phase;
    final gapAfter = (hasPhaseChangeAhead && index != days.length - 1)
        ? calendarGap
        : 0.0;
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
  });

  final List<WeekStripSegment> segments;
  final List<_DayGeometry> geometries;
  final CyclePhaseTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    for (final segment in segments) {
      final startGeometry = geometries[segment.startIndex];
      final endGeometry = geometries[segment.endIndex];
      final left = startGeometry.start;
      final right = endGeometry.end;
      final rect = Rect.fromLTWH(left, 0, right - left, size.height);
      final radiusLeft = segment.startIndex == 0
          ? Radius.zero
          : const Radius.circular(_segmentRadius);
      final radiusRight = segment.endIndex == geometries.length - 1
          ? Radius.zero
          : const Radius.circular(_segmentRadius);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: radiusLeft,
        bottomLeft: radiusLeft,
        topRight: radiusRight,
        bottomRight: radiusRight,
      );
      final paint = Paint()..color = _segmentColor(segment.phase, tokens);
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter oldDelegate) {
    return !listEquals(oldDelegate.segments, segments) ||
        !listEquals(oldDelegate.geometries, geometries) ||
        oldDelegate.tokens != tokens;
  }
}

Color _segmentColor(Phase phase, CyclePhaseTokens tokens) {
  switch (phase) {
    case Phase.menstruation:
      return tokens.menstruation;
    case Phase.follicular:
      return tokens.follicularLight;
    case Phase.ovulation:
      return tokens.ovulation;
    case Phase.luteal:
      return tokens.luteal;
  }
}

Color _todayColor(Phase phase, CyclePhaseTokens tokens) {
  if (phase == Phase.follicular) {
    return tokens.follicularDark;
  }
  return phase.mapToColorTokens(tokens);
}
