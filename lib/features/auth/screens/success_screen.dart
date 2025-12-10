import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/auth/widgets/auth_radial_gradient_background.dart';
import 'package:luvi_app/features/auth/widgets/glow_checkmark.dart';
import 'package:luvi_app/features/consent/widgets/welcome_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// SuccessScreen with Figma Auth UI v2 design.
///
/// Figma Node: 68919:8802
/// Route: /auth/password/success
///
/// Features:
/// - Radial gradient background with beige glow
/// - GlowCheckmark icon (beige radial gradient + white checkmark)
/// - Title: "Geschafft!" (Playfair Regular 32px)
/// - Subtitle: "Neues Passwort gespeichert." (Playfair Regular 24px)
/// - CTA: "Zurück zur Anmeldung" → navigates to /auth/signin
class SuccessScreen extends StatelessWidget {
  static const String passwordSavedRoutePath = '/auth/password/success';
  static const String passwordSavedRouteName = 'password_saved';

  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Figma: Title style - Playfair Display Regular, 32px
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontFamily: FontFamilies.playfairDisplay,
      fontSize: AuthTypography.successTitleFontSize,
      height: AuthTypography.successTitleLineHeight,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface,
    );

    // Figma: Subtitle style - Playfair Display Regular, 24px
    final subtitleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontFamily: FontFamilies.playfairDisplay,
      fontSize: AuthTypography.successSubtitleFontSize,
      height: AuthTypography.successSubtitleLineHeight,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
    );

    return Scaffold(
      key: const ValueKey('auth_success_screen'),
      body: Stack(
        children: [
          // Full-screen radial gradient background
          const Positioned.fill(
            child: AuthRadialGradientBackground(),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Flexible top space
                const Spacer(flex: 2),

                // GlowCheckmark centered
                const GlowCheckmark(),

                // Space between icon and text
                const SizedBox(height: Spacing.l + Spacing.m), // ~40px

                // Title
                Text(
                  l10n.authSuccessTitle,
                  style: titleStyle,
                  textAlign: TextAlign.center,
                ),

                // Figma: Gap = 8px between title and subtitle
                const SizedBox(height: Spacing.xs),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
                  child: Text(
                    l10n.authSuccessSubtitle,
                    style: subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                ),

                // Flexible bottom space
                const Spacer(flex: 3),

                // CTA Button - navigates to /auth/signin per plan
                Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.l,
                    right: Spacing.l,
                    bottom: MediaQuery.of(context).padding.bottom + Spacing.l,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: Sizes.buttonHeightL,
                    child: WelcomeButton(
                      key: const ValueKey('success_cta_button'),
                      onPressed: () => context.goNamed('auth_signin'),
                      label: l10n.authSuccessBackToLogin,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
