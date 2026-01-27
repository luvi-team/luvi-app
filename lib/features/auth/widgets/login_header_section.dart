import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/auth/widgets/login_forgot_button.dart';
import 'package:luvi_app/features/auth/widgets/login_header.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';

/// Bundles callbacks for login form actions.
class LoginFormCallbacks {
  const LoginFormCallbacks({
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onToggleObscure,
    required this.onForgotPassword,
    required this.onSubmit,
  });

  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;
}

class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.callbacks,
    this.emailError,
    this.passwordError,
    this.obscurePassword = true,
    this.fieldScrollPadding = EdgeInsets.zero,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final LoginFormCallbacks callbacks;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;
  final EdgeInsets fieldScrollPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.l + Spacing.xs),
        const LoginHeader(),
        const SizedBox(height: Spacing.l + Spacing.xs),
        // Auth-Flow Bugfix: Prevents automatic keyboard opening
        LoginEmailField(
          controller: emailController,
          errorText: emailError,
          autofocus: false,
          scrollPadding: fieldScrollPadding,
          onChanged: callbacks.onEmailChanged,
        ),
        const SizedBox(height: Spacing.s + Spacing.xs),
        LoginPasswordField(
          controller: passwordController,
          errorText: passwordError,
          obscure: obscurePassword,
          scrollPadding: fieldScrollPadding,
          onToggleObscure: callbacks.onToggleObscure,
          onChanged: callbacks.onPasswordChanged,
          onSubmitted: (_) => callbacks.onSubmit(),
        ),
        const SizedBox(height: Spacing.xs),
        LoginForgotButton(onPressed: callbacks.onForgotPassword),
      ],
    );
  }
}
