import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/features/shared/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/state/reset_password_state.dart';
import 'package:luvi_app/features/auth/state/reset_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/login_email_field.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  static const String routeName = '/auth/forgot';

  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(resetPasswordProvider);
    if (state.email.isNotEmpty) {
      _emailController.value = _emailController.value.copyWith(
        text: state.email,
        selection: TextSelection.collapsed(offset: state.email.length),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(resetPasswordProvider);
    final submitState = ref.watch(resetSubmitProvider);
    if (_emailController.text != state.email) {
      _emailController.value = _emailController.value.copyWith(
        text: state.email,
        selection: TextSelection.collapsed(offset: state.email.length),
      );
    }
    final backButtonTopSpacing = topOffsetFromSafeArea(
      AuthLayout.backButtonTop,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );

    final safeBottom = MediaQuery.of(context).padding.bottom;
    final fieldScrollPadding = EdgeInsets.only(
      bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
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
      backgroundColor: theme.colorScheme.surface,
      body: AuthScreenShell(
        includeBottomReserve: false,
        children: [
          SizedBox(height: backButtonTopSpacing),
          BackButtonCircle(
            onPressed: () {
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                context.goNamed('login');
              }
            },
            size: AuthLayout.backButtonSize,
            innerSize: AuthLayout.backButtonSize,
            backgroundColor: theme.colorScheme.primary,
            iconColor: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: AuthLayout.backButtonToTitle),
          Text(
            AuthStrings.forgotTitle,
            key: const ValueKey('reset_title'),
            style: titleStyle,
          ),
          const SizedBox(height: Spacing.xs),
          Text(AuthStrings.forgotSubtitle, style: subtitleStyle),
          const SizedBox(height: AuthLayout.titleToInput),
          LoginEmailField(
            key: const ValueKey('reset_email_field'),
            controller: _emailController,
            errorText: state.errorText,
            autofocus: false,
            onChanged: (value) =>
                ref.read(resetPasswordProvider.notifier).setEmail(value),
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.done,
            scrollPadding: fieldScrollPadding,
          ),
          const SizedBox(height: AuthLayout.inputToCta),
          SizedBox(
            height: Sizes.buttonHeight,
            width: double.infinity,
            child: ElevatedButton(
              key: const ValueKey('reset_cta'),
              onPressed: state.isValid && !submitState.isLoading
                  ? () async {
                      await ref
                          .read(resetSubmitProvider.notifier)
                          .submit(
                            state.email,
                            onSuccess: () async {
                              if (!context.mounted) return;
                              context.goNamed('forgot_sent');
                            },
                          );
                    }
                  : null,
              child: submitState.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AuthStrings.forgotCta),
            ),
          ),
        ],
      ),
    );
  }
}
