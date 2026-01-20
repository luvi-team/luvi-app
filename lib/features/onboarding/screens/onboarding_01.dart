import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/gradients.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/onboarding/state/onboarding_state.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_glass_card.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_header.dart';
import 'package:luvi_app/features/onboarding/widgets/onboarding_button.dart';
import 'package:luvi_app/features/onboarding/screens/onboarding_02.dart';
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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Restore state from Notifier (for back navigation)
    // Moved from initState to ensure widget is fully mounted before accessing Riverpod
    if (!_initialized) {
      _initialized = true;
      final onboardingState = ref.read(onboardingProvider);
      if (onboardingState.name != null && onboardingState.name!.isNotEmpty) {
        _nameController.text = onboardingState.name!;
      }
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
    context.pushNamed(Onboarding02Screen.navName);
  }

  void _handleBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
    } else {
      // Fallback to auth signin when no back stack is available
      context.go(RoutePaths.authSignIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = OnboardingSpacing.of(context);

    return Scaffold(
      backgroundColor: DsColors.goldLight,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          // Ensure gradient fills entire screen even with keyboard
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: DsGradients.onboardingStandard,
          ),
          child: SafeArea(
          child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.topPadding),
                OnboardingHeader(
                  title: AppLocalizations.of(context)!.onboarding01Title,
                  semanticsLabel:
                      AppLocalizations.of(context)!.onboarding01Title,
                  step: 1,
                  totalSteps: kOnboardingTotalSteps,
                  onBack: _handleBack,
                ),
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
      ),
    );
  }

  Widget _buildNameInput(
    TextTheme textTheme,
    ColorScheme colorScheme,
    OnboardingSpacing spacing,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Debug assertion + safe fallback for DsTokens
    final themeTokens = Theme.of(context).extension<DsTokens>();
    assert(themeTokens != null, 'DsTokens extension must be provided in Theme');
    final tokens = themeTokens ?? DsTokens.light;

    final resolvedFontSize = Sizes.onboardingInputFontSize;
    // Extracted constant
    const designLineHeightPx = Sizes.onboardingLineHeightPx;
    
    final computedHeight = designLineHeightPx / resolvedFontSize;
    final resolvedHeight = math.max(1.2, computedHeight);
    
    final inputStyle = textTheme.bodySmall?.copyWith(
      fontSize: resolvedFontSize,
      fontFamily: FontFamilies.playfairDisplay,
      fontWeight: FontWeight.bold,
      height: resolvedHeight,
      color: colorScheme.onSurface,
    );
    final hintStyle = inputStyle?.copyWith(color: tokens.grayscale500);

    // Figma specs: Glass container 340×88px, radius 16, BackdropFilter blur (v3)
    return OnboardingGlassCard(
      child: Semantics(
        textField: true,
        label: l10n.onboarding01NameInputSemantic,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.l,
          ),
          // Figma: Selection bg transparent, Cursor/Handle black
          child: TextSelectionTheme(
            data: const TextSelectionThemeData(
              selectionColor: DsColors.transparent,
              cursorColor: DsColors.grayscaleBlack,
              selectionHandleColor: DsColors.grayscaleBlack,
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              autofocus: true,
              style: inputStyle,
              decoration:
                  const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ).copyWith(
                    hintText: l10n.onboarding01NameHint,
                    hintStyle: hintStyle,
                  ),
              onSubmitted: (_) {
                if (_hasText) {
                  _handleContinue();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCta(TextTheme textTheme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final ctaLabel = l10n.commonContinue;
    return Center(
      child: OnboardingButton(
        key: const Key('onb_cta'),
        label: ctaLabel,
        onPressed: _handleContinue,
        isEnabled: _hasText,
      ),
    );
  }
}
