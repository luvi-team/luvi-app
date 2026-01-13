import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'auth_rebrand_metrics.dart';

/// Text field for Auth Rebrand v3 screens.
///
/// Gray background (#F7F7F8) with gray border (#DCDCDC).
/// Error state shows red border (#C93838) and red placeholder text.
/// Figma: 329×50, radius 12, border 1px, placeholder 12/15.
class AuthRebrandTextField extends StatelessWidget {
  const AuthRebrandTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.hasError = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.autofocus = false,
    this.width,
  });

  /// Text editing controller
  final TextEditingController controller;

  /// Placeholder text
  final String hintText;

  /// Error message to display (replaces hint text when in error state)
  final String? errorText;

  /// Whether the field is in error state
  final bool hasError;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when submitted
  final ValueChanged<String>? onSubmitted;

  /// Optional suffix icon (e.g., password visibility toggle)
  final Widget? suffixIcon;

  /// Whether to autofocus this field
  final bool autofocus;

  /// Optional fixed width (defaults to button width from metrics)
  final double? width;

  @override
  Widget build(BuildContext context) {
    final showError = hasError || errorText != null;
    final borderColor = showError
        ? DsColors.authRebrandError
        : DsColors.authRebrandInputBorder;

    return SizedBox(
      width: width ?? AuthRebrandMetrics.buttonWidth,
      height: AuthRebrandMetrics.inputHeight,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        style: TextStyle(
          fontFamily: FontFamilies.figtree,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: showError
              ? DsColors.authRebrandError
              : DsColors.authRebrandTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: errorText ?? hintText,
          hintStyle: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: AuthRebrandMetrics.placeholderFontSize,
            fontWeight: FontWeight.normal,
            color: showError
                ? DsColors.authRebrandError
                : DsColors.grayscale500,
            height: AuthRebrandMetrics.placeholderLineHeight,
          ),
          filled: true,
          fillColor: DsColors.authRebrandInputBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AuthRebrandMetrics.inputPaddingHorizontal,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthRebrandMetrics.inputRadius),
            borderSide: BorderSide(
              color: borderColor,
              width: AuthRebrandMetrics.inputBorderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthRebrandMetrics.inputRadius),
            borderSide: BorderSide(
              color: borderColor,
              width: AuthRebrandMetrics.inputBorderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthRebrandMetrics.inputRadius),
            borderSide: BorderSide(
              color: showError ? DsColors.authRebrandError : DsColors.authRebrandCtaPrimary,
              width: AuthRebrandMetrics.inputBorderWidth,
            ),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
