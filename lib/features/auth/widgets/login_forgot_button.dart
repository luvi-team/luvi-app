import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';

class LoginForgotButton extends StatelessWidget {
  const LoginForgotButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        key: const ValueKey('login_forgot_button'),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Passwort vergessen?',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            height: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 105),
          ),
        ),
      ),
    );
  }
}
