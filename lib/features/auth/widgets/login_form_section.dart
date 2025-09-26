import 'package:flutter/material.dart';
import 'package:luvi_app/features/auth/widgets/social_auth_row.dart';

class LoginFormSection extends StatelessWidget {
  const LoginFormSection({
    super.key,
    required this.gapBelowForgot,
    required this.socialGap,
    required this.onGoogle,
    required this.onApple,
  });

  final double gapBelowForgot;
  final double socialGap;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: gapBelowForgot),
        SocialAuthRow(
          onGoogle: onGoogle,
          onApple: onApple,
          dividerToButtonsGap: socialGap,
        ),
      ],
    );
  }
}
