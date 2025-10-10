import 'package:flutter/widgets.dart';
import 'package:luvi_app/features/cycle/domain/week_strip.dart';
import 'package:luvi_app/features/cycle/widgets/cycle_inline_calendar.dart';

/// Dashboard wrapper around the cycle inline calendar to keep cross-feature
/// usage consistent.
class DashboardCalendar extends StatelessWidget {
  const DashboardCalendar({super.key, required this.view});

  final WeekStripView view;

  @override
  Widget build(BuildContext context) => CycleInlineCalendar(view: view);
}
