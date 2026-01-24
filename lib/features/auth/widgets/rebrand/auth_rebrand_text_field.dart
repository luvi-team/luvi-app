import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'auth_rebrand_metrics.dart';

/// Intentional non-localized fallbacks for edge cases where L10n context
/// is unavailable (e.g., during app initialization). These match the
/// universal field semantics and are acceptable per CodeRabbit option (b).
const String _kEmailFallback = 'Email';
const String _kPasswordFallback = 'Password';
const String _kGenericFieldFallback = 'Text field';

/// Text field for Auth Rebrand v3 screens.
///
/// Gray background (#F7F7F8) with gray border (#DCDCDC).
/// Error state shows red border (#C93838) and red placeholder text.
/// Figma: 329×50, radius 12, border 1px, placeholder 12/15.
///
/// A11y: The [semanticLabel] parameter allows providing a custom label
/// for screen readers. If not provided, the [hintText] is used as fallback.
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
    this.semanticLabel,
  });

  /// Text editing controller
  final TextEditingController controller;

  /// Placeholder text
  final String hintText;

  /// Error message to display (replaces hint text when in error state)
  final String? errorText;

  /// Whether the field is in error state.
  ///
  /// This is the authoritative flag for error styling. Callers should set
  /// this to `true` when validation fails. If [errorText] is provided
  /// (and non-empty), the error state is inferred even when this is `false`.
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

  /// Optional semantic label for screen readers.
  /// If not provided, the [hintText] is used as fallback.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // hasError is the primary source-of-truth; errorText presence serves as
    // fallback to catch cases where caller forgets to set hasError explicitly.
    // Empty errorText is ignored to avoid false-positive error styling.
    final showError = hasError || (errorText != null && errorText!.isNotEmpty);
    final borderColor = showError
        ? DsColors.authRebrandError
        : DsColors.authRebrandInputBorder;

    final field = SizedBox(
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
          fontSize: AuthRebrandMetrics.inputTextFontSize,
          fontWeight: FontWeight.normal,
          color: showError
              ? DsColors.authRebrandError
              : DsColors.authRebrandTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: (errorText != null && errorText!.isNotEmpty)
              ? errorText
              : hintText,
          hintStyle: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: AuthRebrandMetrics.placeholderFontSize,
            fontWeight: FontWeight.normal,
            color: showError
                ? DsColors.authRebrandError
                : DsColors.grayscale500,
            height: AuthRebrandMetrics.placeholderLineHeightRatio,
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

    // Derive fallback label from field properties (MUST-03 compliant)
    // Uses existing L10n keys: authEmailHint, authPasswordHint
    final l10n = AppLocalizations.of(context);
    final effectiveLabel = _deriveFallbackLabel(l10n, showError);

    // Issue 4: Error text is already shown visually as hintText (lines 113-115).
    // Removed Semantics.hint to prevent duplicate screen-reader announcements.
    return Semantics(
      label: effectiveLabel,
      textField: true,
      child: field,
    );
  }

  /// Computes the effective semantic label to use for accessibility.
  ///
  /// Logic order:
  /// 1. [semanticLabel] if provided.
  /// 2. Field-type + error message if in error state.
  /// 3. Field-type label based on keyboard type.
  /// 4. [hintText] as last resort.
  String _deriveFallbackLabel(AppLocalizations? l10n, bool showError) {
    // 1. Explicit semanticLabel always wins
    if (semanticLabel != null) {
      return semanticLabel!;
    }

    // 2. Determine field-type label (extracted to avoid duplication)
    final fieldLabel = _getFieldTypeLabel(l10n);

    // 3. Error state: combine field-type with error message
    if (showError && errorText != null && errorText!.isNotEmpty) {
      return '$fieldLabel: $errorText';
    }

    // 4. Normal state: just field-type label
    return fieldLabel;
  }

  /// Returns the appropriate field-type label based on keyboard type.
  /// Ensures a non-empty fallback for accessibility compliance.
  String _getFieldTypeLabel(AppLocalizations? l10n) {
    if (keyboardType == TextInputType.emailAddress) {
      return l10n?.authEmailHint ?? _kEmailFallback;
    }
    // Check both obscureText and visiblePassword keyboard type to handle
    // password fields even when visibility is toggled.
    if (obscureText || keyboardType == TextInputType.visiblePassword) {
      return l10n?.authPasswordHint ?? _kPasswordFallback;
    }
    // Ensure non-empty fallback for generic fields
    if (hintText.isNotEmpty) {
      return hintText;
    }
    return _kGenericFieldFallback;
  }
}
