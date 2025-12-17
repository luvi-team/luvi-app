import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/effects.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/model/fitness_level.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_period.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/widgets/period_calendar.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart' as services;

/// Onboarding07: Period duration adjustment screen (O7)
/// Figma: 07_Onboarding (Periode Dauer)
/// Shows estimated period duration, user can adjust by tapping end day.
/// No progress indicator (this is a calendar input screen).
class Onboarding07DurationScreen extends ConsumerStatefulWidget {
  const Onboarding07DurationScreen({
    super.key,
    this.periodStartDate,
  });

  /// Period start date from O6 (can be passed via extra)
  final DateTime? periodStartDate;

  static const routeName = '/onboarding/period-duration';

  @override
  ConsumerState<Onboarding07DurationScreen> createState() =>
      _Onboarding07DurationScreenState();
}

class _Onboarding07DurationScreenState
    extends ConsumerState<Onboarding07DurationScreen> {
  late DateTime? _periodStart;
  late DateTime _periodEnd;
  late List<DateTime> _periodDays;

  @override
  void initState() {
    super.initState();
    _initializePeriodDates();
  }

  void _initializePeriodDates() {
    // Try widget param first, then OnboardingNotifier (for back navigation)
    final onboardingState = ref.read(onboardingProvider);
    _periodStart = widget.periodStartDate ?? onboardingState.periodStart;

    // Get saved duration from notifier or use default
    final savedDuration = onboardingState.periodDuration;

    if (_periodStart != null) {
      // Calculate end date using saved duration or default
      _periodEnd = _periodStart!.add(
        Duration(days: savedDuration - 1),
      );
      _updatePeriodDays();
    } else {
      // If no start date provided, use a default
      final now = DateTime.now();
      _periodStart = now.subtract(const Duration(days: 7));
      _periodEnd = _periodStart!.add(
        Duration(days: savedDuration - 1),
      );
      _updatePeriodDays();
    }
  }

  void _updatePeriodDays() {
    if (_periodStart == null) {
      _periodDays = [];
      return;
    }

    _periodDays = [];
    var current = _periodStart!;
    while (!current.isAfter(_periodEnd)) {
      _periodDays.add(current);
      current = current.add(const Duration(days: 1));
    }
  }

  void _handlePeriodEndChanged(DateTime newEndDate) {
    // Only allow adjustment if end date is after or equal to start
    if (_periodStart == null) return;
    if (newEndDate.isBefore(_periodStart!)) return;

    // Limit period duration to reasonable range (1-14 days)
    final duration = newEndDate.difference(_periodStart!).inDays + 1;
    if (duration < 1 || duration > 14) return;

    setState(() {
      _periodEnd = newEndDate;
      _updatePeriodDays();
    });
  }

  void _handleContinue() {
    // Save period duration to OnboardingNotifier
    final duration = _periodDays.length;
    ref.read(onboardingProvider.notifier).setPeriodDuration(duration);

    // Read FitnessLevel from OnboardingNotifier (SSOT for onboarding data)
    final onboardingState = ref.read(onboardingProvider);
    final appLevel = onboardingState.fitnessLevel ?? FitnessLevel.beginner;

    // Map App-FitnessLevel to Service-FitnessLevel (routes.dart expects Service enum)
    // Use tryParse for safety - if enum names ever diverge, fall back to beginner
    final serviceLevel = services.FitnessLevel.tryParse(appLevel.name) ??
        services.FitnessLevel.beginner;

    // Navigate to Success Screen with Service-FitnessLevel
    context.pushNamed(
      'onboarding_success',
      extra: serviceLevel,
    );
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding06PeriodScreen.routeName);
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
                child: _buildCalendarCard(dsTokens, l10n),
              ),
              Center(child: _buildCta(l10n)),
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
                l10n.onboarding07DurationTitle,
                style: textTheme.headlineMedium?.copyWith(
                  fontFamily: FontFamilies.playfairDisplay,
                  color: colorScheme.onSurface,
                  fontSize: TypographyTokens.size24,
                  height: TypographyTokens.lineHeightRatio32on24,
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
        // Figma v3: Glass calendar effect (30% white opacity + 40px radius)
        decoration: DsEffects.glassCalendar,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: PeriodCalendar(
            selectedDate: _periodStart,
            periodDays: _periodDays,
            periodEndDate: _periodEnd,
            allowPeriodEndAdjustment: true,
            onPeriodEndChanged: _handlePeriodEndChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildCta(AppLocalizations l10n) {
    final ctaLabel = l10n.commonContinue;

    return OnboardingButton(
      key: const Key('onb_cta'),
      label: ctaLabel,
      onPressed: _handleContinue,
      isEnabled: true,
    );
  }
}
