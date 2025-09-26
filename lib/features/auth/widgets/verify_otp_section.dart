import 'package:flutter/material.dart';
import 'package:luvi_app/features/auth/widgets/verification_code_input.dart';

class VerifyOtpSection extends StatelessWidget {
  const VerifyOtpSection({
    super.key,
    required this.length,
    required this.scrollPadding,
    required this.inactiveBorderColor,
    required this.focusedBorderColor,
    required this.onChanged,
  });

  final int length;
  final EdgeInsets scrollPadding;
  final Color inactiveBorderColor;
  final Color focusedBorderColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: VerificationCodeInput(
        length: length,
        autofocus: true,
        inactiveBorderColor: inactiveBorderColor,
        focusedBorderColor: focusedBorderColor,
        scrollPadding: scrollPadding,
        onChanged: onChanged,
      ),
    );
  }
}
