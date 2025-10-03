import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/onboarding_04.dart';
import 'package:luvi_app/features/screens/onboarding_06.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Onboarding05: Period duration single-select screen
/// Figma: 05_Onboarding (Periodendauer)
/// nodeId: 68214-6243
class Onboarding05Screen extends StatefulWidget {
  const Onboarding05Screen({super.key});

  static const routeName = '/onboarding/05';

  @override
  State<Onboarding05Screen> createState() => _Onboarding05ScreenState();
}

class _Onboarding05ScreenState extends State<Onboarding05Screen> {
  int? _selected;

  void _selectOption(int index) {
    setState(() {
      _selected = index;
    });
  }

  void _handleContinue() {
    context.push(Onboarding06Screen.routeName);
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
              _buildHeader(textTheme, colorScheme),
              SizedBox(height: spacing.headerToFirstOption05),
              _buildOptionList(spacing),
              SizedBox(height: spacing.lastOptionToCallout05),
              _buildCallout(textTheme, colorScheme),
              SizedBox(height: spacing.calloutToCta05),
              _buildCta(),
              SizedBox(height: spacing.ctaToHome05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.onboarding05Title;

    return Row(
      children: [
        BackButtonCircle(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final didPop = await navigator.maybePop();
            if (!mounted) return;
            if (!didPop) {
              context.go(Onboarding04Screen.routeName);
            }
          },
          iconColor: colorScheme.onSurface,
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: TypographyTokens.size24,
                height: TypographyTokens.lineHeightRatio32on24,
              ),
            ),
          ),
        ),
        Semantics(
          label: l10n.onboardingStepSemantic(5, 7),
          child: Text(
            '5/7',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionList(OnboardingSpacing spacing) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      l10n.onboarding05OptUnder3,
      l10n.onboarding05Opt3to5,
      l10n.onboarding05Opt5to7,
      l10n.onboarding05OptOver7,
    ];

    return Semantics(
      label: l10n.onboarding05OptionsSemantic,
      child: Column(
        children: List.generate(
          options.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < options.length - 1 ? spacing.optionGap05 : 0,
            ),
            child: GoalCard(
              key: Key('onb_option_$index'),
              icon: const SizedBox.shrink(), // No icon for radio options
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
    final l10n = AppLocalizations.of(context)!;
    final callout = l10n.onboarding05Callout;

    return Semantics(
      label: callout,
      child: Text(
        callout,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: TypographyTokens.size14,
          height: TypographyTokens.lineHeightRatio24on14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCta() {
    final l10n = AppLocalizations.of(context)!;
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
