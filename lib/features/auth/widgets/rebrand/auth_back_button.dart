import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'auth_rebrand_metrics.dart';

/// Back button for Auth Rebrand v3 screens.
///
/// Positioned at top-left with 44dp touch target.
/// Uses arrow_back_ios_new icon (thinner iOS-style chevron).
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    super.key,
    required this.onPressed,
    this.semanticsLabel,
  });

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Optional semantics label for accessibility
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? 'Zurück',
      child: SizedBox(
        width: Sizes.touchTargetMin,
        height: Sizes.touchTargetMin,
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: AuthRebrandMetrics.backButtonIconSize,
            color: DsColors.authRebrandTextPrimary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: AuthRebrandMetrics.backButtonTouchTarget,
            minHeight: AuthRebrandMetrics.backButtonTouchTarget,
          ),
        ),
      ),
    );
  }
}
