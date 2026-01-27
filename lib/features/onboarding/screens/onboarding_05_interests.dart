import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/onboarding/domain/interest.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_04_goals.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_06_cycle_intro.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/goal_card.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding05: Interests multi-select screen (O5)
/// Figma: 05_Onboarding (Interessen)
/// Shows 6 interest options, user must select 3-5
class Onboarding05InterestsScreen extends ConsumerStatefulWidget {
  const Onboarding05InterestsScreen({super.key});

  static const routeName = '/onboarding/05';

  /// GoRoute name for pushNamed navigation
  static const navName = 'onboarding_05_interests';

  @override
  ConsumerState<Onboarding05InterestsScreen> createState() =>
      _Onboarding05InterestsScreenState();
}

class _Onboarding05InterestsScreenState
    extends ConsumerState<Onboarding05InterestsScreen> {
  /// Validation based on provider state (SSOT)
  /// Uses shared constants from onboarding_constants.dart
  bool _isValidSelection(List<Interest> selectedInterests) {
    final count = selectedInterests.length;
    return count >= kMinInterestSelections && count <= kMaxInterestSelections;
  }

  /// Toggle interest - notifier enforces max=5 limit
  void _toggleInterest(Interest interest) {
    final changed = ref.read(onboardingProvider.notifier).toggleInterest(interest);
    if (!changed) {
      // Max selections reached - provide haptic feedback
      HapticFeedback.heavyImpact();
    }
  }

  void _handleContinue() {
    // Defensive guard: validate selection before navigation
    final selectedInterests = ref.read(onboardingProvider).selectedInterests;
    if (!_isValidSelection(selectedInterests)) return;
    context.pushNamed(Onboarding06CycleIntroScreen.navName);
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding04GoalsScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);
    final l10n = AppLocalizations.of(context)!;

    // SSOT: Watch provider for selected interests
    final selectedInterests = ref.watch(
      onboardingProvider.select((state) => state.selectedInterests),
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
                  title: l10n.onboarding05InterestsTitle,
                  step: 5,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: _handleBack,
                ),
                SizedBox(height: Spacing.m),
                _buildSubtitle(textTheme, colorScheme, l10n),
                SizedBox(height: spacing.headerToFirstCard),
                _buildInterestList(spacing, l10n, selectedInterests),
                SizedBox(height: spacing.lastCardToCta),
                Center(child: _buildCta(l10n, selectedInterests)),
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
      label: l10n.onboarding05InterestsSubtitle,
      child: ExcludeSemantics(
        child: Text(
          l10n.onboarding05InterestsSubtitle,
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

  Widget _buildInterestList(
    OnboardingSpacing spacing,
    AppLocalizations l10n,
    List<Interest> selectedInterests,
  ) {
    final interests = Interest.values;

    return Semantics(
      label: l10n.onboarding05InterestsSemantic,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: interests.length,
        itemBuilder: (context, index) {
          final interest = interests[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < interests.length - 1 ? spacing.cardGap : 0,
            ),
            child: GoalCard(
              key: Key('onb_interest_${interest.name}'),
              title: interest.label(l10n),
              selected: selectedInterests.contains(interest),
              onTap: () => _toggleInterest(interest),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCta(AppLocalizations l10n, List<Interest> selectedInterests) {
    return OnboardingButton(
      key: const Key(TestKeys.onbCta),
      label: l10n.commonContinue,
      onPressed: _handleContinue,
      isEnabled: _isValidSelection(selectedInterests),
    );
  }
}
