import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/widgets/onboarding/onboarding_header.dart';
import 'package:luvi_app/features/screens/onboarding_07.dart';
import 'package:luvi_app/features/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/features/shared/analytics/analytics_recorder.dart';
import 'package:luvi_app/features/shared/utils/run_catching.dart';
import 'package:luvi_app/features/widgets/goal_card.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_services/user_state_service.dart';

/// Onboarding08: Fitness level single-select screen
/// Figma: 08_Onboarding (Fitness-Level)
/// nodeId: 68479-6936
class Onboarding08Screen extends ConsumerStatefulWidget {
  const Onboarding08Screen({super.key});

  static const routeName = '/onboarding/08';

  @override
  ConsumerState<Onboarding08Screen> createState() => _Onboarding08ScreenState();
}

class _Onboarding08ScreenState extends ConsumerState<Onboarding08Screen> {
  int? _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Preload any saved selection for a smoother UX.
    // Safe to call from initState in ConsumerState.
    // ignore: discarded_futures
    _loadInitialSelection();
  }

  void _selectOption(int index) {
    setState(() {
      _selected = index;
    });
    // Persist immediately on selection; do not block UI/CTA state.
    final level = FitnessLevel.fromSelectionIndex(index);
    unawaited(_persistSelection(level));
  }

  Future<void> _handleContinue() async {
    final selected = _selected;
    if (selected == null || _isSaving) {
      return;
    }
    final level = FitnessLevel.fromSelectionIndex(selected);

    setState(() {
      _isSaving = true;
    });

    try {
      await _persistSelection(level);
      ref
          .read(analyticsRecorderProvider)
          .recordEvent(
            'onboarding_fitness_level_selected',
            properties: <String, Object?>{
              'level': level.name,
              'selection_index': selected,
            },
          );
      if (mounted) {
        context.go(OnboardingSuccessScreen.routeName, extra: level);
      }
    } catch (e) {
      // Log error and optionally show user feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.onboardingSuccessGenericError,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
    final isEnabled = _selected != null && !_isSaving;

    return Semantics(
      label: l10n.commonContinue,
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: isEnabled ? () => _handleContinue() : null,
        child: Text(l10n.commonContinue),
      ),
    );
  }

  Future<void> _loadInitialSelection() async {
    final userState = await tryOrNullAsync(
      () => ref.read(userStateServiceProvider.future),
      tag: 'userState',
    );
    if (userState == null) {
      // Failed to load user state for initial selection (logged via tryOrNullAsync)
      return;
    }
    final savedSelection = userState.fitnessLevel;
    final index = FitnessLevel.selectionIndexFor(savedSelection);
    if (!mounted || index == null) return;
    setState(() {
      _selected = index;
    });
  }

  Future<void> _persistSelection(FitnessLevel level) async {
    final userState = await tryOrNullAsync(
      () => ref.read(userStateServiceProvider.future),
      tag: 'userState',
    );
    if (userState == null) return;
    await userState.setFitnessLevel(level);
  }
}
