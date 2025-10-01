import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/opacity.dart';
import 'package:luvi_app/features/auth/widgets/auth_text_field.dart';
import 'package:luvi_app/features/screens/onboarding_spacing.dart';

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
    // Happy Path: no validation, navigate directly to step 2
    context.push('/onboarding/02');
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            label: 'Erzähl mir von dir',
            child: Text(
              'Erzähl mir von dir 💜',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: Spacing.s),
        Semantics(
          label: 'Schritt 1 von 7',
          child: Text(
            '1/7',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(TextTheme textTheme, ColorScheme colorScheme) {
    return Semantics(
      label: 'Wie soll ich dich nennen?',
      child: Text(
        'Wie soll ich dich nennen?',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNameInput(
    TextTheme textTheme,
    ColorScheme colorScheme,
    OnboardingSpacing spacing,
  ) {
    return Column(
      children: [
        Semantics(
          textField: true,
          label: 'Name eingeben',
          child: AuthTextField(
            controller: _nameController,
            frameless: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofocus: true,
            hintText: '',
            onSubmitted: (_) => _handleContinue(),
          ),
        ),
        const SizedBox(height: Spacing.l),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: spacing.underlineWidth,
            child: Divider(
              height: 0,
              thickness: 1,
              color:
                  colorScheme.onSurface.withValues(alpha: OpacityTokens.inactive),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCta(TextTheme textTheme, ColorScheme colorScheme) {
    return Semantics(
      label: 'Weiter',
      button: true,
      child: ElevatedButton(
        key: const Key('onb_cta'),
        onPressed: _hasText ? _handleContinue : null,
        child: const Text('Weiter'),
      ),
    );
  }
}
