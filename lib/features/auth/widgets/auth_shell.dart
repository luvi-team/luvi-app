import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
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
  }) : assert(
         !showBackButton || onBackPressed != null,
         'onBackPressed must be provided when showBackButton is true',
       );

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
    // Auth-Flow Bugfix: Tap-to-dismiss Keyboard
    // HitTestBehavior.translucent erlaubt das Durchreichen von Taps an Kinder
    // (Buttons/Links funktionieren weiterhin), während gleichzeitig das Keyboard
    // bei Tap auf leere Flächen geschlossen wird.
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Full-screen gradient background
          Positioned.fill(child: background),

          // Main content with SafeArea
          SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Back button row (if shown)
              // Note: assertion guarantees onBackPressed != null when showBackButton is true
              if (showBackButton)
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
                      // Figma: Back button without circle background, 32×30.5px icon
                      backgroundColor: DsColors.transparent,
                      iconColor: DsColors.textPrimary,
                      iconSize: Sizes.authBackIconSize,
                    ),
                  ),
                ),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    // Add bottom safe area padding when no bottomCta is present
                    // to prevent content from being obscured by home indicator
                    bottom: bottomCta == null
                        ? MediaQuery.of(context).padding.bottom
                        : 0,
                  ),
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
      ),
    );
  }
}
