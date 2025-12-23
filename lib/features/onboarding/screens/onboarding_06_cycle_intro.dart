import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05_interests.dart';
import 'package:luvi_app/features/onboarding/widgets/calendar_mini_widget.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding06: Cycle Intro screen (O6)
/// Figma: 06_Onboarding (Zyklus Intro)
/// Explains cycle tracking before calendar input
class Onboarding06CycleIntroScreen extends StatelessWidget {
  const Onboarding06CycleIntroScreen({super.key});

  static const routeName = '/onboarding/cycle-intro';

  /// Route name for pushNamed navigation (matches GoRouter name parameter)
  static const navName = 'onboarding_06_cycle_intro';

  void _handleContinue(BuildContext context) {
    context.pushNamed('onboarding_06_period');
  }

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding05InterestsScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = OnboardingSpacing.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        // Gradient fills entire screen (Figma v2)
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: DsGradients.onboardingStandard,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: spacing.topPadding),
                // Figma v4: Use OnboardingHeader for consistent 18px spacing
                OnboardingHeader(
                  title: l10n.onboardingCycleIntroTitle,
                  step: 6,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: () => _handleBack(context),
                ),
                SizedBox(height: Spacing.xl),
                // Calendar mini preview
                const CalendarMiniWidget(highlightedDay: 25),
                const Spacer(),
                // CTA Button (centered)
                Center(child: _buildCta(context, l10n)),
                SizedBox(height: Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCta(BuildContext context, AppLocalizations l10n) {
    return OnboardingButton(
      label: l10n.onboardingCycleIntroButton,
      onPressed: () => _handleContinue(context),
    );
  }
}
