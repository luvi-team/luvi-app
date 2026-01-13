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

/// Login bottom sheet content for Auth Rebrand v3.
///
/// Shows Apple/Google OAuth buttons and "Continue with Email" option.
/// Displayed via [AuthBottomSheetShell.show].
class AuthLoginSheet extends StatelessWidget {
  const AuthLoginSheet({
    super.key,
    required this.onApplePressed,
    required this.onGooglePressed,
    required this.onEmailPressed,
  });

  /// Callback when Apple sign-in is pressed
  final VoidCallback onApplePressed;

  /// Callback when Google sign-in is pressed
  final VoidCallback onGooglePressed;

  /// Callback when Email sign-in is pressed
  final VoidCallback onEmailPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Check if Apple Sign In is supported
    final appleSignInSupported = FeatureFlags.enableAppleSignIn &&
        (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS);

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
                    l10n.authLoginSheetHeadline,
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
                      onPressed: () {
                        Navigator.of(context).pop();
                        Future.delayed(
                          const Duration(milliseconds: 50),
                          onApplePressed,
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.s),
                  ],

                  // Google button
                  if (FeatureFlags.enableGoogleSignIn) ...[
                    AuthRebrandOutlineButton.google(
                      label: l10n.authContinueGoogle,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Future.delayed(
                          const Duration(milliseconds: 50),
                          onGooglePressed,
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.m),
                  ],

                  // Divider
                  Text(
                    l10n.authOr,
                    style: TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: 14,
                      color: DsColors.grayscale500,
                    ),
                  ),

                  const SizedBox(height: Spacing.m),

                  // Email button
                  AuthSecondaryButton(
                    label: l10n.authContinueEmail,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Future.delayed(
                        const Duration(milliseconds: 50),
                        onEmailPressed,
                      );
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
