import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/features/screens/onboarding_04.dart';
import 'package:luvi_app/features/screens/onboarding_spacing.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';

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
    // TODO: Replace with actual next route when available
    context.push('/onboarding/06');
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
              SizedBox(height: spacing.headerToQuestion05),
              _buildQuestion(textTheme, colorScheme),
              SizedBox(height: spacing.questionToFirstOption05),
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
    return Row(
      children: [
        BackButtonCircle(
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              context.pop();
            } else {
              context.go(Onboarding04Screen.routeName);
            }
          },
          iconColor: colorScheme.onSurface,
        ),
        Expanded(
          child: Semantics(
            header: true,
            label: 'Erzähl mir von dir, Schritt 5 von 7',
            child: Text(
              'Erzähl mir von dir 💜',
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 24,
                height: 32 / 24,
              ),
            ),
          ),
        ),
        Semantics(
          label: 'Schritt 5 von 7',
          child: Text(
            '5/7',
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
      label: 'Wie lange dauert deine Periode normalerweise?',
      child: Text(
        'Wie lange dauert deine Periode\nnormalerweise?',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptionList(OnboardingSpacing spacing) {
    final options = [
      'Weniger als 3 Tage',
      'Zwischen 3 und 5 Tage',
      'Zwischen 5 und 7 Tage',
      'Mehr als 7 Tage',
    ];

    return Semantics(
      label: 'Periodendauer auswählen',
      child: Column(
        children: List.generate(
          options.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < options.length - 1 ? spacing.optionGap05 : 0,
            ),
            child: GoalCard(
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
    return Semantics(
      label: 'Hinweis: Wir brauchen diesen Ausgangspunkt, um deine aktuelle '
          'Zyklusphase zu berechnen. Ich lerne mit dir mit und passe die '
          'Prognosen automatisch an, sobald du deine nächste Periode einträgst.',
      child: Text(
        'Wir brauchen diesen Ausgangspunkt, um deine aktuelle Zyklusphase zu '
        'berechnen. Ich lerne mit dir mit und passe die Prognosen automatisch '
        'an, sobald du deine nächste Periode einträgst.',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 14,
          height: 24 / 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCta() {
    return ElevatedButton(
      onPressed: _selected != null ? _handleContinue : null,
      child: const Text('Weiter'),
    );
  }
}
