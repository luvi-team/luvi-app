import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';

/// Shared bottom CTA wrapper that handles keyboard insets, SafeArea, and
/// consistent spacing for auth flows.
class AuthBottomCta extends StatelessWidget {
  const AuthBottomCta({
    super.key,
    required this.child,
    this.topPadding = AuthLayout.ctaTopAfterCopy,
    this.horizontalPadding = AuthLayout.horizontalPadding,
    this.bottomPadding = Spacing.s,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final double topPadding;
  final double horizontalPadding;
  final double bottomPadding;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: animationDuration,
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}
