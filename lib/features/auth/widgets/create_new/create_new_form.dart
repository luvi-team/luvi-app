import 'package:flutter/material.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/utils/field_auto_scroller.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';

class CreateNewForm extends StatelessWidget {
  const CreateNewForm({
    super.key,
    required this.autoScroller,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.passwordFieldKey,
    required this.confirmFieldKey,
    required this.isNewPasswordObscured,
    required this.isConfirmPasswordObscured,
    required this.onToggleNewPassword,
    required this.onToggleConfirmPassword,
    required this.fieldScrollPadding,
    required this.confirmTextStyle,
    required this.confirmHintStyle,
  });

  final FieldAutoScroller autoScroller;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey passwordFieldKey;
  final GlobalKey confirmFieldKey;
  final bool isNewPasswordObscured;
  final bool isConfirmPasswordObscured;
  final VoidCallback onToggleNewPassword;
  final VoidCallback onToggleConfirmPassword;
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
            if (hasFocus) autoScroller.ensureVisible(passwordFieldKey);
          },
          child: LoginPasswordField(
            key: passwordFieldKey,
            textFieldKey: const Key('AuthPasswordField'),
            controller: newPasswordController,
            errorText: null,
            onChanged: (_) {},
            obscure: isNewPasswordObscured,
            onToggleObscure: onToggleNewPassword,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            scrollPadding: fieldScrollPadding,
            hintText: AuthStrings.createNewHint1,
          ),
        ),
        const SizedBox(height: AuthLayout.gapInputToCta),
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) autoScroller.ensureVisible(confirmFieldKey);
          },
          child: LoginPasswordField(
            key: confirmFieldKey,
            textFieldKey: const Key('AuthConfirmPasswordField'),
            controller: confirmPasswordController,
            errorText: null,
            onChanged: (_) {},
            obscure: isConfirmPasswordObscured,
            onToggleObscure: onToggleConfirmPassword,
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
