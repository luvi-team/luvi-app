import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

/// Primary CTA button for Welcome screens (Figma Rebrand 2024).
///
/// Design specs from Figma:
/// - Width: 300px, Height: 56px
/// - Border radius: 12px
/// - Background: #E91E63 (pink)
/// - Label: Figtree 17px Bold, #FFFFFF
/// - Line-height: 24px (ratio 1.412)
///
/// Usage:
/// ```dart
/// WelcomeCtaButton(
///   label: l10n.welcomeNewCta1,
///   onPressed: _nextPage,
/// )
/// ```
class WelcomeCtaButton extends StatelessWidget {
  const WelcomeCtaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  /// The text displayed on the button.
  final String label;

  /// Callback when button is pressed. If null, button is disabled.
  final VoidCallback? onPressed;

  /// Whether the button is in loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: !isLoading && onPressed != null,
      child: SizedBox(
        width: Sizes.welcomeCtaWidth,
        height: Sizes.welcomeCtaHeight,
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
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.welcomeCtaRadius),
            ),
          ),
          child: ExcludeSemantics(
            child: isLoading
                ? SizedBox(
                    height: Sizes.loadingIndicatorSize,
                    width: Sizes.loadingIndicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: Sizes.loadingIndicatorStroke,
                      valueColor: const AlwaysStoppedAnimation(
                        DsColors.welcomeButtonText,
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontFamily: FontFamilies.figtree,
                      fontSize: TypographyTokens.size17,
                      fontWeight: FontWeight.w700,
                      height: TypographyTokens.lineHeightRatio24on17,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
