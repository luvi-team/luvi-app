import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'auth_back_button.dart';
import 'auth_keyboard_aware_padding.dart';
import 'auth_rainbow_background.dart';
import 'auth_rebrand_metrics.dart';

/// Scaffold wrapper for Auth Rebrand v3 screens.
///
/// Provides consistent layout:
/// - Beige background ([DsColors.authRebrandBackground])
/// - Rainbow arcs via [AuthRainbowBackground]
/// - Back button (top-left) via [AuthBackButton]
/// - Keyboard-aware content area via [AuthKeyboardAwarePadding]
///
/// Reduces 60+ LOC and 10-level nesting to a single widget.
///
/// Example usage:
/// ```dart
/// AuthRebrandScaffold(
///   scaffoldKey: const ValueKey('auth_login_screen'),
///   onBack: () => context.go(AuthSignInScreen.routeName),
///   child: Column(
///     children: [
///       AuthContentCard(child: _buildForm(context)),
///     ],
///   ),
/// )
/// ```
class AuthRebrandScaffold extends StatelessWidget {
  const AuthRebrandScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.compactKeyboard = false,
    this.scaffoldKey,
  });

  /// The content to display (typically AuthContentCard wrapped in Column).
  final Widget child;

  /// Callback when back button is pressed.
  final VoidCallback onBack;

  /// Use compact keyboard padding (for screens with fewer fields).
  ///
  /// Set to `true` for ResetPasswordScreen, CreateNewPasswordScreen.
  /// Set to `false` (default) for LoginScreen, AuthSignupScreen.
  final bool compactKeyboard;

  /// Optional key for the Scaffold widget (for testing).
  final Key? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: DsColors.authRebrandBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Rainbow background (containerTop aligned with back button chevron)
          Positioned.fill(
            child: AuthRainbowBackground(
              containerTop: topPadding + AuthRebrandMetrics.rainbowContainerTopOffset,
            ),
          ),

          // Back button (top-left, independent positioning)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AuthRebrandMetrics.backButtonLeft,
                  top: AuthRebrandMetrics.backButtonTop,
                ),
                child: AuthBackButton(
                  onPressed: onBack,
                  semanticsLabel: l10n?.authBackSemantic ??
                      MaterialLocalizations.of(context).backButtonTooltip,
                ),
              ),
            ),
          ),

          // Content area (vertically centered, keyboard-aware)
          SafeArea(
            child: Center(
              child: AuthKeyboardAwarePadding(
                compact: compactKeyboard,
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
