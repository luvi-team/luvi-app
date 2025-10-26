import 'package:flutter/material.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/screens/onboarding_05.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';

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
  static List<String> _cycleLengthOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      l10n?.cycleLengthShort ?? 'Kurz (alle 21-23 Tage)',
      l10n?.cycleLengthLonger ?? 'Etwas länger (alle 24-26 Tage)',
      l10n?.cycleLengthStandard ?? 'Standard (alle 27-30 Tage)',
      l10n?.cycleLengthLong ?? 'Länger (alle 31-35 Tage)',
      l10n?.cycleLengthVeryLong ?? 'Sehr lang (36+ Tage)',
    ];
  }

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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.topPadding),
                OnboardingHeader(
                  title: AppLocalizations.of(context)?.onboarding06Question ??
                      'Wie lange dauert dein Zyklus normalerweise?',
                  step: 6,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: _handleBack,
                ),
                SizedBox(height: spacing.headerToFirstOption06),
              _buildOptionList(spacing),
              SizedBox(height: spacing.lastOptionToCallout06),
              _buildCallout(textTheme, colorScheme),
              SizedBox(height: spacing.calloutToCta06),
              _buildCta(),
              SizedBox(height: spacing.ctaToHome06),
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
        context.go(Onboarding05Screen.routeName);
      }
    });
  }

  Widget _buildOptionList(OnboardingSpacing spacing) {
    final options = _cycleLengthOptions(context);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n?.onboarding06OptionsSemantic ?? 'Zykluslänge auswählen',
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

  Widget _buildCallout(TextTheme textTheme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Text(
      l10n?.onboarding06Callout ??
          'Jeder Zyklus ist einzigartig - wie du auch!',
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontSize: TypographyTokens.size16,
        height: TypographyTokens.lineHeightRatio24on16,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCta() {
    final l10n = AppLocalizations.of(context);
    final ctaLabel = l10n?.commonContinue ?? 'Weiter';
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
