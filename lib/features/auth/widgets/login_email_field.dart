import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

class LoginEmailField extends StatelessWidget {
  const LoginEmailField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
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
                  : theme.colorScheme.outlineVariant.withValues(alpha: 219),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autofocus: autofocus,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Deine E-Mail',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 105),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: Spacing.m,
                right: Spacing.m,
                top: Spacing.s,
                bottom: Spacing.s,
              ),
            ),
            onChanged: onChanged,
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
