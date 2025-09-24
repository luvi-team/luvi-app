import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
    required this.obscure,
    required this.onToggleObscure,
    this.onSubmitted,
    this.scrollPadding = EdgeInsets.zero,
    this.textInputAction = TextInputAction.done,
    this.hintText = 'Dein Passwort',
    this.textStyle,
    this.hintStyle,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsets scrollPadding;
  final TextInputAction textInputAction;
  final String hintText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final resolvedTextStyle = textStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          height: 1.5,
          color: theme.colorScheme.onSurface,
        );
    final resolvedHintStyle = hintStyle ??
        resolvedTextStyle?.copyWith(
          color: tokens.grayscale500,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: Sizes.buttonHeight,
          decoration: BoxDecoration(
            color: tokens.cardSurface,
            borderRadius: BorderRadius.circular(Sizes.radiusM),
            border: Border.all(
              color: errorText != null
                  ? theme.colorScheme.error
                  : tokens.inputBorder,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            textInputAction: textInputAction,
            autofillHints: const [AutofillHints.password],
            style: resolvedTextStyle,
            scrollPadding: scrollPadding,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: resolvedHintStyle,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: Spacing.m,
                right: Spacing.xs,
                top: Spacing.s,
                bottom: Spacing.s,
              ),
              suffixIcon: Semantics(
                label: obscure ? 'Passwort anzeigen' : 'Passwort ausblenden',
                button: true,
                child: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: Spacing.l,
                    color: theme.colorScheme.onSurface.withValues(alpha: 105),
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: Spacing.s - Spacing.xs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
