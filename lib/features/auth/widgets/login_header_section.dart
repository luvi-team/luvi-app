import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_forgot_button.dart';
import 'package:luvi_app/features/auth/widgets/login_header.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';

class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.obscurePassword,
    required this.fieldScrollPadding,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onToggleObscure,
    required this.onForgotPassword,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;
  final EdgeInsets fieldScrollPadding;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.l + Spacing.xs),
        const LoginHeader(),
        const SizedBox(height: Spacing.l + Spacing.xs),
        LoginEmailField(
          controller: emailController,
          errorText: emailError,
          autofocus: true,
          scrollPadding: fieldScrollPadding,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
        LoginPasswordField(
          controller: passwordController,
          errorText: passwordError,
          obscure: obscurePassword,
          scrollPadding: fieldScrollPadding,
          onToggleObscure: onToggleObscure,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: Spacing.xs),
        LoginForgotButton(onPressed: onForgotPassword),
      ],
    );
  }
}
