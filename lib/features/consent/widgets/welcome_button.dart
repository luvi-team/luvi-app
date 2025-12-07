import 'package:flutter/material.dart';
import '../../../core/design_tokens/colors.dart';
import '../../../core/design_tokens/sizes.dart';

/// Pill-shaped primary CTA button for Welcome screens.
///
/// Provides consistent Design System styling across W1-W5 screens.
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
class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// The text displayed on the button (e.g., "Weiter" or "Jetzt loslegen").
  final String label;

  /// Callback when button is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // ElevatedButton provides built-in button semantics with child text as label.
    // No explicit Semantics wrapper needed.
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: DsColors.welcomeButtonBg,
        foregroundColor: DsColors.welcomeButtonText,
        padding: EdgeInsets.symmetric(
          vertical: Sizes.welcomeButtonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusWelcomeButton),
        ),
      ),
      child: Text(label),
    );
  }
}
