import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// A scrollable month-grid calendar for period tracking in onboarding.
/// Figma: Shows multiple months with selectable days.
class PeriodCalendar extends StatefulWidget {
  const PeriodCalendar({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.periodDays = const [],
    this.periodEndDate,
    this.allowPeriodEndAdjustment = false,
    this.onPeriodEndChanged,
  });

  /// The currently selected date (period start)
  final DateTime? selectedDate;

  /// Callback when a date is tapped
  final ValueChanged<DateTime>? onDateSelected;

  /// List of days that are part of the period (for display)
  final List<DateTime> periodDays;

  /// End date of period (for O7 screen duration adjustment)
  final DateTime? periodEndDate;

  /// Whether to allow adjusting period end (O7 mode)
  final bool allowPeriodEndAdjustment;

  /// Callback when period end is adjusted
  final ValueChanged<DateTime>? onPeriodEndChanged;

  @override
  State<PeriodCalendar> createState() => _PeriodCalendarState();
}

class _PeriodCalendarState extends State<PeriodCalendar> {
  late ScrollController _scrollController;
  late DateTime _today;
  late List<DateTime> _months;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _today = DateTime.now();

    // Generate months for the past 6 months and current month
    _months = _generateMonths();

    // Schedule scroll to current month after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  List<DateTime> _generateMonths() {
    final months = <DateTime>[];
    final now = DateTime.now();

    // Show 6 months back and current month (7 total)
    for (int i = -6; i <= 0; i++) {
      months.add(DateTime(now.year, now.month + i, 1));
    }

