import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/onboarding_02.dart';
import 'package:luvi_app/features/screens/onboarding_04.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';

/// Onboarding03: Goals multi-select screen
/// Figma: 03_Onboarding (Ziele)
/// nodeId: 68186-7924
class Onboarding03Screen extends StatefulWidget {
  const Onboarding03Screen({super.key});

  static const routeName = '/onboarding/03';

  @override
  State<Onboarding03Screen> createState() => _Onboarding03ScreenState();
}

class _Onboarding03ScreenState extends State<Onboarding03Screen> {
  // Multi-select state: Track selected goal indices
  final Set<int> _selectedGoals = {}; // Start with no selection

  void _toggleGoal(int index) {
    setState(() {
      if (_selectedGoals.contains(index)) {
        _selectedGoals.remove(index);
      } else {
        _selectedGoals.add(index);
      }
    });
  }

  void _handleContinue() {
    context.push(Onboarding04Screen.routeName);
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
              SizedBox(height: spacing.headerToFirstCard),
              _buildGoalList(spacing),
              SizedBox(height: spacing.lastCardToCta),
              _buildCta(),
              SizedBox(height: spacing.lastCardToCta), // Match Figma spacing
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
              context.go(Onboarding02Screen.routeName);
            }
          },
          iconColor: colorScheme.onSurface,
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              'Was sind deine Ziele?',
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
          label: 'Schritt 3 von 7',
          child: Text(
            '3/7',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalList(OnboardingSpacing spacing) {
    const goals = [
      _GoalItem(
        icon: ExcludeSemantics(
          child: Icon(Icons.favorite_border, size: 24),
        ),
        title: 'Meinen Zyklus & Körper besser verstehen',
      ),
      _GoalItem(
        icon: ExcludeSemantics(
          child: Icon(Icons.fitness_center, size: 24),
        ),
        title: 'Training an meinen Zyklus anpassen',
      ),
      _GoalItem(
        icon: ExcludeSemantics(
          child: Icon(Icons.restaurant, size: 24),
        ),
        title: 'Ernährung optimieren & neue Rezepte entdecken',
      ),
      _GoalItem(
        icon: ExcludeSemantics(
          child: Icon(Icons.monitor_weight, size: 24),
        ),
        title: 'Gewicht managen (Abnehmen/Halten)',
      ),
      _GoalItem(
        icon: ExcludeSemantics(
          child: Icon(Icons.self_improvement, size: 24),
        ),
        title: 'Stress reduzieren & Achtsamkeit stärken',
      ),
    ];

    return Column(
      children: List.generate(
        goals.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < goals.length - 1 ? spacing.cardGap : 0,
          ),
          child: GoalCard(
            key: Key('onb_option_$index'),
            icon: goals[index].icon,
            title: goals[index].title,
            selected: _selectedGoals.contains(index),
            onTap: () => _toggleGoal(index),
          ),
        ),
      ),
    );
  }

  Widget _buildCta() {
    return Semantics(
      label: 'Weiter',
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: _selectedGoals.isNotEmpty ? _handleContinue : null,
        child: const Text('Weiter'),
      ),
    );
  }
}

class _GoalItem {
  final Widget icon;
  final String title;

  const _GoalItem({required this.icon, required this.title});
}
