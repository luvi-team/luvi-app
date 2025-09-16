import 'package:flutter/material.dart';

class LoginForgotButton extends StatelessWidget {
  const LoginForgotButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
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
