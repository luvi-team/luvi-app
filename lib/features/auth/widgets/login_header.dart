import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/strings/auth_strings.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      label: 'Willkommen zurück',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AuthStrings.loginHeadline,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 32,
              height: 1.25,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            AuthStrings.loginSubhead,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              height: 1.33,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
