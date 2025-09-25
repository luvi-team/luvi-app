import 'package:flutter/material.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/widgets/login_cta_section.dart';

class LoginCtaSectionWrapper extends StatelessWidget {
  const LoginCtaSectionWrapper({
    super.key,
    required this.isLoading,
    required this.hasValidationError,
    required this.onSubmit,
    required this.onSignup,
  });

  final bool isLoading;
  final bool hasValidationError;
  final VoidCallback onSubmit;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AuthLayout.ctaTopAfterCopy),
        LoginCtaSection(
          onSubmit: onSubmit,
          onSignup: onSignup,
          hasValidationError: hasValidationError,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
