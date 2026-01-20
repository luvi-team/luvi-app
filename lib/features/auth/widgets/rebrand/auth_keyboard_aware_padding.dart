import 'package:flutter/material.dart';
import 'auth_rebrand_metrics.dart';

/// Keyboard-aware padding widget for Auth Rebrand v3 screens.
///
/// Animates padding based on keyboard visibility to shift content upward
/// when keyboard is open. Uses metrics from [AuthRebrandMetrics] for
/// consistent behavior across all auth screens.
///
/// Use [compact] for screens with fewer fields (e.g., ResetPasswordScreen,
/// CreateNewPasswordScreen) which need less upward shift.
class AuthKeyboardAwarePadding extends StatelessWidget {
  const AuthKeyboardAwarePadding({
    super.key,
    required this.child,
    this.compact = false,
  });

  /// The content to wrap with keyboard-aware padding.
  final Widget child;

  /// Use compact padding factors for screens with fewer fields.
  ///
  /// - `false` (default): Uses [AuthRebrandMetrics.keyboardPaddingFactor] and
  ///   [AuthRebrandMetrics.keyboardPaddingMax] for Login/Signup screens.
  /// - `true`: Uses [AuthRebrandMetrics.keyboardPaddingFactorCompact] and
  ///   [AuthRebrandMetrics.keyboardPaddingMaxCompact] for Reset/CreatePassword.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Use viewInsetsOf to limit rebuilds to viewInsets changes only,
    // avoiding unnecessary rebuilds from other MediaQuery changes.
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final factor = compact
        ? AuthRebrandMetrics.keyboardPaddingFactorCompact
        : AuthRebrandMetrics.keyboardPaddingFactor;
    final max = compact
        ? AuthRebrandMetrics.keyboardPaddingMaxCompact
        : AuthRebrandMetrics.keyboardPaddingMax;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: (inset * factor).clamp(0.0, max)),
      child: child,
    );
  }
}