    return months;
  }

  void _scrollToCurrentMonth() {
    if (!_scrollController.hasClients) return;

    // Scroll to bottom (current month)
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final phaseTokens = theme.extension<CyclePhaseTokens>();

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(Spacing.m),
      itemCount: _months.length,
      itemBuilder: (context, index) {
        final month = _months[index];
        return _MonthGrid(
          month: month,
          today: _today,
          selectedDate: widget.selectedDate,
          periodDays: widget.periodDays,
          periodEndDate: widget.periodEndDate,
          allowPeriodEndAdjustment: widget.allowPeriodEndAdjustment,
          onDateSelected: widget.onDateSelected,
          onPeriodEndChanged: widget.onPeriodEndChanged,
          colorScheme: colorScheme,
          textTheme: textTheme,
          phaseTokens: phaseTokens,
        );
      },
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selectedDate,
    required this.periodDays,
    required this.periodEndDate,
    required this.allowPeriodEndAdjustment,
    required this.onDateSelected,
    required this.onPeriodEndChanged,
    required this.colorScheme,
    required this.textTheme,
    required this.phaseTokens,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? selectedDate;
  final List<DateTime> periodDays;
  final DateTime? periodEndDate;
  final bool allowPeriodEndAdjustment;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onPeriodEndChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final CyclePhaseTokens? phaseTokens;

  @override
  Widget build(BuildContext context) {
    final monthName = _formatMonthName(context, month);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);

    // Monday = 1, Sunday = 7 (ISO)
    // We want Monday as first day, so offset is (weekday - 1)
    final startWeekday = firstDayOfMonth.weekday;
    final leadingEmptyDays = startWeekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            monthName,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: TypographyTokens.size16,
            ),
          ),
        ),
        // Weekday headers
        _buildWeekdayHeaders(context),
        SizedBox(height: Spacing.xs),
        // Days grid
        _buildDaysGrid(daysInMonth, leadingEmptyDays),
        SizedBox(height: Spacing.m),
      ],
    );
  }

  String _formatMonthName(BuildContext context, DateTime date) {
    try {
      final locale = Localizations.localeOf(context).toLanguageTag();
      return DateFormat('MMMM', locale).format(date);
    } catch (_) {
      // English fallback (intl should handle all common locales)
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return months[date.month - 1];
    }
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weekdays = [
      l10n.weekdayMondayShort,
      l10n.weekdayTuesdayShort,
      l10n.weekdayWednesdayShort,
      l10n.weekdayThursdayShort,
      l10n.weekdayFridayShort,
      l10n.weekdaySaturdayShort,
      l10n.weekdaySundayShort,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: DsColors.calendarWeekdayGray,
              fontWeight: FontWeight.w600,
              fontSize: TypographyTokens.size14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid(int daysInMonth, int leadingEmptyDays) {
    final totalCells = leadingEmptyDays + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - leadingEmptyDays + 1;

              if (cellIndex < leadingEmptyDays || dayNumber > daysInMonth) {
                return const SizedBox(
                  width: Sizes.touchTargetMin,
                  height: 48, // Matches _DayCell height for grid alignment
                );
              }

              final date = DateTime(month.year, month.month, dayNumber);
              return _DayCell(
                date: date,
                today: today,
                isSelected: _isSameDay(date, selectedDate),
                isPeriodDay: _isPeriodDay(date),
                isPeriodEnd: _isSameDay(date, periodEndDate),
                allowSelection: !date.isAfter(today),
                allowPeriodEndAdjustment: allowPeriodEndAdjustment,
                onTap: () => _handleDayTap(date),
                colorScheme: colorScheme,
                textTheme: textTheme,
                phaseTokens: phaseTokens,
              );
            }),
          ),
        );
      }),
    );
  }

  bool _isSameDay(DateTime date, DateTime? other) {
    if (other == null) return false;
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }

  bool _isPeriodDay(DateTime date) {
    for (final periodDay in periodDays) {
      if (_isSameDay(date, periodDay)) return true;
    }
    return false;
  }

  void _handleDayTap(DateTime date) {
    // Don't allow selecting future dates
    if (date.isAfter(today)) return;

    if (allowPeriodEndAdjustment) {
      // In O7 mode, tapping adjusts period end
      onPeriodEndChanged?.call(date);
    } else {
      // In O6 mode, tapping selects period start
      onDateSelected?.call(date);
    }
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.isSelected,
    required this.isPeriodDay,
    required this.isPeriodEnd,
    required this.allowSelection,
    required this.allowPeriodEndAdjustment,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
    required this.phaseTokens,
  });

  final DateTime date;
  final DateTime today;
  final bool isSelected;
  final bool isPeriodDay;
  final bool isPeriodEnd;
  final bool allowSelection;
  final bool allowPeriodEndAdjustment;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final CyclePhaseTokens? phaseTokens;

  bool get _isToday =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day;

  @override
  Widget build(BuildContext context) {
    final periodColor = DsColors.signature;
    final showPeriodCircle = isPeriodDay || isSelected;

    return Semantics(
      label: _buildSemanticLabel(context),
      button: allowSelection,
      selected: isSelected,
      child: GestureDetector(
        onTap: allowSelection ? onTap : null,
        child: SizedBox(
          width: 40,
          height: 48, // Increased to fit HEUTE label (24px circle + 12px text + 4px gap)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _isToday ? 24 : 32,
                height: _isToday ? 24 : 32,
                decoration: showPeriodCircle
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: periodColor,
                          width: 2,
                        ),
                        color: isSelected
                            ? periodColor.withValues(alpha: 0.2)
                            : null,
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  date.day.toString(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: allowSelection
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                    fontWeight: _isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: TypographyTokens.size14,
                  ),
                ),
              ),
              if (_isToday) ...[
                Text(
                  AppLocalizations.of(context)!.commonToday,
                  style: TextStyle(
                    color: DsColors.todayLabelGray,
                    fontSize: TypographyTokens.size12,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildSemanticLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dayLabel = DateFormat('d. MMMM yyyy', locale).format(date);
    if (_isToday) {
      return '${l10n.periodCalendarSemanticToday}, $dayLabel';
    }
    if (isSelected) {
      return '$dayLabel, ${l10n.periodCalendarSemanticSelected}';
    }
    if (isPeriodDay) {
      return '$dayLabel, ${l10n.periodCalendarSemanticPeriodDay}';
    }
    return dayLabel;
  }
}
