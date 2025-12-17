import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/effects.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/features/auth/widgets/auth_text_field.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/auth/screens/auth_signin_screen.dart';
import 'package:luvi_app/features/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// First onboarding screen: name input.
/// Displays title, step counter, instruction, text input, and CTA.
class Onboarding01Screen extends ConsumerStatefulWidget {
  const Onboarding01Screen({super.key});

  static const routeName = '/onboarding/01';

  @override
  ConsumerState<Onboarding01Screen> createState() => _Onboarding01ScreenState();
}

class _Onboarding01ScreenState extends ConsumerState<Onboarding01Screen> {
  final _nameController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
    // Restore state from Notifier (for back navigation)
    final onboardingState = ref.read(onboardingProvider);
    if (onboardingState.name != null && onboardingState.name!.isNotEmpty) {
      _nameController.text = onboardingState.name!;
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _nameController.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleContinue() {
    // Save name to OnboardingNotifier
    ref.read(onboardingProvider.notifier).setName(_nameController.text.trim());
    // Navigate to O2
    context.pushNamed('onboarding_02');
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      // Fallback to auth signin when no back stack is available
      context.go(AuthSignInScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: DsGradients.onboardingStandard,
        ),
        child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Spacing.m),
                OnboardingHeader(
                  title: AppLocalizations.of(context)!.onboarding01Title,
                  semanticsLabel:
                      AppLocalizations.of(context)!.onboarding01Title,
                  step: 1,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: _handleBack,
                ),
                SizedBox(height: spacing.headerToInstruction01),
                _buildInstruction(textTheme, colorScheme),
              SizedBox(height: spacing.instructionToInput01),
              _buildNameInput(textTheme, colorScheme, spacing),
              SizedBox(height: spacing.inputToCta01),
              _buildCta(textTheme, colorScheme),
              const SizedBox(height: Spacing.l),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildInstruction(TextTheme textTheme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final instruction = l10n.onboarding01Instruction;
    return Semantics(
      label: instruction,
      child: Text(
        instruction,
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNameInput(
    TextTheme textTheme,
    ColorScheme colorScheme,
    OnboardingSpacing spacing,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // Figma specs: Glass container 340×88px, radius 16, 10% white opacity
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.l,
      ),
      decoration: DsEffects.glassCard,
      child: Semantics(
        textField: true,
        label: l10n.onboarding01NameInputSemantic,
        child: AuthTextField(
          controller: _nameController,
          frameless: true,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          autofocus: true,
          hintText: '',
          onSubmitted: (_) {
            if (_hasText) {
              _handleContinue();
            }
          },
        ),
      ),
    );
  }

  Widget _buildCta(TextTheme textTheme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final ctaLabel = l10n.commonContinue;
    return OnboardingButton(
      key: const Key('onb_cta'),
      label: ctaLabel,
      onPressed: _handleContinue,
      isEnabled: _hasText,
    );
  }
}
