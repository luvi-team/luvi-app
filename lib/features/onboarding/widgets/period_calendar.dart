import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Configuration record for _DayCell to reduce parameter bloat.
/// Groups 11 parameters into a single immutable config object.
typedef DayCellConfig = ({
  // Date state
  DateTime date,
  DateTime today,
  bool isSelected,
  bool isPeriodDay,
  bool isPeriodEnd,
  // Interaction
  bool allowSelection,
  bool allowPeriodEndAdjustment,
  VoidCallback onTap,
  // Theme
  ColorScheme colorScheme,
  TextTheme textTheme,
  CyclePhaseTokens? phaseTokens,
});

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

class _PeriodCalendarState extends State<PeriodCalendar>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  late DateTime _today;
  late List<DateTime> _months;

  // O(1) lookup set for period days (Fix 1)
  late Set<DateTime> _periodDaysSet;

  // B1: GlobalKey for scroll-to-current-month via ensureVisible
  final GlobalKey _currentMonthKey = GlobalKey();

  // B1: Current month index (8 months: 0-5 past, 6 current, 7 next)
  static const int _currentMonthIndex = 6;

  // B1: Retry limit for lazy-build fallback (max 3 attempts)
  int _scrollRetryCount = 0;
  static const int _maxScrollRetries = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _today = DateTime.now();
    _periodDaysSet = _normalizePeriodDays(widget.periodDays);

    // Generate months for the past 6 months and current month
    _months = _generateMonths();

    // Schedule scroll to current month after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  /// Normalizes period days to date-only DateTime for O(1) Set lookup.
  Set<DateTime> _normalizePeriodDays(List<DateTime> days) {
    return days.map((d) => DateTime(d.year, d.month, d.day)).toSet();
  }

  @override
  void didUpdateWidget(PeriodCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.periodDays, widget.periodDays)) {
      _periodDaysSet = _normalizePeriodDays(widget.periodDays);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshTodayIfNeeded();
    }
  }

  /// Refreshes _today and regenerates months if date changed (Fix 3).
  void _refreshTodayIfNeeded() {
    final now = DateTime.now();
    final newToday = DateTime(now.year, now.month, now.day);
    final oldToday = DateTime(_today.year, _today.month, _today.day);
    if (newToday != oldToday) {
      setState(() {
        _today = now;
        _months = _generateMonths();
      });
    }
  }

  List<DateTime> _generateMonths() {
    final months = <DateTime>[];
    final now = DateTime.now();

    // Show 6 months back, current month, and next month (8 total)
    // O8 End-Adjust mode needs next month for period-end selection across month boundaries
    for (int i = -6; i <= 1; i++) {
      months.add(DateTime(now.year, now.month + i, 1));
    }

    return months;
  }

  void _scrollToCurrentMonth() {
    // Safety: bail if widget was disposed before callback fires
    if (!mounted) return;
    if (!_scrollController.hasClients) return;

    // B1 Guard: Skip if list too small to scroll
    if (_scrollController.position.maxScrollExtent == 0) return;

    // B1: Use GlobalKey + ensureVisible for reliable scroll positioning
    // Fallback: If currentContext is null (lazy-build), trigger build first
    if (_currentMonthKey.currentContext == null) {
      if (_scrollRetryCount >= _maxScrollRetries) return;
      _scrollRetryCount++;

      // Jump to approximate position to trigger lazy build of current month
      final approxOffset = _scrollController.position.maxScrollExtent * 0.75;
      _scrollController.jumpTo(approxOffset);

      // Retry after next frame when widget should be built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // Check again inside callback
        _scrollToCurrentMonth();
      });
      return;
    }

    // B1: Use ensureVisible for accurate scroll to current month
    Scrollable.ensureVisible(
      _currentMonthKey.currentContext!,
      alignment: 0.0, // Top of viewport
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    // Saturate to prevent any pending callbacks from scheduling more retries
    _scrollRetryCount = _maxScrollRetries;
    WidgetsBinding.instance.removeObserver(this);
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
        // B1: Assign GlobalKey to current month for ensureVisible
        final isCurrentMonth = index == _currentMonthIndex;
        return _MonthGrid(
          key: isCurrentMonth ? _currentMonthKey : null,
          month: month,
          today: _today,
          selectedDate: widget.selectedDate,
          periodDaysSet: _periodDaysSet,
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
    super.key,
    required this.month,
    required this.today,
    required this.selectedDate,
    required this.periodDaysSet,
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
  final Set<DateTime> periodDaysSet;
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

  /// English fallback month names for locale errors.
  static const _fallbackMonths = [
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

  String _formatMonthName(BuildContext context, DateTime date) {
    try {
      final locale = Localizations.localeOf(context).toLanguageTag();
      return DateFormat('MMMM', locale).format(date);
    } on FormatException catch (e) {
      // DateFormat parsing failed - log in debug and use fallback
      assert(() {
        debugPrint('DateFormat FormatException: $e');
        return true;
      }());
      return _fallbackMonths[date.month - 1];
    } on ArgumentError catch (e) {
      // Invalid locale or pattern - log in debug and use fallback
      assert(() {
        debugPrint('DateFormat ArgumentError: $e');
        return true;
      }());
      return _fallbackMonths[date.month - 1];
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
                config: (
                  date: date,
                  today: today,
                  isSelected: _isSameDay(date, selectedDate),
                  isPeriodDay: _isPeriodDay(date),
                  isPeriodEnd: _isSameDay(date, periodEndDate),
                  // End-Adjust mode: Only allow valid range (1-14 days from start)
                  // Start-Select mode: Only allow past dates
                  allowSelection: allowPeriodEndAdjustment
                      ? _isInValidPeriodEndRange(date)
                      : !date.isAfter(today),
                  allowPeriodEndAdjustment: allowPeriodEndAdjustment,
                  onTap: () => _handleDayTap(date),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  phaseTokens: phaseTokens,
                ),
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

  /// O(1) lookup using pre-computed normalized Set.
  bool _isPeriodDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return periodDaysSet.contains(normalized);
  }

  /// Returns true if date is valid period-end (1-14 days after selectedDate).
  /// Used in End-Adjust mode (O7/O8) to limit selectable dates to valid range.
  bool _isInValidPeriodEndRange(DateTime date) {
    if (selectedDate == null) return false;
    final daysDiff = date.difference(selectedDate!).inDays;
    // Valid range: Same day (0) to 13 days after (=14 days total duration)
    return daysDiff >= 0 && daysDiff <= 13;
  }

  void _handleDayTap(DateTime date) {
    if (allowPeriodEndAdjustment) {
      // End-Adjust-Mode (O7/O8): Only allow taps within valid range
      if (!_isInValidPeriodEndRange(date)) return;
      onPeriodEndChanged?.call(date);
    } else {
      // Start-Select-Mode (O6): Only allow past dates
      if (date.isAfter(today)) return;
      onDateSelected?.call(date);
    }
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.config});

  /// Single config record replaces 11 individual parameters (P2.2 refactor).
  final DayCellConfig config;

  bool get _isToday =>
      config.date.year == config.today.year &&
      config.date.month == config.today.month &&
      config.date.day == config.today.day;

  @override
  Widget build(BuildContext context) {
    final periodColor = DsColors.signature;
    final showPeriodCircle = config.isPeriodDay || config.isSelected;

    return Semantics(
      label: _buildSemanticLabel(context),
      button: config.allowSelection,
      selected: config.isSelected,
      child: InkResponse(
        onTap: config.allowSelection
            ? () {
                HapticFeedback.lightImpact();
                config.onTap();
              }
            : null,
        radius: 24,
        highlightShape: BoxShape.circle,
        child: SizedBox(
          width: 40,
          height: 48, // Fits HEUTE label (32px circle + 12px text + 4px gap)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: showPeriodCircle
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: periodColor,
                          width: 2,
                        ),
                        // Figma v3: Transparent fill, only border colored
                        color: null,
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  config.date.day.toString(),
                  style: config.textTheme.bodyMedium?.copyWith(
                    // Figma v3: Red text for selected/period days
                    color: (config.isSelected || config.isPeriodDay)
                        ? DsColors.signature
                        : config.allowSelection
                            ? config.colorScheme.onSurface
                            : config.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                    fontWeight: _isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: TypographyTokens.size14,
                    // Stabilize vertical alignment across all day cells
                    height: 1.0,
                  ),
                ),
              ),
              // Figma v3: Gap between day number and HEUTE label
              const SizedBox(height: 4),
              // Always reserve space for HEUTE label to maintain consistent height
              if (_isToday)
                Text(
                  AppLocalizations.of(context)!.commonToday,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: DsColors.todayLabelGray,
                    // Figma v3: 10px font size for HEUTE label
                    fontSize: Sizes.todayLabelFontSize,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                // Invisible placeholder to reserve same space as HEUTE label
                // Height matches HEUTE text line height for grid consistency
                SizedBox(
                  height: Sizes.calendarDayLabelSize,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSemanticLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String dayLabel;
    try {
      final locale = Localizations.localeOf(context).toLanguageTag();
      dayLabel = DateFormat('d. MMMM yyyy', locale).format(config.date);
    } catch (e) {
      // Fallback for malformed locale or date (FormatException, ArgumentError)
      dayLabel = config.date.toIso8601String().split('T').first;
    }
    if (_isToday) {
      return '${l10n.periodCalendarSemanticToday}, $dayLabel';
    }
    if (config.isSelected) {
      return '$dayLabel, ${l10n.periodCalendarSemanticSelected}';
    }
    if (config.isPeriodDay) {
      return '$dayLabel, ${l10n.periodCalendarSemanticPeriodDay}';
    }
    return dayLabel;
  }
}
