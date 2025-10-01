import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/onboarding_06.dart';
import 'package:luvi_app/features/screens/onboarding_spacing.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';

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
    // Last onboarding step - navigate to completion/dashboard
    // TODO: Replace with actual dashboard/completion route when available
    context.push('/onboarding/done');
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
          padding: EdgeInsets.symmetric(
            horizontal: spacing.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing.topPadding),
              _buildHeader(textTheme, colorScheme),
              SizedBox(height: spacing.headerToQuestion07),
              _buildQuestion(textTheme, colorScheme),
              SizedBox(height: spacing.questionToFirstOption07),
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

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        BackButtonCircle(
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              context.pop();
            } else {
              context.go(Onboarding06Screen.routeName);
            }
          },
          iconColor: colorScheme.onSurface,
        ),
        Expanded(
          child: Semantics(
            header: true,
            label: 'Erzähl mir von dir, Schritt 7 von 7',
          child: Text(
            'Erzähl mir von dir 💜',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: TypographyTokens.size24,
              height: TypographyTokens.lineHeightRatio32on24,
            ),
          ),
        ),
        ),
        Semantics(
          label: 'Schritt 7 von 7',
          child: Text(
            '7/7',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(TextTheme textTheme, ColorScheme colorScheme) {
    return Semantics(
      label: 'Wie ist dein Zyklus so?',
      child: Text(
        'Wie ist dein Zyklus so?',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptionList(OnboardingSpacing spacing) {
    // Icons: clock (⏰), energy/lightning (⚡), help (❓)
    // Using Material Icons.access_time, Icons.flash_on, Icons.help_outline as fallback
    final iconColor = Theme.of(context).colorScheme.onSurface;
    final options = [
      (icon: Icons.access_time, label: 'Ziemlich regelmäßig'),
      (icon: Icons.flash_on, label: 'Eher unberechenbar'),
      (icon: Icons.help_outline, label: 'Keine Ahnung'),
    ];

    return Semantics(
      label: 'Zyklusregelmäßigkeit auswählen',
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
                  size: 24,
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
    return ExcludeSemantics(
      child: Text(
        'Ob Uhrwerk oder Chaos - ich verstehe beides!',
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
    final theme = Theme.of(context);
    final isEnabled = _selected != null;

    return Semantics(
      label: 'Weiter',
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: isEnabled ? _handleContinue : null,
        child: Text(
          'Weiter',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: TypographyTokens.size20,
            fontWeight: FontWeight.w700,
            height: TypographyTokens.lineHeightRatio24on20,
          ),
        ),
      ),
    );
  }
}
