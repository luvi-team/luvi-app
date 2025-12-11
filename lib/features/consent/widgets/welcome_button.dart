import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design_tokens/colors.dart';
import '../../../core/design_tokens/sizes.dart';

/// Pill-shaped primary CTA button for Welcome and Auth screens.
///
/// Provides consistent Design System styling across W1-W5 and Auth screens.
/// Uses [DsColors.welcomeButtonBg] (#A8406F) background
/// and [DsColors.welcomeButtonText] (white) foreground.
///
/// Usage:
/// ```dart
/// WelcomeButton(
///   label: l10n.commonContinue,
///   onPressed: () => context.go('/next'),
/// )
/// ```
///
/// For Auth screens with loading state:
/// ```dart
/// WelcomeButton(
///   label: l10n.authLoginCta,
///   onPressed: isValid ? _submit : null,
///   isLoading: true,
/// )
/// ```
class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.loadingKey,
    this.labelKey,
  });

  /// The text displayed on the button (e.g., "Weiter" or "Jetzt loslegen").
  final String label;

  /// Callback when button is pressed. If null, button is disabled.
  final VoidCallback? onPressed;

  /// Whether the button is in loading state.
  final bool isLoading;

  /// Optional key for the loading indicator (for testing).
  final Key? loadingKey;

  /// Optional key for the label text (for testing).
  final Key? labelKey;

  @override
  Widget build(BuildContext context) {
    // ElevatedButton provides built-in button semantics with child text as label.
    // No explicit Semantics wrapper needed.
    return ElevatedButton(
      // Auth-Flow Bugfix: Dezentes haptisches Feedback bei Button-Tap
      onPressed: isLoading || onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: DsColors.welcomeButtonBg,
        foregroundColor: DsColors.welcomeButtonText,
        disabledBackgroundColor: DsColors.welcomeButtonBg.withValues(alpha: 0.5),
        disabledForegroundColor: DsColors.welcomeButtonText.withValues(alpha: 0.7),
        padding: EdgeInsets.symmetric(
          vertical: Sizes.welcomeButtonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusWelcomeButton),
        ),
      ),
      child: isLoading
          ? SizedBox(
              key: loadingKey,
              height: Sizes.loadingIndicatorSize,
              width: Sizes.loadingIndicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: Sizes.loadingIndicatorStroke,
                valueColor: const AlwaysStoppedAnimation(DsColors.welcomeButtonText),
              ),
            )
          : Text(label, key: labelKey),
    );
  }
}
