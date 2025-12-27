import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_glass_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Custom birthdate picker with three wheels (Month, Day, Year).
///
/// Figma specs:
/// - Container: 333 × 280px
/// - Selection highlight: 313 × 56px, radius 14
/// - Age policy: 16-120 years (kMinAge, kMaxAge)
class BirthdatePicker extends StatefulWidget {
  const BirthdatePicker({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
  });

  /// Initial date to display
  final DateTime initialDate;

  /// Callback when date changes
  final ValueChanged<DateTime> onDateChanged;

  @override
  State<BirthdatePicker> createState() => _BirthdatePickerState();
}

class _BirthdatePickerState extends State<BirthdatePicker> {
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _yearController;

  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedYear;

  // Widget-specific layout constants (Figma Birthdate Picker specs)
  static const double _containerWidth = 333.0;
  static const double _containerHeight = 280.0;
  // Note: Highlight uses Positioned with left/right offsets instead of fixed width
  static const double _highlightHeight = 56.0;
  static const double _itemExtent = 56.0;
  static const double _perspective = 0.003;
  static const double _diameterRatio = 1.5;
  static const double _unselectedOpacity = 0.5;

  /// Minimum year based on max age policy (120 years back)
  /// Cached in initState to ensure consistent value during widget lifecycle.
  late final int _minimumYear;

  /// Maximum year based on min age policy (16 years back)
  /// Cached in initState to ensure consistent value during widget lifecycle.
  late final int _maximumYear;

  /// List of years in valid range (cached for performance)
  late final List<int> _years;

  /// Days in the selected month/year
  int get _daysInMonth => DateTime(_selectedYear, _selectedMonth + 1, 0).day;

  /// Get localized month name using intl DateFormat
  String _getMonthName(int month, String locale) {
    final date = DateTime(2024, month);
    return DateFormat.MMMM(locale).format(date);
  }

  @override
  void initState() {
    super.initState();

    // Cache year bounds once to ensure consistent values during widget lifecycle
    final now = DateTime.now();
    _minimumYear = now.year - kMaxAge;
    _maximumYear = now.year - kMinAge;

    // Cache years list once (avoids rebuilding on every access)
    _years = List.generate(
      _maximumYear - _minimumYear + 1,
      (i) => _maximumYear - i,
    );

    // Clamp initial date to valid range
    final clampedDate = _clampDate(widget.initialDate);

    _selectedMonth = clampedDate.month - 1;
    _selectedDay = clampedDate.day;
    _selectedYear = clampedDate.year;

    _monthController = FixedExtentScrollController(initialItem: _selectedMonth);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _yearController = FixedExtentScrollController(
      // Defensive clamp: indexOf returns -1 if not found (edge case)
      initialItem: _years.indexOf(_selectedYear).clamp(0, _years.length - 1),
    );
  }

  DateTime _clampDate(DateTime date) {
    final minDate = onboardingBirthdateMinDate();
    final maxDate = onboardingBirthdateMaxDate();

    if (date.isBefore(minDate)) return minDate;
    if (date.isAfter(maxDate)) return maxDate;
    return date;
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    // Clamp day if needed (e.g., Feb 30 -> Feb 28)
    final maxDay = _daysInMonth;
    if (_selectedDay > maxDay) {
      _selectedDay = maxDay;
      // Smooth animation for better UX when clamping invalid days
      if (_dayController.hasClients) {
        _dayController.animateToItem(
          _selectedDay - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } else {
        // Fallback if controller not attached (defensive)
        _dayController.jumpToItem(_selectedDay - 1);
      }
    }

    final newDate = DateTime(_selectedYear, _selectedMonth + 1, _selectedDay);
    widget.onDateChanged(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Semantics(
      label: l10n.onboarding02PickerSemantic,
      child: OnboardingGlassCard(
        child: SizedBox(
          width: _containerWidth,
          height: _containerHeight,
          child: Stack(
          children: [
            // Selection highlight - Figma v3: Asymmetric position (more right padding)
            Positioned(
              left: 8,
              right: 5,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  height: _highlightHeight,
                  decoration: BoxDecoration(
                    color: DsColors.transparent,
                    borderRadius: BorderRadius.circular(Sizes.radiusPickerHighlight),
                  ),
                ),
              ),
            ),
            // Wheels
            Row(
              children: [
                // Month wheel
                Expanded(
                  flex: 3,
                  child: _buildWheel(
                    controller: _monthController,
                    itemCount: 12,
                    itemBuilder: (index) => _getMonthName(index + 1, locale),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMonth = index;
                        _onDateChanged();
                      });
                    },
                  ),
                ),
                // Day wheel
                Expanded(
                  flex: 2,
                  child: _buildWheel(
                    controller: _dayController,
                    itemCount: _daysInMonth,
                    itemBuilder: (index) => '${index + 1}',
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedDay = index + 1;
                        _onDateChanged();
                      });
                    },
                  ),
                ),
                // Year wheel
                Expanded(
                  flex: 2,
                  child: _buildWheel(
                    controller: _yearController,
                    itemCount: _years.length,
                    itemBuilder: (index) => '${_years[index]}',
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedYear = _years[index];
                        _onDateChanged();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) itemBuilder,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      perspective: _perspective,
      diameterRatio: _diameterRatio,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          // Defensive guard: use initialItem if controller not yet attached
          final isSelected = controller.hasClients
              ? controller.selectedItem == index
              : controller.initialItem == index;
          return Center(
            child: Text(
              itemBuilder(index),
              style: TextStyle(
                fontSize: isSelected
                    ? TypographyTokens.size20
                    : TypographyTokens.size16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? DsColors.grayscaleBlack
                    : DsColors.grayscaleBlack.withValues(alpha: _unselectedOpacity),
              ),
            ),
          );
        },
      ),
    );
  }
}
