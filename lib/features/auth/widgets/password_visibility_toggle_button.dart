import 'package:flutter/material.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Shared password visibility toggle button with proper Semantics.
///
/// Provides consistent accessibility and UX across all password fields.
/// Style-agnostic: accepts optional [color] and [size] to match
/// both Rebrand screens (DsColors, AuthRebrandMetrics) and legacy
/// widgets (tokens, Spacing).
///
/// Usage:
/// ```dart
/// suffixIcon: PasswordVisibilityToggleButton(
///   obscured: _obscurePassword,
///   onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
///   color: DsColors.grayscale500,
///   size: AuthRebrandMetrics.passwordToggleIconSize,
/// ),
/// ```
class PasswordVisibilityToggleButton extends StatelessWidget {
  const PasswordVisibilityToggleButton({
    super.key,
    required this.obscured,
    required this.onPressed,
    this.color,
    this.size,
  });

  /// Whether the password field is currently obscured.
  final bool obscured;

  /// Callback when the toggle button is pressed.
  final VoidCallback onPressed;

  /// Icon color. Defaults to grey if not specified.
  final Color? color;

  /// Icon size. Defaults to 24 if not specified.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = obscured ? l10n.authShowPassword : l10n.authHidePassword;

    return Semantics(
      excludeSemantics: true,
      button: true,
      label: label,
      child: IconButton(
        tooltip: label,
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: color,
          size: size,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
