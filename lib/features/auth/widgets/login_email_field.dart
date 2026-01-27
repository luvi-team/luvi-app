import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/l10n/auth_strings.dart';
import 'package:luvi_app/features/auth/widgets/field_error_text.dart';

class LoginEmailField extends StatelessWidget {
  const LoginEmailField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
    this.autofocus = false,
    this.onSubmitted,
    this.scrollPadding = EdgeInsets.zero,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsets scrollPadding;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final inputStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 24 / 16,
      color: theme.colorScheme.onSurface,
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
            keyboardType: TextInputType.emailAddress,
            textInputAction: textInputAction,
            autofillHints: const [AutofillHints.email],
            autofocus: autofocus,
            style: inputStyle,
            scrollPadding: scrollPadding,
            decoration: InputDecoration(
              hintText: AuthStrings.emailHint,
              hintStyle: inputStyle?.copyWith(color: tokens.grayscale500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: Spacing.m,
                right: Spacing.m,
                top: Spacing.s,
                bottom: Spacing.s,
              ),
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        if (errorText != null) FieldErrorText(errorText!),
      ],
    );
  }
}
