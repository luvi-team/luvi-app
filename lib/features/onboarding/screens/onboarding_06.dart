import 'package:flutter/material.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_05.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_07.dart';
import 'package:luvi_app/features/onboarding/widgets/goal_card.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/consent/widgets/localized_builder.dart';

/// Onboarding06: Cycle length single-select screen
/// Figma: 06_Onboarding (Zyklusdauer)
/// nodeId: 68256-6510
class Onboarding06Screen extends StatefulWidget {
  const Onboarding06Screen({super.key});

  static const routeName = '/onboarding/06';

  @override
  State<Onboarding06Screen> createState() => _Onboarding06ScreenState();
}

class _Onboarding06ScreenState extends State<Onboarding06Screen> {
  static List<String> _cycleLengthOptions(AppLocalizations l10n) => [
        l10n.cycleLengthShort,
        l10n.cycleLengthLonger,
        l10n.cycleLengthStandard,
        l10n.cycleLengthLong,
        l10n.cycleLengthVeryLong,
      ];

  int? _selected;

  void _selectOption(int index) {
    setState(() {
      _selected = index;
    });
  }

  void _handleContinue() {
    context.push(Onboarding07Screen.routeName);
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
        child: LocalizedBuilder(
          builder: (ctx, l10n) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.topPadding),
                OnboardingHeader(
                  title: l10n.onboarding06Question,
                  step: 6,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: _handleBack,
                ),
                SizedBox(height: spacing.headerToFirstOption06),
                _buildOptionList(spacing, l10n),
                SizedBox(height: spacing.lastOptionToCallout06),
                _buildCallout(textTheme, colorScheme, l10n),
                SizedBox(height: spacing.calloutToCta06),
                _buildCta(l10n),
                SizedBox(height: spacing.ctaToHome06),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    final r = GoRouter.of(context);
    if (r.canPop()) {
      context.pop();
    } else {
      context.go(Onboarding05Screen.routeName);
    }
  }

  Widget _buildOptionList(OnboardingSpacing spacing, AppLocalizations l10n) {
    final options = _cycleLengthOptions(l10n);
    return Semantics(
      label: l10n.onboarding06OptionsSemantic,
      child: Column(
        children: List.generate(
          options.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < options.length - 1 ? spacing.optionGap06 : 0,
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

  Widget _buildCallout(
      TextTheme textTheme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Text(
      l10n.onboarding06Callout,
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontSize: TypographyTokens.size16,
        height: TypographyTokens.lineHeightRatio24on16,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCta(AppLocalizations l10n) {
    final ctaLabel = l10n.commonContinue;
    return Semantics(
      label: ctaLabel,
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: _selected != null ? _handleContinue : null,
        child: Text(ctaLabel),
      ),
    );
  }
}
