import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/features/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding08: Fitness level single-select screen
/// Figma: 08_Onboarding (Fitness-Level)
/// nodeId: 68479-6936
class Onboarding08Screen extends StatefulWidget {
  const Onboarding08Screen({super.key});

  static const routeName = '/onboarding/08';

  @override
  State<Onboarding08Screen> createState() => _Onboarding08ScreenState();
}

class _Onboarding08ScreenState extends State<Onboarding08Screen> {
  int? _selected;

  void _selectOption(int index) {
    setState(() {
      _selected = index;
    });
  }

  void _handleContinue() {
    context.go(OnboardingSuccessScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.topPadding),
                OnboardingHeader(
                  title: AppLocalizations.of(context)!.onboarding08Title,
                  step: 8,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: _handleBack,
                ),
                SizedBox(height: spacing.headerToQuestion08),
              _buildOptionList(spacing),
              SizedBox(height: spacing.lastOptionToFootnote08),
              _buildFootnote(textTheme, colorScheme),
              SizedBox(height: spacing.footnoteToCta08),
              _buildCta(),
              SizedBox(height: spacing.ctaToHome08),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding07Screen.routeName);
    }
  }

  Widget _buildOptionList(OnboardingSpacing spacing) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      l10n.onboarding08OptBeginner,
      l10n.onboarding08OptOccasional,
      l10n.onboarding08OptFit,
      l10n.onboarding08OptUnknown,
    ];

    return Semantics(
      label: l10n.onboarding08OptionsSemantic,
      child: Column(
        children: List.generate(
          options.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < options.length - 1 ? spacing.optionGap08 : 0,
            ),
            child: GoalCard(
              key: Key('onb_option_$index'),
              title: options[index],
              selected: _selected == index,
              onTap: () => _selectOption(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFootnote(TextTheme textTheme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return ExcludeSemantics(
      child: Text(
        l10n.onboarding08Footnote,
        style: textTheme.bodyMedium?.copyWith(
          fontSize: TypographyTokens.size16,
          height: TypographyTokens.lineHeightRatio24on16,
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCta() {
    final l10n = AppLocalizations.of(context)!;
    final isEnabled = _selected != null;

    return Semantics(
      label: l10n.commonContinue,
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: isEnabled ? _handleContinue : null,
        child: Text(l10n.commonContinue),
      ),
    );
  }
}
