import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';

class FieldErrorText extends StatelessWidget {
  const FieldErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.s - Spacing.xs),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 14,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
