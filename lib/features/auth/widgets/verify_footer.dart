import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';

class VerifyFooter extends StatelessWidget {
  const VerifyFooter({
    super.key,
    required this.helper,
    required this.resend,
    required this.helperStyle,
    required this.resendStyle,
    required this.ctaEnabled,
    required this.onConfirm,
    required this.onResend,
  });

  final String helper;
  final String resend;
  final TextStyle? helperStyle;
  final TextStyle? resendStyle;
  final bool ctaEnabled;
  final VoidCallback onConfirm;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: Sizes.buttonHeight,
          child: ElevatedButton(
            key: const ValueKey('verify_confirm_button'),
            onPressed: ctaEnabled ? onConfirm : null,
            child: const Text(AuthStrings.verifyCta),
          ),
        ),
        const SizedBox(height: AuthLayout.gapSection),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(helper, style: helperStyle),
            TextButton(
              onPressed: onResend,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(resend, style: resendStyle),
            ),
          ],
        ),
      ],
    );
  }
}
