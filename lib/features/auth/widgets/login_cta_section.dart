import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';

class LoginCtaSection extends StatelessWidget {
  const LoginCtaSection({
    super.key,
    required this.onSubmit,
    required this.onSignup,
    required this.hasValidationError,
  });

  final VoidCallback onSubmit;
  final VoidCallback onSignup;
  final bool hasValidationError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: Sizes.buttonHeight,
          child: ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Anmelden'),
          ),
        ),
        SizedBox(height: hasValidationError ? 29.0 : 31.0),
        Center(
          child: TextButton(
            onPressed: onSignup,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Neu bei LUVI? ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 214),
                    ),
                  ),
                  TextSpan(
                    text: 'Starte hier',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 17,
                      height: 1.47,
                      color: tokens.cardBorderSelected,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
      ],
    );
  }
}
