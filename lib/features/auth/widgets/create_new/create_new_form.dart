import 'package:flutter/material.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/features/auth/l10n/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/utils/field_auto_scroller.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';

/// Configuration for a password field in the create new password form.
class PasswordFieldConfig {
  const PasswordFieldConfig({
    required this.controller,
    required this.fieldKey,
    required this.isObscured,
    required this.onToggleObscure,
  });

  final TextEditingController controller;
  final GlobalKey fieldKey;
  final bool isObscured;
  final VoidCallback onToggleObscure;
}

class CreateNewForm extends StatelessWidget {
  const CreateNewForm({
    super.key,
    required this.autoScroller,
    required this.newPasswordConfig,
    required this.confirmPasswordConfig,
    this.fieldScrollPadding = EdgeInsets.zero,
    this.confirmTextStyle,
    this.confirmHintStyle,
  });

  final FieldAutoScroller autoScroller;
  final PasswordFieldConfig newPasswordConfig;
  final PasswordFieldConfig confirmPasswordConfig;
  final EdgeInsets fieldScrollPadding;
  final TextStyle? confirmTextStyle;
  final TextStyle? confirmHintStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              autoScroller.ensureVisible(newPasswordConfig.fieldKey);
            }
          },
          child: LoginPasswordField(
            key: newPasswordConfig.fieldKey,
            textFieldKey: const ValueKey(TestKeys.authPasswordField),
            controller: newPasswordConfig.controller,
            errorText: null,
            onChanged: (_) {},
            obscure: newPasswordConfig.isObscured,
            onToggleObscure: newPasswordConfig.onToggleObscure,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            scrollPadding: fieldScrollPadding,
            hintText: AuthStrings.createNewHint1,
          ),
        ),
        const SizedBox(height: AuthLayout.gapInputToCta),
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              autoScroller.ensureVisible(confirmPasswordConfig.fieldKey);
            }
          },
          child: LoginPasswordField(
            key: confirmPasswordConfig.fieldKey,
            textFieldKey: const ValueKey(TestKeys.authConfirmPasswordField),
            controller: confirmPasswordConfig.controller,
            errorText: null,
            onChanged: (_) {},
            obscure: confirmPasswordConfig.isObscured,
            onToggleObscure: confirmPasswordConfig.onToggleObscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            scrollPadding: fieldScrollPadding,
            hintText: AuthStrings.createNewHint2,
            textStyle: confirmTextStyle,
            hintStyle: confirmHintStyle,
          ),
        ),
      ],
    );
  }
}
