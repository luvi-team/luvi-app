import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/screens/onboarding_06.dart';
import 'package:luvi_app/features/screens/onboarding_08.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding07: Cycle regularity single-select screen
/// Figma: 07_Onboarding (Zyklusregelmäßigkeit)
/// nodeId: 68479-6935
class Onboarding07Screen extends StatefulWidget {
  const Onboarding07Screen({super.key});

  static const routeName = '/onboarding/07';

  @override
  State<Onboarding07Screen> createState() => _Onboarding07ScreenState();
}

class _Onboarding07ScreenState extends State<Onboarding07Screen> {
  int? _selected;

  void _selectOption(int index) {
    setState(() {
      _selected = index;
    });
  }

  void _handleContinue() {
    // Navigate to next onboarding step (08)
    context.push(Onboarding08Screen.routeName);
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
                title: AppLocalizations.of(context)!.onboarding07Title,
                step: 7,
                totalSteps: kOnboardingTotalSteps,
                onBack: _handleBack,
              ),
              SizedBox(height: spacing.headerToFirstOption07),
              _buildOptionList(spacing),
              SizedBox(height: spacing.lastOptionToFootnote07),
              _buildFootnote(textTheme, colorScheme),
              SizedBox(height: spacing.footnoteToCta07),
              _buildCta(),
              SizedBox(height: spacing.ctaToHome07),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    navigator.maybePop().then((didPop) {
      if (!mounted) return;
      if (!didPop) {
        context.go(Onboarding06Screen.routeName);
      }
    });
  }

  Widget _buildOptionList(OnboardingSpacing spacing) {
    // Icons: clock (⏰), energy/lightning (⚡), help (❓)
    // Using Material Icons.access_time, Icons.flash_on, Icons.help_outline as fallback
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurface;
    final iconSize = theme.iconTheme.size ?? TypographyTokens.size20;
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (icon: Icons.access_time, label: l10n.onboarding07OptRegular),
      (icon: Icons.flash_on, label: l10n.onboarding07OptUnpredictable),
      (icon: Icons.help_outline, label: l10n.onboarding07OptUnknown),
    ];

    return Semantics(
      label: l10n.onboarding07OptionsSemantic,
      child: Column(
        children: List.generate(
          options.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < options.length - 1 ? spacing.optionGap07 : 0,
            ),
            child: GoalCard(
              key: Key('onb_option_$index'),
              icon: ExcludeSemantics(
                child: Icon(
                  options[index].icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
              title: options[index].label,
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
        l10n.onboarding07Footnote,
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
    final isEnabled = _selected != null;
    final l10n = AppLocalizations.of(context)!;

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
