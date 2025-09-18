import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';

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
        SizedBox(
          height: hasValidationError
              ? AuthLayout.ctaLinkGapError
              : AuthLayout.ctaLinkGapNormal,
        ),
        Center(
          child: TextButton(
            key: const ValueKey('login_signup_link'),
            onPressed: onSignup,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Neu bei LUVI? ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: 'Starte hier',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 17,
                      height: 1.47,
                      color: tokens.cardBorderSelected,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
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
