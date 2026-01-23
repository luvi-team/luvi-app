import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/features/auth/widgets/rebrand/auth_rebrand_metrics.dart';

/// Error banner for Auth Rebrand v3 screens.
///
/// Displays a styled error message with:
/// - Red background (10% opacity) with red border
/// - Error text centered in Figtree font
/// - Consistent spacing and border radius
///
/// Usage:
/// ```dart
/// if (errorMessage != null)
///   AuthErrorBanner(message: errorMessage!),
/// ```
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    super.key,
    required this.message,
  });

  /// The error message to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.all(Spacing.s),
            margin: const EdgeInsets.only(bottom: Spacing.m),
            decoration: BoxDecoration(
              color: DsColors.authRebrandError.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Sizes.radiusS),
              border: Border.all(
                color: DsColors.authRebrandError,
                width: 1,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontFamily: FontFamilies.figtree,
                fontSize: AuthRebrandMetrics.errorTextFontSize,
                fontVariations: const [FontVariations.regular],
                color: DsColors.authRebrandError,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
