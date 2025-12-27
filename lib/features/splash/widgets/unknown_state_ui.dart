import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/widgets/welcome_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Presentational widget for the Unknown/connectivity-error state.
///
/// Displays a message indicating connectivity issues with retry and sign out options.
/// State management (retry count, isRetrying) is owned by the parent widget.
///
/// Used by [SplashScreen] when the app cannot determine the user's authentication
/// or onboarding state due to network issues.
class UnknownStateUi extends StatelessWidget {
  const UnknownStateUi({
    super.key,
    required this.onRetry,
    required this.onSignOut,
    required this.canRetry,
    this.isRetrying = false,
  });

  /// Callback when the retry button is pressed.
  /// Pass null to disable the retry button (e.g., when max retries exhausted).
  final VoidCallback? onRetry;

  /// Callback when the sign out button is pressed.
  final VoidCallback onSignOut;

  /// Whether retry attempts are available.
  /// When false, the retry button is disabled.
  final bool canRetry;

  /// Whether a retry operation is in progress.
  /// When true, shows a loading indicator on the retry button.
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: DsColors.textPrimary,
              semanticLabel: l10n.splashGateUnknownTitle,
            ),
            const SizedBox(height: Spacing.l),
            Text(
              l10n.splashGateUnknownTitle,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.m),
            Text(
              l10n.splashGateUnknownBody,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xl),
            // Primary CTA: Retry (Welcome-style magenta pill button)
            SizedBox(
              width: double.infinity,
              child: WelcomeButton(
                label: l10n.splashGateRetryCta,
                onPressed: canRetry ? onRetry : null,
                isLoading: isRetrying,
              ),
            ),
            const SizedBox(height: Spacing.m),
            // Secondary CTA: Sign out (outline style)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DsColors.welcomeButtonBg,
                  side: const BorderSide(color: DsColors.welcomeButtonBg),
                  padding: const EdgeInsets.symmetric(
                    vertical: Sizes.welcomeButtonPaddingVertical,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.radiusWelcomeButton),
                  ),
                ),
                child: Text(l10n.splashGateSignOutCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
