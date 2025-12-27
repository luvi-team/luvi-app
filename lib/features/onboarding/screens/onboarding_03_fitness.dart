import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/onboarding/model/fitness_level.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_02.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_04_goals.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/onboarding/widgets/fitness_pill.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart' as user_state_svc;

/// Onboarding03: Fitness level single-select screen (O3)
/// Figma: 03_Onboarding (Fitnesslevel)
/// Shows 3 horizontal pills: "Nicht fit" | "Fit" | "Sehr fit"
class Onboarding03FitnessScreen extends ConsumerStatefulWidget {
  const Onboarding03FitnessScreen({super.key, this.userName});

  /// User's name from O1 for personalized title
  final String? userName;

  static const routeName = '/onboarding/03';

  /// GoRoute name for pushNamed navigation
  static const navName = 'onboarding_03_fitness';

  @override
  ConsumerState<Onboarding03FitnessScreen> createState() =>
      _Onboarding03FitnessScreenState();
}

class _Onboarding03FitnessScreenState
    extends ConsumerState<Onboarding03FitnessScreen> {
  FitnessLevel? _selectedLevel;

  @override
  void initState() {
    super.initState();
    // Riverpod ConsumerStatefulWidget: ref is available in initState.
    // This is safe because WidgetRef is initialized before initState runs.
    // See: https://riverpod.dev/docs/essentials/lifecycle
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.fitnessLevel != null) {
      _selectedLevel = onboardingState.fitnessLevel;
    }
  }

  void _selectLevel(FitnessLevel level) {
    setState(() {
      _selectedLevel = level;
    });
  }

  Future<void> _handleContinue() async {
    // Guard: require selection before navigation
    if (_selectedLevel == null) return;

    // Save to OnboardingNotifier (SSOT)
    ref.read(onboardingProvider.notifier).setFitnessLevel(_selectedLevel!);
    try {
      // Also save to UserStateService for backward compatibility
      // Note: bindUser is already called in main.dart auth state listener
      final userState =
          await ref.read(user_state_svc.userStateServiceProvider.future);
      final serviceFitness =
          user_state_svc.FitnessLevel.tryParse(_selectedLevel!.name) ??
              user_state_svc.FitnessLevel.beginner;
      await userState.setFitnessLevel(serviceFitness);
    } catch (e) {
      // Log error but proceed - data is saved in SSOT provider
      log.w(
        'Failed to sync fitness level to UserStateService',
        tag: 'Onboarding',
        error: e,
      );
    }

    // Navigate to O4 Goals
    if (mounted) context.pushNamed(Onboarding04GoalsScreen.navName);
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding02Screen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Read name from OnboardingNotifier (SSOT), fallback to widget.userName or default
    final onboardingState = ref.watch(onboardingProvider);
    final displayName = onboardingState.name ?? widget.userName ?? l10n.onboardingDefaultName;
    final title = l10n.onboarding03FitnessTitle(displayName);

    return Scaffold(
      body: Container(
        // Gradient fills entire screen (Figma v2)
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: DsGradients.onboardingStandard,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.topPadding),
                OnboardingHeader(
                  title: title,
                  step: 3,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: _handleBack,
                ),
                SizedBox(height: spacing.headerToSubtitle03),
                _buildSubtitle(textTheme, colorScheme, l10n),
                SizedBox(height: spacing.subtitleToPills03),
                _buildFitnessPills(l10n, spacing),
                SizedBox(height: spacing.pillsToCta03),
                Center(child: _buildCta(l10n)),
                SizedBox(height: Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Semantics(
      label: l10n.onboarding03FitnessSubtitle,
      child: ExcludeSemantics(
        child: Text(
          l10n.onboarding03FitnessSubtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontSize: TypographyTokens.size16,
            height: TypographyTokens.lineHeightRatio24on16,
          ),
        ),
      ),
    );
  }

  Widget _buildFitnessPills(AppLocalizations l10n, OnboardingSpacing spacing) {
    final levels = FitnessLevel.values;
    final halfGap = spacing.pillsGap03 / 2;

    return Semantics(
      label: l10n.onboarding03FitnessSemantic,
      child: Row(
        children: levels.asMap().entries.map((entry) {
          final index = entry.key;
          final level = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : halfGap,
                right: index == levels.length - 1 ? 0 : halfGap,
              ),
              child: FitnessPill(
                key: Key('fitness_pill_${level.name}'),
                label: level.label(l10n),
                selected: _selectedLevel == level,
                onTap: () => _selectLevel(level),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCta(AppLocalizations l10n) {
    final ctaLabel = l10n.commonContinue;

    return OnboardingButton(
      key: const Key('onb_cta'),
      label: ctaLabel,
      onPressed: _handleContinue,
      isEnabled: _selectedLevel != null,
    );
  }
}
