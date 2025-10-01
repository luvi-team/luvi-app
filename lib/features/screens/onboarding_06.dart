import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/onboarding_05.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';

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
  int? _selected;

  void _selectOption(int index) {
    setState(() {
      _selected = index;
    });
  }

  void _handleContinue() {
    // TODO: Replace with actual next route when available
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
          padding: EdgeInsets.symmetric(
            horizontal: spacing.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing.topPadding),
              _buildHeader(textTheme, colorScheme),
              SizedBox(height: spacing.headerToQuestion06),
              _buildQuestion(textTheme, colorScheme),
              SizedBox(height: spacing.questionToFirstOption06),
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

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        BackButtonCircle(
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              context.pop();
            } else {
              context.go(Onboarding05Screen.routeName);
            }
          },
          iconColor: colorScheme.onSurface,
        ),
        Expanded(
          child: Semantics(
            header: true,
            label: 'Erzähl mir von dir, Schritt 6 von 7',
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
          label: 'Schritt 6 von 7',
          child: Text(
            '6/7',
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
      label: 'Wie lange dauert dein Zyklus normalerweise?',
      child: Text(
        'Wie lange dauert dein Zyklus\nnormalerweise?',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptionList(OnboardingSpacing spacing) {
    final options = [
      'Kurz (alle 21-23 Tage)',
      'Etwas länger (alle 24-26 Tage)',
      'Standard (alle 27-30 Tage)',
      'Länger (alle 31-35 Tage)',
      'Sehr lang (36+ Tage)',
    ];

    return Semantics(
      label: 'Zykluslänge auswählen',
      child: Column(
        children: List.generate(
          options.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < options.length - 1 ? spacing.optionGap06 : 0,
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
    return ExcludeSemantics(
      child: Text(
        'Jeder Zyklus ist einzigartig - wie du auch!',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: TypographyTokens.size16,
          height: TypographyTokens.lineHeightRatio24on16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCta() {
    return Semantics(
      label: 'Weiter',
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: _selected != null ? _handleContinue : null,
        child: const Text('Weiter'),
      ),
    );
  }
}
