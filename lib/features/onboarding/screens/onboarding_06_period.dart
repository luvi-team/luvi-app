import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07_duration.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/custom_radio_check.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_glass_card.dart';
import 'package:luvi_app/features/onboarding/widgets/period_calendar.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding06: Period start calendar screen (O6)
/// Figma: 06_Onboarding (Periode Start)
/// Full calendar view where user taps the day their last period started.
/// No progress indicator (this is a calendar input screen).
class Onboarding06PeriodScreen extends ConsumerStatefulWidget {
  const Onboarding06PeriodScreen({super.key});

  static const routeName = '/onboarding/period-start';
  static const navName = 'onboarding_06_period';

  @override
  ConsumerState<Onboarding06PeriodScreen> createState() =>
      _Onboarding06PeriodScreenState();
}

class _Onboarding06PeriodScreenState extends ConsumerState<Onboarding06PeriodScreen> {
  DateTime? _selectedDate;
  bool _unknownSelected = false;
  bool _didRestoreState = false;

  @override
  void initState() {
    super.initState();
    // State restoration moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A1: Restore from OnboardingNotifier (back navigation)
    // Moved from initState to ensure widget is fully mounted before accessing Riverpod
    if (!_didRestoreState) {
      _didRestoreState = true;
      final onboardingState = ref.read(onboardingProvider);
      if (onboardingState.periodStart != null) {
        _selectedDate = onboardingState.periodStart;
      }
    }
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _unknownSelected = false;
    });
    // User will tap CTA to confirm and navigate (explicit UX)
  }

  void _handleUnknownToggle() {
    // Reversible toggle - user can toggle on/off, navigation via explicit CTA
    setState(() {
      _unknownSelected = !_unknownSelected;
      if (_unknownSelected) {
        _selectedDate = null;
      }
    });
  }

  void _navigateToNextScreen() {
    // Save to OnboardingNotifier if date selected
    if (_selectedDate != null) {
      ref.read(onboardingProvider.notifier).setPeriodStart(_selectedDate!);
    }
    // Navigate to O7 Period Duration Calendar
    context.pushNamed(
      Onboarding07DurationScreen.navName,
      extra: _selectedDate,
    );
  }

  /// Navigate directly to success screen when user selects "I don't remember"
  /// Privacy-safe: clears period data and skips O7 to avoid implicit cycle data
  void _navigateToSuccessScreen() {
    // Clear period data in provider (privacy-safe)
    ref.read(onboardingProvider.notifier).clearPeriodStart();

    // Skip O7 and go directly to O9 Success
    context.pushNamed(OnboardingSuccessScreen.navName);
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
    // A2: Removed unused dsTokens variable

    return Scaffold(
      body: Container(
        // Gradient fills entire screen (Figma v2)
        width: double.infinity,
        height: double.infinity,
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
                child: _buildCalendarCard(l10n),
              ),
              _buildUnknownOption(textTheme, colorScheme, l10n),
              _buildCta(l10n),
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
          BackButtonCircle(
            onPressed: _handleBack,
            iconColor: colorScheme.onSurface,
            showCircle: false,
            semanticLabel: l10n.authBackSemantic,
          ),
          SizedBox(width: Spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.onboarding06PeriodTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      fontFamily: FontFamilies.figtree,
                      color: colorScheme.onSurface,
                      fontSize: TypographyTokens.size20,
                      height: TypographyTokens.lineHeightRatio28on20,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                // Subheader (Figma v3: "Du kannst das später ändern.")
                Text(
                  l10n.onboarding06PeriodSubheader,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: TypographyTokens.size14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: OnboardingGlassCard(
        // Figma v3: 30% white opacity, 40px radius + BackdropFilter blur + border
        backgroundColor: DsColors.white.withValues(alpha: 0.30),
        borderRadius: Sizes.radiusXL,
        child: PeriodCalendar(
          selectedDate: _selectedDate,
          onDateSelected: _handleDateSelected,
          periodDays: const [], // No period days selected yet
        ),
      ),
    );
  }

  Widget _buildCta(AppLocalizations l10n) {
    // Show CTA when date selected OR unknown selected (explicit navigation)
    final showCta = _selectedDate != null || _unknownSelected;
    if (!showCta) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: OnboardingButton(
        key: const Key(TestKeys.o6Cta),
        label: l10n.commonContinue,
        onPressed: _unknownSelected ? _navigateToSuccessScreen : _navigateToNextScreen,
        isEnabled: true,
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
        toggled: _unknownSelected, // A4: Use toggled for on/off switches (not checked)
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
