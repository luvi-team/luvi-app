import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/core/utils/layout_utils.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  static const EdgeInsets _fieldScrollPadding = EdgeInsets.only(
    bottom: Sizes.buttonHeight + Spacing.l * 2,
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backButtonTopSpacing = topOffsetFromSafeArea(
      context,
      AuthLayout.backButtonTop,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );

    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 24,
      height: 32 / 24,
      color: theme.colorScheme.onSurface,
    );

    final subtitleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: 20,
      height: 24 / 20,
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      key: const ValueKey('auth_forgot_screen'),
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: AuthScreenShell(
        children: [
          SizedBox(height: backButtonTopSpacing),
          BackButtonCircle(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/auth/login');
              }
            },
            size: 40,
            innerSize: 40,
            backgroundColor: theme.colorScheme.primary,
            iconColor: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: AuthLayout.backButtonToTitle),
          Text('Passwort vergessen? 💜', style: titleStyle),
          const SizedBox(height: Spacing.xs),
          Text('E-Mail eingeben für Link.', style: subtitleStyle),
          const SizedBox(height: AuthLayout.titleToInput),
          LoginEmailField(
            controller: _emailController,
            errorText: null,
            autofocus: false,
            onChanged: (_) {},
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.done,
            scrollPadding: _fieldScrollPadding,
          ),
          const SizedBox(height: AuthLayout.inputToCta),
          SizedBox(
            height: Sizes.buttonHeight,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Weiter'),
            ),
          ),
        ],
      ),
    );
  }
}
