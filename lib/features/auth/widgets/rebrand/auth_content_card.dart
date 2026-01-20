import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'auth_rebrand_metrics.dart';

/// Content card for Auth Rebrand v3 screens.
///
/// White rounded card with padding, used to contain form elements.
/// Figma: radius 12, padding 16, white background.
class AuthContentCard extends StatelessWidget {
  const AuthContentCard({
    super.key,
    required this.child,
    this.width,
    this.padding,
  });

  /// The content of the card
  final Widget child;

  /// Optional fixed width (defaults to card width from metrics)
  final double? width;

  /// Optional custom padding (defaults to card padding from metrics)
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? AuthRebrandMetrics.cardWidth,
      padding: padding ?? const EdgeInsets.all(AuthRebrandMetrics.cardPadding),
      decoration: BoxDecoration(
        color: DsColors.authRebrandCardSurface,
        borderRadius: BorderRadius.circular(AuthRebrandMetrics.cardRadius),
      ),
      child: child,
    );
  }
}
