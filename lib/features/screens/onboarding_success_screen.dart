import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Final screen after onboarding completes.
/// Shows a trophy visual, celebratory title, and CTA to open the dashboard.
class OnboardingSuccessScreen extends StatelessWidget {
  const OnboardingSuccessScreen({super.key});

  static const routeName = '/onboarding/success';
  // Encapsulated illustration dimensions (per Figma bounds 308x300)
  static const double _kTrophyWidth = 308.0;
  static const double _kTrophyHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final spacing = OnboardingSpacing.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.horizontalPadding),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.l),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTrophy(l10n),
                    SizedBox(height: spacing.trophyToTitle),
                    _buildTitle(textTheme, colorScheme, l10n),
                    SizedBox(height: spacing.titleToButton),
                    _buildButton(context, l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy(AppLocalizations l10n) {
    // Trophy is decorative (title already communicates success)
    // From Figma audit: Trophy bounding box 308×300px
    // PNG format ensures pixel-perfect match with complex Figma illustration
    return ExcludeSemantics(
      child: Center(
        child: Image.asset(
          Assets.images.onboardingSuccessTrophy,
          width: _kTrophyWidth,
          height: _kTrophyHeight,
          errorBuilder: Assets.defaultImageErrorBuilder,
        ),
      ),
    );
  }

  Widget _buildTitle(
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    // From Figma audit: Playfair Display Regular 24px/32px (Heading 2 token)
    return Semantics(
      header: true,
      child: Text(
        l10n.onboardingSuccessTitle,
        textAlign: TextAlign.center,
        style: textTheme.headlineMedium?.copyWith(
          fontFamily: FontFamilies.playfairDisplay,
          fontSize: TypographyTokens.size24,
          height: TypographyTokens.lineHeightRatio32on24,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, AppLocalizations l10n) {
    // ElevatedButton already provides accessible label from visible text
    return ElevatedButton(
      key: const Key('onboarding_success_cta'),
      onPressed: () => context.go(HeuteScreen.routeName),
      child: Text(l10n.onboardingSuccessButton),
    );
  }
}
