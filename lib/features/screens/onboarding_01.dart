import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/features/auth/widgets/auth_text_field.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/features/screens/onboarding_02.dart';
import 'package:luvi_app/features/screens/onboarding/utils/onboarding_constants.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// First onboarding screen: name input.
/// Displays title, step counter, instruction, text input, and CTA.
class Onboarding01Screen extends StatefulWidget {
  const Onboarding01Screen({super.key});

  static const routeName = '/onboarding/01';

  @override
  State<Onboarding01Screen> createState() => _Onboarding01ScreenState();
}

class _Onboarding01ScreenState extends State<Onboarding01Screen> {
  final _nameController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
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
    // push statt go: Back-Stack bewahren (Konsistenz mit 02–07)
    context.push(Onboarding02Screen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.m),
              _buildHeader(textTheme, colorScheme),
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
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final headerTitle = l10n.onboarding01Title;
    const step = 1;
    final stepSemantic = l10n.onboardingStepSemantic(step, kOnboardingTotalSteps);
    final stepFraction = l10n.onboardingStepFraction(step, kOnboardingTotalSteps);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            label: headerTitle,
            child: Text(
              headerTitle,
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: Spacing.s),
        Semantics(
          label: stepSemantic,
          child: Text(
            stepFraction,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ],
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
    final theme = Theme.of(context);
    final dividerThickness = theme.dividerTheme.thickness ?? 1;

    return Column(
      children: [
        Semantics(
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
        const SizedBox(height: Spacing.l),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: spacing.underlineWidth,
            child: Divider(
              height: 0,
              thickness: dividerThickness,
              color: colorScheme.onSurface.withValues(
                alpha: OpacityTokens.inactive,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCta(TextTheme textTheme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final ctaLabel = l10n.commonContinue;
    return Semantics(
      label: ctaLabel,
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: _hasText ? _handleContinue : null,
        child: Text(ctaLabel),
      ),
    );
  }
}
