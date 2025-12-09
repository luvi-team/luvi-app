import 'package:flutter/material.dart';
import 'package:luvi_app/core/widgets/back_button.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';

/// Unified shell widget for all Auth screens.
///
/// Provides a consistent layout structure:
/// - Full-screen gradient background (passed as parameter)
/// - SafeArea
/// - Optional back button (top-left)
/// - Scrollable content area
/// - Optional bottom CTA button
///
/// Usage:
/// ```dart
/// AuthShell(
///   background: const AuthLinearGradientBackground(),
///   showBackButton: true,
///   onBackPressed: () => context.pop(),
///   bottomCta: WelcomeButton(...),
///   child: Column(...),
/// )
/// ```
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.background,
    required this.child,
    this.showBackButton = false,
    this.onBackPressed,
    this.bottomCta,
    this.horizontalPadding = AuthLayout.horizontalPadding,
  });

  /// The gradient background widget (Conic, Linear, or Radial)
  final Widget background;

  /// The main content of the screen
  final Widget child;

  /// Whether to show the back button in the top-left corner
  final bool showBackButton;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Optional CTA button fixed at the bottom
  final Widget? bottomCta;

  /// Horizontal padding for content (default: AuthLayout.horizontalPadding)
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen gradient background
        Positioned.fill(child: background),

        // Main content with SafeArea
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Back button row (if shown)
              if (showBackButton && onBackPressed != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    top: AuthLayout.backButtonTopInset,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BackButtonCircle(
                      key: const ValueKey('backButtonCircle'),
                      onPressed: onBackPressed!,
                    ),
                  ),
                ),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: child,
                ),
              ),

              // Bottom CTA (if provided)
              if (bottomCta != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: MediaQuery.of(context).padding.bottom +
                        AuthLayout.ctaBottomInset,
                  ),
                  child: bottomCta,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
