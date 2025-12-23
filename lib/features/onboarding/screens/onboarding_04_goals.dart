import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/onboarding/model/goal.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_03_fitness.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/goal_card.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding04: Goals multi-select screen (O4)
/// Figma: 04_Onboarding (Ziele)
/// Shows 6 goal options with icons, multi-select
class Onboarding04GoalsScreen extends ConsumerStatefulWidget {
  const Onboarding04GoalsScreen({super.key});

  static const routeName = '/onboarding/04';
  static const navName = 'onboarding_04_goals';

  @override
  ConsumerState<Onboarding04GoalsScreen> createState() => _Onboarding04GoalsScreenState();
}

class _Onboarding04GoalsScreenState extends ConsumerState<Onboarding04GoalsScreen> {
  /// Toggle goal - notifier is SSOT, no local state
  void _toggleGoal(Goal goal) {
    ref.read(onboardingProvider.notifier).toggleGoal(goal);
  }

  void _handleContinue() {
    context.pushNamed(Onboarding05InterestsScreen.navName);
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding03FitnessScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);
    final l10n = AppLocalizations.of(context)!;

    // SSOT: Watch provider for selected goals
    final selectedGoals = ref.watch(
      onboardingProvider.select((state) => state.selectedGoals),
    );

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
                  title: l10n.onboarding04GoalsTitle,
                  step: 4,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: _handleBack,
                ),
                SizedBox(height: Spacing.m),
                _buildSubtitle(textTheme, colorScheme, l10n),
                SizedBox(height: spacing.headerToFirstCard),
                _buildGoalList(spacing, l10n, theme, selectedGoals),
                SizedBox(height: spacing.lastCardToCta),
                Center(child: _buildCta(l10n, selectedGoals)),
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
      label: l10n.onboarding04GoalsSubtitle,
      child: Text(
        l10n.onboarding04GoalsSubtitle,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: TypographyTokens.size16,
          height: TypographyTokens.lineHeightRatio24on16,
        ),
      ),
    );
  }

  Widget _buildGoalList(
    OnboardingSpacing spacing,
    AppLocalizations l10n,
    ThemeData theme,
    List<Goal> selectedGoals,
  ) {
    final iconSize = theme.iconTheme.size ?? TypographyTokens.size20;

    // Goal enum values in display order
    final goals = Goal.values;

    return Semantics(
      label: l10n.onboarding04GoalsSemantic,
      child: Column(
        children: List.generate(
          goals.length,
          (index) {
            final goal = goals[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < goals.length - 1 ? spacing.cardGap : 0,
              ),
              child: GoalCard(
                key: Key('onb_goal_${goal.name}'),
                // Use canonical Goal.iconPath extension instead of local mapping
                icon: ExcludeSemantics(
                  child: SvgPicture.asset(
                    goal.iconPath,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
                title: goal.label(l10n),
                selected: selectedGoals.contains(goal),
                onTap: () => _toggleGoal(goal),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCta(AppLocalizations l10n, List<Goal> selectedGoals) {
    return OnboardingButton(
      key: const Key('onb_cta'),
      label: l10n.commonContinue,
      onPressed: _handleContinue,
      isEnabled: selectedGoals.isNotEmpty,
    );
  }
}
