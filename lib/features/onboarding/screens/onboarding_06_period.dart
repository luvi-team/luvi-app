import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/custom_radio_check.dart';
import 'package:luvi_app/features/onboarding/widgets/period_calendar.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding06: Period start calendar screen (O6)
/// Figma: 06_Onboarding (Periode Start)
/// Full calendar view where user taps the day their last period started.
/// No progress indicator (this is a calendar input screen).
class Onboarding06PeriodScreen extends ConsumerStatefulWidget {
  const Onboarding06PeriodScreen({super.key});

  static const routeName = '/onboarding/period-start';

  @override
  ConsumerState<Onboarding06PeriodScreen> createState() =>
      _Onboarding06PeriodScreenState();
}

class _Onboarding06PeriodScreenState extends ConsumerState<Onboarding06PeriodScreen> {
  DateTime? _selectedDate;
  bool _unknownSelected = false;

  @override
  void initState() {
    super.initState();
    // Restore from OnboardingNotifier (back navigation)
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.periodStart != null) {
      _selectedDate = onboardingState.periodStart;
    }
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _unknownSelected = false;
    });
    // Auto-navigate to O7 Duration after selecting a date
    _navigateToNextScreen();
  }

  void _handleUnknownToggle() {
    setState(() {
      _unknownSelected = !_unknownSelected;
      if (_unknownSelected) {
        _selectedDate = null;
      }
    });
    // Auto-navigate when "I don't remember" is selected
    if (_unknownSelected) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // Save to OnboardingNotifier if date selected
    if (_selectedDate != null) {
      ref.read(onboardingProvider.notifier).setPeriodStart(_selectedDate!);
    }
    // Navigate to O7 Period Duration Calendar
    context.pushNamed(
      'onboarding_07_duration',
      extra: _selectedDate,
    );
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding05InterestsScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dsTokens = theme.extension<DsTokens>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DsGradients.onboardingStandard,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing.topPadding),
              _buildHeader(textTheme, colorScheme, spacing, l10n),
              SizedBox(height: Spacing.m),
              Expanded(
                child: _buildCalendarCard(dsTokens, l10n),
              ),
              _buildUnknownOption(textTheme, colorScheme, l10n),
              SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    TextTheme textTheme,
    ColorScheme colorScheme,
    OnboardingSpacing spacing,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: l10n.authBackSemantic,
            button: true,
            child: IconButton(
              key: const Key('onb_back'),
              icon: const Icon(Icons.chevron_left),
              onPressed: _handleBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: Sizes.touchTargetMin,
                minHeight: Sizes.touchTargetMin,
              ),
            ),
          ),
          SizedBox(width: Spacing.xs),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                l10n.onboarding06PeriodTitle,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: TypographyTokens.size20,
                  fontWeight: FontWeight.w600,
                  height: TypographyTokens.lineHeightRatio28on20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(DsTokens? dsTokens, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: Container(
        decoration: BoxDecoration(
          color: dsTokens?.cardSurface ?? DsColors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(Sizes.radiusXL),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Sizes.radiusXL),
          child: PeriodCalendar(
            selectedDate: _selectedDate,
            onDateSelected: _handleDateSelected,
            periodDays: const [], // No period days selected yet
          ),
        ),
      ),
    );
  }

  Widget _buildUnknownOption(
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: Semantics(
        label: l10n.onboarding06PeriodUnknown,
        button: true,
        selected: _unknownSelected,
        child: InkWell(
          onTap: _handleUnknownToggle,
          borderRadius: BorderRadius.circular(Sizes.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Spacing.m,
              horizontal: Spacing.s,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomRadioCheck(
                  selected: _unknownSelected,
                ),
                const SizedBox(width: Spacing.s),
                Text(
                  l10n.onboarding06PeriodUnknown,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: TypographyTokens.size16,
                    height: TypographyTokens.lineHeightRatio24on16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
