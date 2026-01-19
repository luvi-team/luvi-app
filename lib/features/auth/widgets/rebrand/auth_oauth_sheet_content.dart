import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:luvi_app/core/config/feature_flags.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'auth_content_card.dart';
import 'auth_rebrand_metrics.dart';
import 'auth_rebrand_outline_button.dart';
import 'auth_secondary_button.dart';

import 'auth_rebrand_text_styles.dart';

/// Shared OAuth content for Auth Rebrand v3 bottom sheets.
///
/// Provides the common layout for both login and register sheets:
/// - Headline (customizable)
/// - Apple OAuth button (if supported)
/// - Google OAuth button (if enabled)
/// - "or" divider
/// - Email button
///
/// Used internally by [AuthLoginSheet] and [AuthRegisterSheet].
class AuthOAuthSheetContent extends StatelessWidget {
  const AuthOAuthSheetContent({
    super.key,
    required this.headline,
    this.onApplePressed,
    this.onGooglePressed,
    required this.onEmailPressed,
  });

  /// The headline text to display at the top of the card.
  final String headline;

  /// Callback when Apple sign-in is pressed.
  final VoidCallback? onApplePressed;

  /// Callback when Google sign-in is pressed.
  final VoidCallback? onGooglePressed;

  /// Callback when Email sign-in is pressed.
  final VoidCallback onEmailPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Check if Apple Sign In is supported
    final appleSignInSupported = FeatureFlags.enableAppleSignIn &&
        (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AuthRebrandMetrics.contentTopGap), // Space for rainbow arcs

            AuthContentCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Headline
                  Text(
                    headline,
                    style: const TextStyle(
                      fontFamily: FontFamilies.playfairDisplay,
                      fontSize: AuthRebrandMetrics.headlineFontSize,
                      fontWeight: FontWeight.w600,
                      height: AuthRebrandMetrics.headlineLineHeight,
                      color: DsColors.authRebrandTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: Spacing.l),

                  // Apple button (if supported)
                  if (appleSignInSupported) ...[
                    AuthRebrandOutlineButton.apple(
                      label: l10n.authContinueApple,
                      onPressed: () async {
                        await Navigator.of(context).maybePop();
                        if (!context.mounted) return;
                        onApplePressed?.call();
                      },
                    ),
                    const SizedBox(height: Spacing.s),
                  ],

                  // Google button
                  if (FeatureFlags.enableGoogleSignIn) ...[
                    AuthRebrandOutlineButton.google(
                      label: l10n.authContinueGoogle,
                      onPressed: () async {
                        await Navigator.of(context).maybePop();
                        if (!context.mounted) return;
                        onGooglePressed?.call();
                      },
                    ),
                    const SizedBox(height: Spacing.m),
                  ],

                  // Divider (SSOT: Figma #030401, 17px, Regular)
                  Text(
                    l10n.authOr,
                    style: AuthRebrandTextStyles.divider,
                  ),

                  const SizedBox(height: Spacing.m),

                  // Email button
                  AuthSecondaryButton(
                    label: l10n.authContinueEmail,
                    onPressed: () async {
                      await Navigator.of(context).maybePop();
                      if (!context.mounted) return;
                      onEmailPressed();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AuthRebrandMetrics.sheetBottomGap), // Space for bottom stripes
          ],
        ),
      ),
    );
  }
}
