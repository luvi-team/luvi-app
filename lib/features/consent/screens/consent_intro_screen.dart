import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/consent_spacing.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/consent/screens/consent_options_screen.dart';
import 'package:luvi_app/core/widgets/welcome_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// C1 - Consent Intro Screen
///
/// First screen in the consent flow. Introduces the user to the data consent
/// process with a friendly illustration and message.
///
/// Route: /consent/intro (canonical path per Welcome Rebrand Plan)
/// Legacy /consent/02 redirects here via router.dart alias.
class ConsentIntroScreen extends StatelessWidget {
  const ConsentIntroScreen({super.key});

  /// Canonical route path for consent intro screen.
  /// Legacy /consent/02 redirects here via router.dart.
  static const routeName = RoutePaths.consentIntro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: DsColors.bgCream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ConsentSpacing.pageHorizontal),
          child: Column(
            children: [
              // Content - centered vertically
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration (Figma: 265 x 303 px, scalable)
                    Semantics(
                      label: l10n.consentIntroIllustrationSemantic,
                      child: Image.asset(
                        Assets.images.consentIntroHero,
                        width: 265,
                        height: 303,
                        fit: BoxFit.contain,
                        errorBuilder: Assets.defaultImageErrorBuilder,
                      ),
                    ),
                    SizedBox(height: Spacing.xl),

                    // Title (Figma: Playfair Display SemiBold 30px)
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.consentIntroTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontFamily: FontFamilies.playfairDisplay,
                          fontWeight: FontWeight.w600,
                          fontSize: ConsentTypography.introTitleFontSize,
                          height: ConsentTypography.introTitleLineHeight,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.m),

                    // Body Text (Figma: Figtree Regular 18px)
                    Text(
                      l10n.consentIntroBody,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontFamily: FontFamilies.figtree,
                        fontWeight: FontWeight.w400,
                        fontSize: ConsentTypography.introBodyFontSize,
                        height: ConsentTypography.introBodyLineHeight,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom CTA (WelcomeButton - reused from existing component)
              // Note: SafeArea already handles bottom inset, only add Spacing.l
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.l),
                child: SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    label: l10n.consentIntroCtaSemantic,
                    child: WelcomeButton(
                      label: l10n.consentIntroCtaLabel,
                      onPressed: () => context.push(ConsentOptionsScreen.routeName),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
