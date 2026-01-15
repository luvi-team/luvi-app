import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'auth_rebrand_metrics.dart';

/// Back button for Auth Rebrand v3 screens.
///
/// Positioned at top-left with 44dp touch target.
/// Uses custom Figma SVG chevron (stroke 1.5dp) for pixel-perfect alignment.
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
          icon: SvgPicture.asset(
            'assets/icons/Auth/auth_back_chevron.svg',
            // SVG is 44x44 with centered chevron - render at full touch target size
            width: Sizes.touchTargetMin,
            height: Sizes.touchTargetMin,
            colorFilter: const ColorFilter.mode(
              DsColors.authRebrandTextPrimary,
              BlendMode.srcIn,
            ),
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
