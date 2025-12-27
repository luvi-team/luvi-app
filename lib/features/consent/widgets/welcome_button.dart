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
    // A11y-Fix: MergeSemantics ensures the label is correctly exposed to screen
    // readers while preserving ElevatedButton's tap action. Stack+Opacity pattern
    // keeps the Text in semantic tree even during loading.
    return MergeSemantics(
      child: Semantics(
        label: label,
        button: true,
        enabled: !isLoading && onPressed != null,
        child: ElevatedButton(
          onPressed: isLoading || onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: DsColors.welcomeButtonBg,
            foregroundColor: DsColors.welcomeButtonText,
            disabledBackgroundColor:
                DsColors.welcomeButtonBg.withValues(alpha: 0.5),
            disabledForegroundColor:
                DsColors.welcomeButtonText.withValues(alpha: 0.7),
            padding: EdgeInsets.symmetric(
              vertical: Sizes.welcomeButtonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.radiusWelcomeButton),
            ),
          ),
          child: ExcludeSemantics(
            // Exclude inner Text semantics since MergeSemantics provides the label
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Text always in tree for layout, but invisible during loading
                Opacity(
                  opacity: isLoading ? 0 : 1,
                  child: Text(label, key: labelKey),
                ),
                // Spinner only visible during loading
                if (isLoading)
                  SizedBox(
                    key: loadingKey,
                    height: Sizes.loadingIndicatorSize,
                    width: Sizes.loadingIndicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: Sizes.loadingIndicatorStroke,
                      valueColor:
                          const AlwaysStoppedAnimation(DsColors.welcomeButtonText),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
