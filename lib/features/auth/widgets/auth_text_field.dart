import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/widgets/field_error_text.dart';

/// Reusable auth text field with shared styling for signup/login flows.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.errorText,
    this.obscureText = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.scrollPadding = EdgeInsets.zero,
    this.textAlign = TextAlign.start,
    this.frameless = false,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsets scrollPadding;
  final TextAlign textAlign;
  final bool frameless;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final inputStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: TypographyTokens.size14,
      height: TypographyTokens.lineHeightRatio24on14,
      color: theme.colorScheme.onSurface,
    );
    final resolvedHintStyle = inputStyle?.copyWith(color: tokens.grayscale500);

    // Frameless variant: no box, just the inner TextField.
    if (frameless) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            textCapitalization: textCapitalization,
            obscureText: obscureText,
            autofocus: autofocus,
            style: inputStyle,
            scrollPadding: scrollPadding,
            textAlign: textAlign,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
            ).copyWith(
              hintText: hintText.isEmpty ? null : hintText,
              hintStyle: resolvedHintStyle,
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted ?? (_) => FocusScope.of(context).nextFocus(),
          ),
          if (errorText != null) FieldErrorText(errorText!),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: Sizes.buttonHeight,
          decoration: BoxDecoration(
            color: tokens.cardSurface,
            borderRadius: BorderRadius.circular(Sizes.radiusM),
            border: Border.all(
              color:
                  errorText != null ? theme.colorScheme.error : tokens.inputBorder,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            textCapitalization: textCapitalization,
            obscureText: obscureText,
            autofocus: autofocus,
            style: inputStyle,
            scrollPadding: scrollPadding,
            textAlign: textAlign,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: resolvedHintStyle,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.m,
                vertical: Spacing.s,
              ),
            ),
            onChanged: onChanged,
            onSubmitted:
                onSubmitted ?? (_) => FocusScope.of(context).nextFocus(),
          ),
        ),
        if (errorText != null) FieldErrorText(errorText!),
      ],
    );
  }
}
